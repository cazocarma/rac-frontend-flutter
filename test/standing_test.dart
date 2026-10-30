import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/shared/services/account_standing.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/widgets/standing_notice.dart';
import 'auth_test.dart' show FakeSession;

Map<String, dynamic> snapshot(String status) => {
  'enforcement_enabled': true,
  'status': status,
  'version': 2,
  'capabilities': {
    for (final key in AccountStanding.commercial) key: status == 'active',
    for (final key in AccountStanding.protective) key: true,
  },
};

void main() {
  test(
    'standing binds own Bearer identity and rejects invalid responses',
    () async {
      final previous = Session.auth;
      addTearDown(() {
        Session.auth = previous;
      });
      Session.auth = FakeSession()..signedIn = true;
      var response = snapshot('suspended');
      var statusCode = 200;
      final api = UserApi(
        'https://api.example',
        client: MockClient((request) async {
          expect(request.url.path, '/api/user/me/standing');
          expect(request.url.query, isEmpty);
          expect(
            request.headers['Authorization'],
            'Bearer verified-access-token',
          );
          return http.Response(jsonEncode(response), statusCode);
        }),
      );
      final state = await api.standing();
      expect(state.hasRestrictions, isTrue);
      expect(state.capabilities['access_safety'], isTrue);
      expect(state.capabilities['request_privacy'], isTrue);
      statusCode = 503;
      await expectLater(api.standing(), throwsStateError);
      statusCode = 200;
      response = {
        'enforcement_enabled': true,
        'status': 'active',
        'version': 2,
      };
      await expectLater(api.standing(), throwsFormatException);
      response = {'enforcement_enabled': false};
      expect((await api.standing()).enabled, isFalse);
      expect((Session.auth as FakeSession).cleared, isFalse);
    },
  );
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'standing notice $locale $width localizes states and preserves protective navigation',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var current = AccountStanding.fromJson(snapshot('suspended'));
          var unavailable = false;
          var calls = 0;
          final opened = <String>[];
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Column(
                  children: [
                    StandingNotice(
                      load: () async {
                        calls++;
                        if (unavailable) throw StateError('private offline');
                        return current;
                      },
                    ),
                    TextButton(
                      key: const Key('bookings'),
                      onPressed: () => opened.add('bookings'),
                      child: const Text('bookings'),
                    ),
                    TextButton(
                      key: const Key('safety'),
                      onPressed: () => opened.add('safety'),
                      child: const Text('safety'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          final t = AppLocalizations.of(
            tester.element(find.byType(StandingNotice)),
          )!;
          Future<void> poll() async {
            await tester.pump(const Duration(seconds: 5));
            await tester.pump();
          }

          expect(find.text(t.standingSuspended), findsOneWidget);
          expect(find.text(t.standingRestrictedHelp), findsOneWidget);
          expect(find.text(t.standingRetry), findsNothing);
          current = AccountStanding.fromJson(snapshot('restricted'));
          await poll();
          expect(find.text(t.standingRestricted), findsOneWidget);
          expect(find.text(t.standingSuspended), findsNothing);
          current = AccountStanding.fromJson(snapshot('banned'));
          await poll();
          expect(find.text(t.standingSuspended), findsOneWidget);
          unavailable = true;
          await poll();
          expect(find.text(t.standingLoadFailed), findsOneWidget);
          expect(find.text(t.standingUnavailableHelp), findsOneWidget);
          expect(find.text(t.standingSuspended), findsNothing);
          expect(find.textContaining('private offline'), findsNothing);
          expect(
            find.text('Reintentar'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          await tester.tap(find.byKey(const Key('bookings')));
          await tester.tap(find.byKey(const Key('safety')));
          expect(opened, ['bookings', 'safety']);
          final beforeRetry = calls;
          await tester.tap(find.text(t.standingRetry));
          await tester.pump();
          expect(calls, beforeRetry + 1);
          expect(find.text(t.standingLoadFailed), findsOneWidget);
          unavailable = false;
          current = AccountStanding.fromJson(snapshot('active'));
          await tester.tap(find.text(t.standingRetry));
          await tester.pump();
          expect(find.text(t.standingLoadFailed), findsNothing);
          expect(find.text(t.standingSuspended), findsNothing);
          expect(find.text(t.standingRestricted), findsNothing);
          current = AccountStanding.fromJson({'enforcement_enabled': false});
          await poll();
          expect(find.text(t.standingRestricted), findsNothing);
          expect(find.byKey(const Key('bookings')), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          final before = calls;
          await tester.pump(const Duration(seconds: 10));
          expect(calls, before);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
