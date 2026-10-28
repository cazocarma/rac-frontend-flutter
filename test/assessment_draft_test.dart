import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/assessment_draft.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_decision.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'editorial_api_test.dart' show StaffFixture;

Map<String, String> statements() => {
  for (final id in editorialStatementIds) id: 'Synthetic commitment',
};
List<AssessmentQuestionDraft> questions() => List.generate(
  3,
  (i) =>
      AssessmentQuestionDraft('Scenario ${i + 1}', ['Report', 'Continue'], 0),
);

void main() {
  test(
    'private structured draft includes explicit key but never asserts approval or hash',
    () {
      final command = draftAssessment(
        version: 'candidate-1',
        locale: 'en',
        statements: statements(),
        questions: questions(),
      );
      final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
      expect(command.path, '/api/admin/staff/assessments/drafts');
      expect(
        body.keys,
        unorderedEquals([
          'event_id',
          'definition_id',
          'version',
          'locale',
          'content',
        ]),
      );
      final content = body['content'] as Map<String, dynamic>;
      expect(content['statements'], hasLength(5));
      expect(content['questions'], hasLength(3));
      expect(content['questions'][0]['correct_option'], 'option_1');
    },
  );

  test(
    'shape and text checks reject missing key, empty options and control characters',
    () {
      for (final question in [
        const AssessmentQuestionDraft('Scenario', ['A', 'B'], null),
        const AssessmentQuestionDraft('Scenario', ['A'], 0),
        const AssessmentQuestionDraft('Scenario', ['A', 'B', 'C', 'D', 'E'], 0),
        const AssessmentQuestionDraft('Scenario', ['A', ' '], 0),
        const AssessmentQuestionDraft('Scenario', ['A', 'B'], 2),
        const AssessmentQuestionDraft('Scenario\u0000', ['A', 'B'], 0),
      ]) {
        expect(
          () => draftAssessment(
            version: '1',
            locale: 'es',
            statements: statements(),
            questions: [question, ...questions().skip(1)],
          ),
          throwsFormatException,
        );
      }
      final incomplete = statements()..remove(editorialStatementIds.first);
      expect(
        () => draftAssessment(
          version: '1',
          locale: 'es',
          statements: incomplete,
          questions: questions(),
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'assessment draft validates owner hash receipt before resolving',
    () async {
      final command = draftAssessment(
        version: '1',
        locale: 'es',
        statements: statements(),
        questions: questions(),
      );
      final body = jsonDecode(command.encodedBody);
      for (final hash in ['b' * 64, 'not-a-hash']) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((request) async {
            expect(request.body, command.encodedBody);
            return http.Response(
              jsonEncode({
                'definition_id': body['definition_id'],
                'sha256': hash,
              }),
              200,
            );
          }),
        );
        final attempt = EditorialDecisionAttempt(command);
        if (hash.length == 64) {
          await attempt.submit(api);
          expect(attempt.receipt!['sha256'], hash);
          expect(attempt.resolved, isTrue);
        } else {
          await expectLater(
            attempt.submit(api),
            throwsA(isA<EditorialFailure>()),
          );
          expect(attempt.resolved, isFalse);
          expect(attempt.uncertain, isTrue);
        }
      }
    },
  );

  testWidgets('correct answers start unset and incomplete form cannot dispatch', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AssessmentDraftForm(
              onSubmit: (_) async {
                calls++;
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Create private assessment'));
    await tester.pumpAndSettle();
    final answers = tester
        .widgetList<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        )
        .toList();
    expect(answers, hasLength(3));
    expect(answers.every((a) => a.initialValue == null), isTrue);
    final button = find.widgetWithText(
      FilledButton,
      'Create private assessment',
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text(
        'Complete commitments, questions, options and correct answers. Also check version and language.',
      ),
      findsOneWidget,
    );
  });
}
