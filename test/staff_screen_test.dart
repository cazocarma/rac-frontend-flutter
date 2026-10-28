import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/staff_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/main.dart';

import 'editorial_api_test.dart' show StaffFixture;

void main() {
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
      if (status != 200) expect(find.text('Sign in with MFA'), findsOneWidget);
      if (status == 403)
        expect(
          find.text('This account cannot access the console.'),
          findsOneWidget,
        );
      if (status == 503)
        expect(
          find.text('We could not validate access. Retry or sign in again.'),
          findsOneWidget,
        );
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
