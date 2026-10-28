import 'dart:convert';
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';

const editorialStatementIds = [
  'no_illicit_substances',
  'no_sexual_services',
  'catalog_only',
  'adults_only',
  'enforcement_and_appeal',
];

class AssessmentQuestionDraft {
  const AssessmentQuestionDraft(this.text, this.options, this.correct);
  final String text;
  final List<String> options;
  final int? correct;
}

bool _text(String text, int maximum) =>
    text.trim().isNotEmpty &&
    text.runes.length <= maximum &&
    !text.runes.any(
      (r) => (r < 32 && r != 9 && r != 10) || (r >= 127 && r <= 159),
    );

EditorialCommand draftAssessment({
  required String version,
  required String locale,
  required Map<String, String> statements,
  required List<AssessmentQuestionDraft> questions,
}) {
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$').hasMatch(version) ||
      !{'es', 'en'}.contains(locale) ||
      statements.length != 5 ||
      editorialStatementIds.any((id) => !_text(statements[id] ?? '', 2000)) ||
      questions.length != 3) {
    throw const FormatException('Invalid assessment draft');
  }
  for (final q in questions) {
    if (!_text(q.text, 2000) ||
        q.options.length < 2 ||
        q.options.length > 4 ||
        q.options.any((o) => !_text(o, 1000)) ||
        q.correct == null ||
        q.correct! < 0 ||
        q.correct! >= q.options.length) {
      throw const FormatException('Invalid assessment question');
    }
  }
  final content = {
    'statements': [
      for (final id in editorialStatementIds)
        {'id': id, 'text': statements[id]},
    ],
    'questions': [
      for (var i = 0; i < questions.length; i++)
        {
          'id': 'question_${i + 1}',
          'text': questions[i].text,
          'options': [
            for (var j = 0; j < questions[i].options.length; j++)
              {'id': 'option_${j + 1}', 'text': questions[i].options[j]},
          ],
          'correct_option': 'option_${questions[i].correct! + 1}',
        },
    ],
  };
  if (utf8.encode(jsonEncode(content)).length > 65536) {
    throw const FormatException('Assessment draft too large');
  }
  // Only the owner canonicalizes content and assigns its authoritative hash.
  return EditorialCommand('assessments/drafts', {
    'event_id': newEditorialReference(),
    'definition_id': newEditorialReference(),
    'version': version,
    'locale': locale,
    'content': content,
  });
}

class AssessmentDraftForm extends StatefulWidget {
  const AssessmentDraftForm({super.key, required this.onSubmit});
  final Future<void> Function(EditorialCommand) onSubmit;
  @override
  State<AssessmentDraftForm> createState() => _AssessmentDraftFormState();
}

class _AssessmentDraftFormState extends State<AssessmentDraftForm> {
  final version = TextEditingController();
  final statements = List.generate(5, (_) => TextEditingController());
  final questions = List.generate(3, (_) => TextEditingController());
  final options = List.generate(
    3,
    (_) => List.generate(4, (_) => TextEditingController()),
  );
  final counts = [2, 2, 2];
  final correct = <int?>[null, null, null];
  String? locale;
  bool failed = false;
  bool busy = false;

  Future<void> prepare() async {
    final t = AppLocalizations.of(context)!;
    EditorialCommand command;
    try {
      command = draftAssessment(
        version: version.text,
        locale: locale ?? '',
        statements: {
          for (var i = 0; i < 5; i++)
            editorialStatementIds[i]: statements[i].text,
        },
        questions: [
          for (var i = 0; i < 3; i++)
            AssessmentQuestionDraft(
              questions[i].text,
              options[i].take(counts[i]).map((c) => c.text).toList(),
              correct[i],
            ),
        ],
      );
    } catch (_) {
      setState(() => failed = true);
      return;
    }
    setState(() {
      busy = true;
      failed = false;
    });
    final labels = [
      t.staffNoSubstances,
      t.staffNoSexualServices,
      t.staffCatalogOnly,
      t.staffAdultsOnly,
      t.staffEnforcement,
    ];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.staffConfirmAssessment),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.staffPrivateAssessmentHelp),
                for (var i = 0; i < 5; i++)
                  ListTile(
                    title: Text(labels[i]),
                    subtitle: SelectableText(statements[i].text),
                  ),
                for (var i = 0; i < 3; i++) ...[
                  SelectableText(questions[i].text),
                  for (var j = 0; j < counts[i]; j++)
                    ListTile(
                      leading: Icon(
                        j == correct[i]
                            ? Icons.check_circle_outline
                            : Icons.circle_outlined,
                      ),
                      title: SelectableText(options[i][j].text),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.staffCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.staffConfirmAssessment),
          ),
        ],
      ),
    );
    if (!mounted) return;
    try {
      if (confirmed == true) await widget.onSubmit(command);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      version,
      ...statements,
      ...questions,
      ...options.expand((o) => o),
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final labels = [
      t.staffNoSubstances,
      t.staffNoSexualServices,
      t.staffCatalogOnly,
      t.staffAdultsOnly,
      t.staffEnforcement,
    ];
    return ExpansionTile(
      title: Text(t.staffCreateAssessment),
      children: [
        Text(t.staffPrivateAssessmentHelp),
        TextField(
          controller: version,
          enabled: !busy,
          decoration: InputDecoration(labelText: t.staffVersion),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: t.staffLocale),
          items: const [
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: busy ? null : (v) => setState(() => locale = v),
        ),
        for (var i = 0; i < 5; i++)
          TextField(
            controller: statements[i],
            enabled: !busy,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: labels[i]),
          ),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                TextField(
                  controller: questions[i],
                  enabled: !busy,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: '${t.staffQuestion} ${i + 1}',
                  ),
                ),
                for (var j = 0; j < counts[i]; j++)
                  TextField(
                    controller: options[i][j],
                    enabled: !busy,
                    decoration: InputDecoration(
                      labelText: '${t.staffOption} ${j + 1}',
                    ),
                  ),
                DropdownButtonFormField<int>(
                  key: ValueKey('correct-$i-${counts[i]}'),
                  initialValue: correct[i],
                  decoration: InputDecoration(labelText: t.staffCorrectOption),
                  items: [
                    for (var j = 0; j < counts[i]; j++)
                      DropdownMenuItem(
                        value: j,
                        child: Text('${t.staffOption} ${j + 1}'),
                      ),
                  ],
                  onChanged: busy
                      ? null
                      : (v) => setState(() => correct[i] = v),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: busy || counts[i] == 4
                          ? null
                          : () => setState(() => counts[i]++),
                      child: Text(t.staffAddOption),
                    ),
                    TextButton(
                      onPressed: busy || counts[i] == 2
                          ? null
                          : () => setState(() {
                              counts[i]--;
                              if (correct[i] != null &&
                                  correct[i]! >= counts[i]) {
                                correct[i] = null;
                              }
                            }),
                      child: Text(t.staffRemoveOption),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (failed) Text(t.staffAssessmentInvalid),
        FilledButton(
          onPressed: busy ? null : prepare,
          child: Text(t.staffCreateAssessment),
        ),
      ],
    );
  }
}
