import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/services/json_api.dart';

void main() {
  for (final personal in [true, false]) {
    test(
      'public contact error survives transport, personal=$personal',
      () async {
        var calls = 0;
        final api = UserApi(
          'https://fixture.invalid',
          tokenProvider: () async => 'fixture',
          client: MockClient((request) async {
            calls++;
            expect(request.method, 'PUT');
            expect(
              request.url.path,
              personal ? '/api/user/me' : '/api/user/me/compa',
            );
            return http.Response(
              jsonEncode({
                'error': 'public_contact_not_allowed',
                'field': 'biografia',
                'private_rule': 'must_not_reach_ui',
              }),
              400,
            );
          }),
        );
        addTearDown(api.client.close);
        final save = personal
            ? api.savePersonalProfile({'nombre': 'Cris'})
            : api.saveCompa({'descripcion': 'Synthetic draft'});
        await expectLater(
          save,
          throwsA(
            isA<ApiException>()
                .having((e) => e.status, 'status', 400)
                .having((e) => e.code, 'code', 'public_contact_not_allowed'),
          ),
        );
        expect(calls, 1); // No retry or token refresh for a correctable edit.
      },
    );
  }

  test(
    'an unrelated invalid response does not become a contact accusation',
    () async {
      final api = UserApi(
        'https://fixture.invalid',
        tokenProvider: () async => 'fixture',
        client: MockClient(
          (_) async => http.Response('<html>failure</html>', 400),
        ),
      );
      addTearDown(api.client.close);
      await expectLater(
        api.savePersonalProfile({'nombre': 'Cris'}),
        throwsA(isA<StateError>()),
      );
    },
  );
}
