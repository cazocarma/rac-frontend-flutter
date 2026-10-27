import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/services/json_api.dart';

void main() {
  for (final code in [
    'DOCUMENT_ACCEPTANCE_REQUIRED',
    'COMPA_ATTESTATION_REQUIRED',
  ]) {
    test(
      'compa save preserves $code instead of claiming a network failure',
      () async {
        var calls = 0;
        final api = UserApi(
          'https://fixture.invalid',
          tokenProvider: () async => 'fixture',
          client: MockClient((request) async {
            calls++;
            expect(request.method, 'PUT');
            expect(jsonDecode(request.body), {
              'descripcion': 'synthetic draft',
            });
            return http.Response(jsonEncode({'error': code}), 428);
          }),
        );
        await expectLater(
          api.saveCompa({'descripcion': 'synthetic draft'}),
          throwsA(
            isA<ApiException>()
                .having((e) => e.status, 'status', 428)
                .having((e) => e.code, 'code', code),
          ),
        );
        expect(calls, 1);
        api.client.close();
      },
    );
  }
}
