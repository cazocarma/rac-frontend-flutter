import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../../documents/ui/document_prompt.dart';
import '../data/assessment_api.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, this.api});
  final AssessmentApi? api;
  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late final api = widget.api ?? AssessmentApi(Env.apiBase);
  late Future<CompaAssessment> data = api.current();
  final statements = <String, bool>{}, answers = <String, String>{};
  bool busy = false, stale = false, passed = false;
  String? error;
  void reload() {
    setState(() {
      statements.clear();
      answers.clear();
      error = null;
      stale = false;
      passed = false;
      data = api.current();
    });
  }

  Future<void> submit(CompaAssessment assessment) async {
    if (busy ||
        stale ||
        statements.values.where((value) => value).length != 5 ||
        answers.length != 3) {
      return;
    }
    final strings = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await api.submit(assessment, Map.of(statements), Map.of(answers));
      if (mounted) setState(() => passed = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          stale = e is ApiException && e.status == 409;
          if (stale) {
            statements.clear();
            answers.clear();
          }
          error = stale
              ? strings.compaRulesChanged
              : e is ApiException && e.code == 'quiz_incorrect'
              ? strings.compaRulesWrong
              : e is ApiException && e.code == 'declarations_required'
              ? strings.compaRulesDeclarations
              : strings.compaRulesFailed;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.compaRulesTitle)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.compaRulesIntro),
              const SizedBox(height: 20),
              FutureBuilder<CompaAssessment>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        Text(strings.compaRulesUnavailable),
                        OutlinedButton(
                          onPressed: reload,
                          child: Text(strings.compaRulesRetry),
                        ),
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final assessment = snapshot.data!;
                  if (passed || assessment.passedAt != null) {
                    return Column(
                      children: [
                        Text(strings.compaRulesPassed),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(strings.compaRulesContinue),
                        ),
                      ],
                    );
                  }
                  final ready =
                      !busy &&
                      !stale &&
                      statements.values.where((value) => value).length == 5 &&
                      answers.length == 3;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.pendingVersion(assessment.version)),
                      for (final statement in assessment.statements.entries)
                        CheckboxListTile(
                          key: ValueKey(statement.key),
                          value: statements[statement.key] ?? false,
                          title: Text(statement.value),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: busy || stale
                              ? null
                              : (value) => setState(
                                  () => statements[statement.key] =
                                      value ?? false,
                                ),
                        ),
                      for (final question in assessment.questions) ...[
                        const SizedBox(height: 16),
                        Text(
                          question.text,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        RadioGroup<String>(
                          groupValue: answers[question.id],
                          onChanged: (value) {
                            if (!busy && !stale && value != null) {
                              setState(() => answers[question.id] = value);
                            }
                          },
                          child: Column(
                            children: [
                              for (final option in question.options)
                                RadioListTile<String>(
                                  key: ValueKey('${question.id}:${option.id}'),
                                  value: option.id,
                                  title: Text(option.text),
                                  enabled: !busy && !stale,
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: ready ? () => submit(assessment) : null,
                        child: Text(
                          busy
                              ? strings.compaRulesSaving
                              : strings.compaRulesSubmit,
                        ),
                      ),
                      if (stale)
                        OutlinedButton(
                          onPressed: reload,
                          child: Text(strings.compaRulesRetry),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DocumentPrivacyEscape(),
                  ),
                ),
                child: Text(strings.privacyEscape),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
