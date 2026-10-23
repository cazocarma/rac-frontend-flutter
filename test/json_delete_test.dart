import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/shared/services/json_api.dart';

void main() {
  test(
    'DELETE survives one authentication renewal without becoming GET or POST',
    () async {
      var calls = 0, refreshes = 0;
      final api = JsonApi(
        'http://test.invalid',
        apiPath: '/api/match',
        token: () async => 'fixture',
        refresh: () async {
          refreshes++;
        },
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'DELETE');
          expect(request.url.path, '/api/match/block');
          return calls == 1
              ? http.Response('{"error":"invalid_token"}', 401)
              : http.Response('{"removed":true}', 200);
        }),
      );
      expect(
        (await api.request('/block', method: 'DELETE'))['removed'],
        isTrue,
      );
      expect(calls, 2);
      expect(refreshes, 1);
      api.close();
    },
  );
}
