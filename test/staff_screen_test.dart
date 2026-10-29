import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/staff_screen.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/main.dart';

import 'editorial_api_test.dart' show StaffFixture;

void main() {
  testWidgets(
    'scrolled long revision keeps its in-flight workspace and receipt',
    (tester) async {
      const reference = '11111111-1111-4111-8111-111111111111';
      final response = Completer<http.Response>();
      var writes = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          if (request.method == 'POST') {
            writes++;
            return response.future;
          }
          if (request.url.path.endsWith('/session')) {
            return http.Response(
              jsonEncode({
                'subject': 'reviewer',
                'permissions': [
                  'staff.session.read',
                  'documents.read',
                  'documents.approve',
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'id': reference,
              'sha256': 'a' * 64,
              'content': List.filled(
                100,
                'Synthetic paragraph for scrolling.',
              ).join('\n'),
              'version': '1',
              'locale': 'en',
              'author_id': 'other-author',
              'decision': null,
              'published_at': null,
            }),
            200,
          );
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StaffScreen(
            api: api,
            journal: EditorialJournal(store: OidcMemoryStore()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), reference);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Read exact revision'),
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Read exact revision'),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(CheckboxListTile),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      final approve = find.widgetWithText(FilledButton, 'Approve revision');
      await tester.ensureVisible(approve);
      await tester.tap(approve);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm decision'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(writes, 1);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Retry the same command'), findsNothing);
      response.complete(http.Response('{"document_id":"$reference"}', 200));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Operation confirmed. Read the revision again to view its current state.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry the same command'), findsNothing);
      expect(writes, 1);
    },
  );

  for (final status in [200, 401, 403, 503]) {
    testWidgets('staff entry presents server session outcome $status', (
      tester,
    ) async {
      var calls = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          calls++;
          expect(request.url.path, '/api/admin/staff/session');
          return http.Response(
            status == 200 ? '{"permissions":["staff.session.read"]}' : '{}',
            status,
          );
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StaffScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        find.text('Team session verified'),
        status == 200 ? findsOneWidget : findsNothing,
      );
      if (status != 200) {
        expect(find.text('Sign in with MFA'), findsOneWidget);
      }
      if (status == 403) {
        expect(
          find.text('This account cannot access the console.'),
          findsOneWidget,
        );
      }
      if (status == 503) {
        expect(
          find.text('We could not validate access. Retry or sign in again.'),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets('direct staff startup never checks ordinary account session', (
    tester,
  ) async {
    var ordinaryChecks = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StartupGate(
          requestedRoute: '/staff',
          checkSession: () async {
            ordinaryChecks++;
            return false;
          },
        ),
        routes: {'/staff': (_) => const Scaffold(body: Text('staff entry'))},
      ),
    );
    await tester.pumpAndSettle();
    expect(ordinaryChecks, 0);
    expect(find.text('staff entry'), findsOneWidget);
  });
}
