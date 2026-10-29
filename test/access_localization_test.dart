import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/shared/services/auth_api.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'auth_test.dart' show FakeSession;

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      for (final cancelled in [false, true]) {
        testWidgets(
          'access $locale $width cancellation=$cancelled keeps OIDC route behaviour',
          (tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final session = FakeSession()..fail = cancelled;
            final api = AuthApi(
              session: session,
              client: MockClient(
                (_) async => http.Response('{"id":"fixture-user"}', 200),
              ),
            );
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: UnifiedAuthScreen(auth: api),
                routes: {
                  '/home': (_) => const Scaffold(body: Text('home target')),
                },
              ),
            );
            final t = AppLocalizations.of(
              tester.element(find.byType(UnifiedAuthScreen)),
            )!;
            expect(t.accessStory, contains('\n'));
            expect(find.byType(TextField), findsNothing);
            await tester.ensureVisible(find.text(t.accessContinue));
            await tester.pumpAndSettle();
            await tester.tap(find.text(t.accessContinue));
            await tester.pumpAndSettle();
            if (cancelled) {
              expect(find.text(t.accessFailed), findsOneWidget);
              expect(find.byType(UnifiedAuthScreen), findsOneWidget);
            } else {
              expect(find.text('home target'), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
