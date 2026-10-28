import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';
import 'package:rentacompa/features/staff/editorial_workspace.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'editorial_api_test.dart' show StaffFixture;

const id = '11111111-1111-4111-8111-111111111111';
Widget workspace(EditorialApi api, EditorialJournal journal) => MaterialApp(
  key: UniqueKey(),
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: EditorialWorkspace(
        api: api,
        journal: journal,
        subject: 'reviewer',
        issuer: 'issuer',
        permissions: const {
          'documents.read',
          'documents.approve',
          'documents.publish',
        },
      ),
    ),
  ),
);

void main() {
  for (final firstStatus in [503, 403]) {
    testWidgets(
      'explicit confirmed approval survives $firstStatus and retries exact saved command',
      (tester) async {
        final bodies = <String>[];
        final journal = EditorialJournal(store: OidcMemoryStore());
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({
                  'id': id,
                  'sha256': 'a' * 64,
                  'content': 'Synthetic reviewed content',
                  'version': '1',
                  'locale': 'en',
                  'author_id': 'author',
                  'decision': null,
                  'published_at': null,
                }),
                200,
              );
            }
            bodies.add(request.body);
            return http.Response(
              bodies.length == 1
                  ? (firstStatus == 403
                        ? '{"error":"staff_step_up_required"}'
                        : '{}')
                  : '{"document_id":"$id"}',
              bodies.length == 1 ? firstStatus : 200,
            );
          }),
        );
        await tester.pumpWidget(workspace(api, journal));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), id);
        await tester.tap(
          find.widgetWithText(FilledButton, 'Read exact revision'),
        );
        await tester.pumpAndSettle();
        final approve = find.widgetWithText(FilledButton, 'Approve revision');
        expect(tester.widget<FilledButton>(approve).onPressed, isNull);
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();
        await tester.ensureVisible(approve);
        await tester.tap(approve);
        await tester.pumpAndSettle();
        expect(bodies, isEmpty);
        await tester.tap(find.widgetWithText(FilledButton, 'Confirm decision'));
        await tester.pumpAndSettle();
        expect(bodies, hasLength(1));
        final command = jsonDecode(bodies.single) as Map<String, dynamic>;
        expect(command['document_id'], id);
        expect(command['sha256'], 'a' * 64);
        expect(command['decision'], 'approved');
        expect(command.containsKey('actor'), isFalse);
        await tester.pumpWidget(workspace(api, journal));
        await tester.pumpAndSettle();
        expect(bodies, hasLength(1));
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Retry the same command'),
        );
        await tester.pumpAndSettle();
        expect(bodies, hasLength(2));
        expect(bodies[0], bodies[1]);
        expect(
          await journal.pending(
            subject: 'reviewer',
            issuer: 'issuer',
            origin: 'https://rac.test',
          ),
          isEmpty,
        );
        expect(
          find.text(
            'Operation confirmed. Read the revision again to view its current state.',
          ),
          findsOneWidget,
        );
      },
    );
  }
}
