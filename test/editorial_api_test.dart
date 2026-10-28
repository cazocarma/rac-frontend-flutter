import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/shared/services/auth_session.dart';

class StaffFixture implements AuthSession {
  String? token = 'staff-token';
  @override
  Map<String, dynamic> get claims => {
    'realm_access': {
      'roles': ['admin'],
    },
  };
  @override
  Future<String?> accessToken() async => token;
  @override
  Future<void> login() async => throw StateError('unexpected login');
  @override
  Future<void> logout() async => token = null;
  @override
  Future<void> clear() async => token = null;
  @override
  Future<void> refresh() async => throw StateError('unexpected refresh');
}

void main() {
  test(
    'MFA expiry uses only an exact approved error code, never upstream diagnostics',
    () async {
      for (final body in [
        '{"error":"staff_step_up_required"}',
        '{"error":"private diagnostic"}',
        '{"error":"staff_step_up_required","extra":"private"}',
      ]) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((_) async => http.Response(body, 403)),
        );
        await expectLater(
          api.sessionInfo(),
          throwsA(
            isA<EditorialFailure>()
                .having(
                  (e) => e.authenticationRequired,
                  'needs authentication',
                  body == '{"error":"staff_step_up_required"}',
                )
                .having(
                  (e) => e.toString().contains('private'),
                  'no diagnostics',
                  false,
                ),
          ),
        );
      }
    },
  );

  test(
    'registry head is fetched by locale and unsafe browser integers fail closed',
    () async {
      for (final body in [
        '{"registry_version":0}',
        '{"registry_version":4}',
        '{"registry_version":9007199254740991}',
        '{"registry_version":1.5}',
        '{"registry_version":"4"}',
        '{"registry_version":-1}',
        '{"registry_version":4,"extra":"private"}',
      ]) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((request) async {
            expect(request.url.path, '/api/admin/staff/documents/registry/es');
            expect(request.followRedirects, isFalse);
            return http.Response(body, 200);
          }),
        );
        if (body == '{"registry_version":0}' ||
            body == '{"registry_version":4}') {
          expect(
            await api.registryHead('es'),
            jsonDecode(body)['registry_version'],
          );
        } else {
          await expectLater(
            api.registryHead('es'),
            throwsA(isA<EditorialFailure>()),
          );
        }
      }
    },
  );

  test(
    'redirects stay disabled and oversized replies remain uncertain',
    () async {
      final client = MockClient((request) async {
        expect(request.followRedirects, isFalse);
        return http.Response('x' * 1048577, 200);
      });
      final api = EditorialApi(
        session: StaffFixture(),
        client: client,
        origin: Uri.parse('https://rac.test'),
      );
      await expectLater(
        api.submit(
          EditorialCommand('documents/drafts', {'event_id': 'stable'}),
        ),
        throwsA(
          isA<EditorialFailure>().having((e) => e.uncertain, 'uncertain', true),
        ),
      );
    },
  );
  test(
    'uncertain write has one attempt; explicit retry preserves frozen body',
    () async {
      final session = StaffFixture();
      final bodies = <String>[];
      final api = EditorialApi(
        session: session,
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://rac.test/api/admin/staff/documents/reviews',
          );
          expect(request.headers['Authorization'], 'Bearer ${session.token}');
          bodies.add(request.body);
          if (bodies.length == 1) {
            throw http.ClientException('secret diagnostic');
          }
          return http.Response('{"document_id":"doc"}', 200);
        }),
      );
      final body = <String, dynamic>{
        'event_id': 'stable-event',
        'document_id': 'doc',
        'decision': 'approved',
      };
      final command = EditorialCommand('documents/reviews', body);
      body['event_id'] = 'different-event';
      await expectLater(
        api.submit(command),
        throwsA(
          isA<EditorialFailure>().having((e) => e.uncertain, 'uncertain', true),
        ),
      );
      expect(bodies, hasLength(1));
      session.token = 'fresh-staff-token';
      expect(await api.submit(command), {'document_id': 'doc'});
      expect(bodies, hasLength(2));
      expect(bodies[0], bodies[1]);
      expect(jsonDecode(bodies[1])['event_id'], 'stable-event');
    },
  );

  test(
    'no token does not dispatch; realm admin does not authorize locally',
    () async {
      var calls = 0;
      final session = StaffFixture()..token = null;
      final api = EditorialApi(
        session: session,
        origin: Uri.parse('https://rac.test'),
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      await expectLater(
        api.sessionInfo(),
        throwsA(
          isA<EditorialFailure>()
              .having((e) => e.status, 'status', 401)
              .having((e) => e.uncertain, 'uncertain', false),
        ),
      );
      expect(calls, 0);
    },
  );

  test(
    'owner rejection is definite; proxy or malformed success is uncertain',
    () async {
      for (final status in [302, 403, 409, 503, 200]) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient(
            (_) async => http.Response('private upstream diagnostic', status),
          ),
        );
        await expectLater(
          api.submit(
            EditorialCommand('assessments/publications', {'event_id': 'same'}),
          ),
          throwsA(
            isA<EditorialFailure>()
                .having(
                  (e) => e.uncertain,
                  'uncertain',
                  status == 302 || status >= 500 || status == 200,
                )
                .having(
                  (e) => e.toString().contains('private'),
                  'no diagnostics',
                  false,
                ),
          ),
        );
      }
    },
  );

  test('fixed routes reject path injection and ambiguous origins', () {
    expect(
      () => EditorialCommand('../users', {'event_id': 'x'}),
      throwsArgumentError,
    );
    for (final url in [
      'https://user:password@rac.test',
      'https://rac.test/api',
      'https://rac.test?next=x',
    ]) {
      expect(
        () => EditorialApi(
          session: StaffFixture(),
          client: MockClient((_) async => http.Response('{}', 200)),
          origin: Uri.parse(url),
        ),
        throwsArgumentError,
      );
    }
    final api = EditorialApi(
      session: StaffFixture(),
      origin: Uri.parse('https://rac.test'),
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    expect(() => api.read('documents', '../session'), throwsArgumentError);
  });
}
