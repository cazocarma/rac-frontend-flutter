import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/features/plans/ui/plans_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/widgets/weekly_allowance.dart';
import 'auth_test.dart' show FakeSession;

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('plans $locale $width keeps payments under construction', (
        tester,
      ) async {
        final previous = Session.auth;
        Session.auth = FakeSession();
        addTearDown(() => Session.auth = previous);
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PlansScreen(),
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(PlansScreen)),
        )!;
        expect(find.text(t.plansTitle), findsOneWidget);
        await tester.ensureVisible(find.text(t.plansPaymentsConstruction));
        expect(find.text(t.plansPaymentsConstruction), findsOneWidget);
        expect(find.text(t.plansPaymentDetails), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
      for (final subscribed in [false, true]) {
        testWidgets(
          'allowance $locale $width subscribed=$subscribed retries and changes week',
          (tester) async {
            final previous = Session.auth;
            Session.auth = FakeSession()..signedIn = true;
            addTearDown(() => Session.auth = previous);
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            var unavailable = true;
            final requests = <Uri>[];
            final user = UserApi(
              'http://fixture.invalid',
              client: MockClient(
                (request) async => http.Response('{"id":"compa-fixture"}', 200),
              ),
            );
            final match = MatchApi(
              'http://fixture.invalid',
              client: MockClient((request) async {
                requests.add(request.url);
                return http.Response(
                  jsonEncode(
                    unavailable
                        ? {'error': 'unavailable'}
                        : {
                            'disponibles': 4,
                            'limite_gratuito': 7,
                            'usados': 3,
                            'semana_inicio':
                                request.url.queryParameters['fecha'] ??
                                '2026-10-26',
                            'suscripcion_activa': subscribed,
                          },
                  ),
                  unavailable ? 503 : 200,
                );
              }),
            );
            addTearDown(user.client.close);
            addTearDown(match.client.close);
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: WeeklyAllowance(userApi: user, matchApi: match),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final context = tester.element(find.byType(WeeklyAllowance));
            final t = AppLocalizations.of(context)!;
            expect(find.text(t.allowanceLoadFailed), findsOneWidget);
            unavailable = false;
            await tester.tap(find.byTooltip(t.allowanceRetry));
            await tester.pumpAndSettle();
            expect(
              find.text(
                subscribed ? t.allowanceActive : t.allowanceAvailable(4, 7),
              ),
              findsOneWidget,
            );
            expect(find.text(t.allowanceWeek('2026-10-26', 3)), findsOneWidget);
            await tester.tap(find.byTooltip(t.allowanceRefresh));
            await tester.pumpAndSettle();
            expect(
              requests.last.path,
              '/api/match/compa/compa-fixture/allowance',
            );
            await tester.tap(find.text(t.allowanceSelectWeek));
            await tester.pumpAndSettle();
            await tester.tap(
              find
                  .descendant(
                    of: find.byType(CalendarDatePicker),
                    matching: find.text('15'),
                  )
                  .last,
            );
            await tester.tap(
              find.text(MaterialLocalizations.of(context).okButtonLabel),
            );
            await tester.pumpAndSettle();
            final now = DateTime.now();
            final date =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-15';
            expect(requests.last.queryParameters, {'fecha': date});
            expect(find.text(t.allowanceWeek(date, 3)), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
