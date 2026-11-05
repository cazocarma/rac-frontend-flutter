import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentacompa/features/photos/data/photo_upload_api.dart';
import 'package:rentacompa/features/photos/data/photo_upload_pointer.dart';
import 'package:rentacompa/shared/services/json_api.dart';
import 'package:rentacompa/shared/services/request_id.dart';

const requestId = '11111111-1111-4111-8111-111111111111';
const assetId = '22222222-2222-4222-8222-222222222222';
const statusBody = '{"asset_id":"$assetId","status":"queued"}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'raw refresh keeps frozen bytes and idempotency; confirmation uses empty POST',
    () async {
      var calls = 0;
      final bytes = Uint8List.fromList([1, 2, 3]);
      final api = PhotoUploadApi(
        'http://fixture.invalid',
        owner: 'owner',
        subject: () => 'owner',
        token: () async => 'token',
        refresh: () async {
          bytes[0] = 99;
        },
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'POST');
          if (calls <= 2) {
            expect(request.url.path, '/api/user/me/photo-sources');
            expect(request.headers['content-type'], 'image/png');
            expect(request.headers['idempotency-key'], requestId);
            expect(request.bodyBytes, [1, 2, 3]);
          } else {
            expect(
              request.url.path,
              '/api/user/me/photo-sources/$assetId/confirm',
            );
            expect(request.bodyBytes, isEmpty);
          }
          return http.Response(
            calls == 1 ? '{}' : statusBody,
            calls == 1 ? 401 : 202,
          );
        }),
      );
      expect(
        (await api.upload(requestId, bytes, 'image/png')).state,
        PhotoSourceState.queued,
      );
      await api.confirm(assetId);
      expect(calls, 3);
      api.close();
    },
  );
  test('JSON command refresh also freezes the original payload', () async {
    var calls = 0;
    final body = <String, dynamic>{'version': '1'};
    final api = JsonApi(
      'http://fixture.invalid',
      apiPath: '/fixture',
      token: () async => 'token',
      refresh: () async {
        body['version'] = '2';
      },
      client: MockClient((request) async {
        calls++;
        expect(jsonDecode(request.body)['version'], '1');
        return http.Response('{}', calls == 1 ? 401 : 200);
      }),
    );
    await api.request('/command', body: body);
    expect(calls, 2);
    api.close();
  });
  test('account change during refresh never replays private bytes', () async {
    var owner = 'owner', calls = 0;
    final api = PhotoUploadApi(
      'http://fixture.invalid',
      owner: 'owner',
      subject: () => owner,
      token: () async => 'token',
      refresh: () async {
        owner = 'other';
      },
      client: MockClient((_) async {
        calls++;
        return http.Response('{}', 401);
      }),
    );
    await expectLater(
      api.upload(requestId, Uint8List.fromList([1]), 'image/png'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'photo_session_changed',
        ),
      ),
    );
    expect(calls, 1);
    api.close();
  });
  test(
    'account change in flight does not reveal the previous account response',
    () async {
      var owner = 'owner';
      final api = PhotoUploadApi(
        'http://fixture.invalid',
        owner: 'owner',
        subject: () => owner,
        token: () async => 'token',
        client: MockClient((_) async {
          owner = 'other';
          return http.Response(statusBody, 200);
        }),
      );
      await expectLater(
        api.byRequest(requestId),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'photo_session_changed',
          ),
        ),
      );
      api.close();
    },
  );
  test(
    'unrecognized approval state and invalid path IDs fail closed',
    () async {
      expect(
        () => PhotoSourceStatus.fromJson({
          'asset_id': assetId,
          'status': 'approved',
        }),
        throwsFormatException,
      );
      var calls = 0;
      final api = PhotoUploadApi(
        'http://fixture.invalid',
        owner: 'owner',
        subject: () => 'owner',
        token: () async => 'token',
        client: MockClient((_) async {
          calls++;
          return http.Response(statusBody, 200);
        }),
      );
      expect(() => api.byRequest('../documents'), throwsArgumentError);
      expect(calls, 0);
      api.close();
    },
  );
  test(
    'retry pointer is scoped by issuer/API/account and stores no image or token',
    () async {
      SharedPreferences.setMockInitialValues({});
      final a = PreferencesPhotoUploadPointer('realm-a', 'api-a', 'account-a');
      final b = PreferencesPhotoUploadPointer('realm-a', 'api-a', 'account-b');
      final c = PreferencesPhotoUploadPointer('realm-b', 'api-a', 'account-a');
      final d = PreferencesPhotoUploadPointer('realm-a', 'api-b', 'account-a');
      await a.save(requestId);
      expect(await a.load(), requestId);
      expect(await b.load(), isNull);
      expect(await c.load(), isNull);
      expect(await d.load(), isNull);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), {a.key});
      expect(preferences.get(a.key), requestId);
      await preferences.setInt(a.key, 123);
      expect(await a.load(), isNull);
      final fresh = newRequestId();
      expect(isRequestId(fresh), isTrue);
    },
  );
}
