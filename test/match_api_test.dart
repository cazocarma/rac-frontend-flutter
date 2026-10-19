import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/shared/services/auth_session.dart';
import 'package:rentacompa/shared/services/session.dart';

class _Session implements AuthSession {
  @override
  Future<void> refresh() async {}
  @override
  Future<String?> accessToken() async => 'fixture-token';
  @override
  Map<String, dynamic> get claims => {};
  @override
  Future<void> clear() async {}
  @override
  Future<void> login() async {}
  @override
  Future<void> logout() async {}
}

void main() {
  late AuthSession previous;
  setUp(() {
    previous = Session.auth;
    Session.auth = _Session();
  });
  tearDown(() => Session.auth = previous);
  test(
    'allowance queries the selected date and uses the verified session',
    () async {
      final api = MatchApi(
        'http://api.test',
        client: MockClient((request) async {
          expect(request.url.path, '/api/match/compa/owner/allowance');
          expect(request.url.queryParameters, {'fecha': '2026-11-03'});
          expect(request.headers['Authorization'], 'Bearer fixture-token');
          return http.Response('{"disponibles":2,"usados":1}', 200);
        }),
      );
      expect(
        (await api.allowance('owner', date: '2026-11-03'))['disponibles'],
        2,
      );
    },
  );
  test(
    'weekly cap response is a subscription requirement, not a successful acceptance',
    () async {
      final api = MatchApi(
        'http://api.test',
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer fixture-token');
          expect(jsonDecode(request.body), {'estado': 'activa'});
          return http.Response(
            jsonEncode({
              'error': 'subscription_required',
              'cupo': {
                'usados': 3,
                'disponibles': 0,
                'semana_inicio': '2026-10-12',
              },
            }),
            402,
          );
        }),
      );
      await expectLater(
        api.updateState('booking', 'activa'),
        throwsA(
          isA<SubscriptionRequired>().having(
            (e) => e.allowance['disponibles'],
            'remaining',
            0,
          ),
        ),
      );
    },
  );
  test('successful acceptance returns the actual server state', () async {
    final api = MatchApi(
      'http://api.test',
      client: MockClient(
        (_) async => http.Response('{"id":"booking","estado":"activa"}', 200),
      ),
    );
    expect((await api.updateState('booking', 'activa'))['estado'], 'activa');
  });
}
