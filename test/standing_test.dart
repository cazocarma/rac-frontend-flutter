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
  for (final width in [360.0, 1200.0]) {
    testWidgets('standing notice preserves content at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var current = AccountStanding.fromJson(snapshot('suspended'));
      var unavailable = false;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StandingNotice(
                  load: () async {
                    calls++;
                    if (unavailable) throw StateError('offline');
                    return current;
                  },
                ),
                TextButton(onPressed: () {}, child: const Text('Mis reservas')),
                TextButton(onPressed: () {}, child: const Text('Seguridad')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.text('Tu cuenta tiene actividades suspendidas'),
        findsOneWidget,
      );
      expect(find.text('Mis reservas'), findsOneWidget);
      expect(find.text('Seguridad'), findsOneWidget);
      expect(tester.takeException(), isNull);
      unavailable = true;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(
        find.text('No pudimos consultar el estado de tu cuenta'),
        findsOneWidget,
      );
      unavailable = false;
      current = AccountStanding.fromJson(snapshot('active'));
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(
        find.text('No pudimos consultar el estado de tu cuenta'),
        findsNothing,
      );
      expect(
        find.text('Tu cuenta tiene actividades suspendidas'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      final before = calls;
      await tester.pump(const Duration(seconds: 10));
      expect(calls, before);
      expect(tester.takeException(), isNull);
    });
  }
}
