import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_reader.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'editorial_api_test.dart' show StaffFixture;

const revisionId = '11111111-1111-4111-8111-111111111111';
Widget app(http.Client client) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: EditorialReader(
        api: EditorialApi(
          session: StaffFixture(),
          client: client,
          origin: Uri.parse('https://rac.test'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('reads exact revision without rendering markup as active HTML', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        MockClient((request) async {
          expect(request.url.path, '/api/admin/staff/documents/$revisionId');
          return http.Response(
            jsonEncode({
              'id': revisionId,
              'version': '1',
              'locale': 'es',
              'content': '<script>synthetic</script>',
              'sha256': 'a' * 64,
            }),
            200,
          );
        }),
      ),
    );
    await tester.enterText(find.byType(TextField), revisionId);
    await tester.tap(find.widgetWithText(FilledButton, 'Read exact revision'));
    await tester.pumpAndSettle();
    expect(find.text('<script>synthetic</script>'), findsOneWidget);
    expect(find.text('SHA-256: ${'a' * 64}'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'different');
    await tester.pump();
    expect(find.text('<script>synthetic</script>'), findsNothing);
  });

  testWidgets('late response cannot restore content after reference changes', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    await tester.pumpWidget(app(MockClient((_) => response.future)));
    await tester.enterText(find.byType(TextField), revisionId);
    await tester.tap(find.widgetWithText(FilledButton, 'Read exact revision'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'new reference');
    response.complete(
      http.Response(
        jsonEncode({
          'id': revisionId,
          'content': 'stale private content',
          'sha256': 'a' * 64,
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('stale private content'), findsNothing);
  });
}
