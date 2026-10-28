import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';

const editorialDocumentKinds = [
  'terms_client',
  'terms_compa',
  'community_rules',
  'privacy',
  'safety_rules',
];
final _reference = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);
bool _id(dynamic value) =>
    value is String &&
    _reference.hasMatch(value) &&
    value != '00000000-0000-0000-0000-000000000000';
bool _published(Map<String, dynamic> revision, String kind, String locale) =>
    _id(revision['id']) &&
    revision['kind'] == kind &&
    revision['locale'] == locale &&
    revision['sha256'] is String &&
    RegExp(r'^[0-9a-f]{64}$').hasMatch(revision['sha256'] as String) &&
    revision['decision'] == 'approved' &&
    _id(revision['author_id']) &&
    _id(revision['reviewer_id']) &&
    revision['author_id'] != revision['reviewer_id'] &&
    revision['published_at'] is String &&
    DateTime.tryParse(revision['published_at'] as String) != null;

EditorialCommand activationBundle({
  required String locale,
  required int expectedVersion,
  required Map<String, Map<String, dynamic>> documents,
  required Map<String, dynamic> assessment,
  required List<String> summary,
}) {
  if (!{'es', 'en'}.contains(locale) ||
      expectedVersion < 0 ||
      expectedVersion > 9007199254740990 ||
      documents.length != 5 ||
      editorialDocumentKinds.any(
        (kind) => !_published(documents[kind] ?? {}, kind, locale),
      ) ||
      !_published(assessment, 'compa_assessment', locale) ||
      documents.values.map((d) => d['id']).toSet().length != 5 ||
      summary.length > 3 ||
      summary.any(
        (s) =>
            s.trim().isEmpty ||
            s.runes.length > 280 ||
            s.runes.any((r) => r < 32 || (r >= 127 && r <= 159)),
      )) {
    throw const FormatException('Invalid published editorial bundle');
  }
  return EditorialCommand('documents/activations', {
    'event_id': newEditorialReference(),
    'expected_version': expectedVersion,
    'locale': locale,
    'documents': [
      for (final kind in editorialDocumentKinds)
        {
          'document_id': documents[kind]!['id'],
          'sha256': documents[kind]!['sha256'],
        },
    ],
    'assessment': {
      'definition_id': assessment['id'],
      'sha256': assessment['sha256'],
    },
    'summary': summary,
  });
}

class EditorialActivationForm extends StatefulWidget {
  const EditorialActivationForm({
    super.key,
    required this.api,
    required this.onSubmit,
  });
  final EditorialApi api;
  final Future<void> Function(EditorialCommand) onSubmit;
  @override
  State<EditorialActivationForm> createState() =>
      _EditorialActivationFormState();
}

class _EditorialActivationFormState extends State<EditorialActivationForm> {
  final references = List.generate(6, (_) => TextEditingController());
  final summary = TextEditingController();
  String? locale;
  bool busy = false;
  bool failed = false;

  Future<void> prepare() async {
    final language = locale;
    final ids = references.map((c) => c.text.trim().toLowerCase()).toList();
    if (language == null || ids.any((id) => !_id(id))) {
      setState(() => failed = true);
      return;
    }
    final points = summary.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      final expected = await widget.api.registryHead(language);
      final revisions = await Future.wait([
        for (var i = 0; i < 5; i++) widget.api.read('documents', ids[i]),
        widget.api.read('assessments', ids[5]),
      ]);
      for (var i = 0; i < 6; i++) {
        if (revisions[i]['id'] != ids[i]) {
          throw const FormatException('Revision mismatch');
        }
      }
      final command = activationBundle(
        locale: language,
        expectedVersion: expected,
        documents: {
          for (var i = 0; i < 5; i++) editorialDocumentKinds[i]: revisions[i],
        },
        assessment: revisions[5],
        summary: points,
      );
      if (!mounted) return;
      final t = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.staffConfirmActivation),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.staffActivationHelp),
                  Text(
                    '${t.staffRegistryVersion}: $expected → ${expected + 1} · $language',
                  ),
                  for (final revision in revisions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SelectableText(
                        '${revision['version']}\n${revision['id']}\nSHA-256: ${revision['sha256']}',
                      ),
                    ),
                  for (final point in points) Text(point),
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
              child: Text(t.staffConfirmActivation),
            ),
          ],
        ),
      );
      if (mounted && confirmed == true) await widget.onSubmit(command);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    for (final c in [...references, summary]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final labels = [
      t.staffClientTerms,
      t.staffCompaTerms,
      t.staffCommunityRules,
      t.staffPrivacy,
      t.staffSafetyRules,
      t.staffAssessment,
    ];
    return ExpansionTile(
      title: Text(t.staffActivateBundle),
      children: [
        Text(t.staffActivationHelp),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: t.staffLocale),
          items: const [
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: busy ? null : (v) => setState(() => locale = v),
        ),
        for (var i = 0; i < 6; i++)
          TextField(
            controller: references[i],
            enabled: !busy,
            decoration: InputDecoration(labelText: '${labels[i]} · UUID'),
          ),
        TextField(
          controller: summary,
          enabled: !busy,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(labelText: t.staffActivationSummary),
        ),
        if (failed) Text(t.staffActivationInvalid),
        FilledButton(
          onPressed: busy ? null : prepare,
          child: Text(t.staffPrepareActivation),
        ),
      ],
    );
  }
}
