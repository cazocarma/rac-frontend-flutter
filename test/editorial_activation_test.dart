import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_activation.dart';
import 'package:rentacompa/features/staff/editorial_decision.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'editorial_api_test.dart' show StaffFixture;

String id(int n) => '11111111-1111-4111-8111-${n.toString().padLeft(12, '0')}';
Map<String, dynamic> published(String kind, int n) => {
  'id': id(n),
  'kind': kind,
  'locale': 'en',
  'version': '1',
  'sha256': 'a' * 64,
  'decision': 'approved',
  'author_id': id(8),
  'reviewer_id': id(9),
  'published_at': '2026-10-20T12:00:00Z',
};
Map<String, Map<String, dynamic>> documents() => {
  for (var i = 0; i < 5; i++)
    editorialDocumentKinds[i]: published(editorialDocumentKinds[i], i + 1),
};

void main() {
  test(
    'activation binds complete published hashes and expected head without authority fields',
    () {
      final command = activationBundle(
        locale: 'en',
        expectedVersion: 4,
        documents: documents(),
        assessment: published('compa_assessment', 6),
        summary: ['Synthetic change'],
      );
      final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
      expect(command.path, '/api/admin/staff/documents/activations');
      expect(body['expected_version'], 4);
      expect(body['documents'], hasLength(5));
      expect(body['assessment']['definition_id'], id(6));
      expect(
        body.keys,
        unorderedEquals([
          'event_id',
          'expected_version',
          'locale',
          'documents',
          'assessment',
          'summary',
        ]),
      );
    },
  );

  test(
    'incomplete, wrong locale, wrong kind, self-reviewed and unpublished sets are rejected',
    () {
      for (final mutation in [
        (Map<String, Map<String, dynamic>> d) => d.remove('privacy'),
        (Map<String, Map<String, dynamic>> d) => d['privacy']!['locale'] = 'es',
        (Map<String, Map<String, dynamic>> d) =>
            d['privacy']!['kind'] = 'terms_compa',
        (Map<String, Map<String, dynamic>> d) =>
            d['privacy']!['reviewer_id'] = id(8),
        (Map<String, Map<String, dynamic>> d) =>
            d['privacy']!['published_at'] = null,
        (Map<String, Map<String, dynamic>> d) =>
            d['privacy']!['decision'] = 'rejected',
      ]) {
        final changed = documents();
        mutation(changed);
        expect(
          () => activationBundle(
            locale: 'en',
            expectedVersion: 0,
            documents: changed,
            assessment: published('compa_assessment', 6),
            summary: [],
          ),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'only expected+1 receipt resolves activation; stale or extra receipts stay uncertain',
    () async {
      final command = activationBundle(
        locale: 'en',
        expectedVersion: 4,
        documents: documents(),
        assessment: published('compa_assessment', 6),
        summary: [],
      );
      for (final body in [
        '{"registry_version":5}',
        '{"registry_version":4}',
        '{"registry_version":"5"}',
        '{"registry_version":5,"extra":"private"}',
      ]) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((_) async => http.Response(body, 200)),
        );
        final attempt = EditorialDecisionAttempt(command);
        if (body == '{"registry_version":5}') {
          await attempt.submit(api);
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

  testWidgets(
    'preparation fetches locale head and exact six revisions before explicit confirmation',
    (tester) async {
      final reads = <String>[];
      var submissions = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          expect(request.method, 'GET');
          reads.add(request.url.path);
          if (request.url.path.endsWith('/registry/en')) {
            return http.Response('{"registry_version":4}', 200);
          }
          final n =
              List.generate(
                6,
                (i) => id(i + 1),
              ).indexOf(request.url.path.split('/').last) +
              1;
          return http.Response(
            jsonEncode(
              published(
                n == 6 ? 'compa_assessment' : editorialDocumentKinds[n - 1],
                n,
              ),
            ),
            200,
          );
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: EditorialActivationForm(
                api: api,
                onSubmit: (command) async {
                  submissions++;
                  expect(
                    jsonDecode(command.encodedBody)['expected_version'],
                    4,
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Activate document bundle'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        await tester.enterText(find.byType(TextField).at(i), id(i + 1));
      }
      final prepare = find.widgetWithText(
        FilledButton,
        'Read and prepare activation',
      );
      await tester.ensureVisible(prepare);
      await tester.tap(prepare);
      await tester.pumpAndSettle();
      expect(reads, hasLength(7));
      expect(submissions, 0);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Confirm bundle activation'),
      );
      await tester.pumpAndSettle();
      expect(submissions, 1);
    },
  );
}
