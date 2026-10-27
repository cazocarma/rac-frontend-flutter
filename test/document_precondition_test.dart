import 'dart:convert';
import 'package:rentacompa/shared/services/document_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/shared/services/json_api.dart';
import 'package:rentacompa/shared/services/pending_documents.dart';

Map<String, dynamic> problem() => {
  'error': 'DOCUMENT_ACCEPTANCE_REQUIRED',
  'documents': [
    {
      'id': '12345678-1234-4234-8234-123456789abc',
      'kind': 'privacy',
      'sha256': List.filled(64, 'a').join(),
      'material_version': 'abcdef12-1234-4234-8234-123456789abc',
    },
  ],
};

void main() {
  test(
    'stream observer preserves response bytes and bounds metadata inspection',
    () async {
      for (final body in [jsonEncode(problem()), 'not-json', 'x' * 17000]) {
        var calls = 0;
        final events = <DocumentPrecondition>[];
        final client = DocumentHttpClient(
          MockClient((request) async {
            calls++;
            return http.Response(
              body,
              428,
              headers: {'x-fixture': 'preserved'},
            );
          }),
          onDocumentsRequired: events.add,
        );
        final response = await client.post(
          Uri.parse('https://test.invalid/profile'),
          body: 'private fixture',
        );
        expect(response.statusCode, 428);
        expect(response.body, body);
        expect(response.headers['x-fixture'], 'preserved');
        expect(calls, 1);
        expect(events.length, body.startsWith('{') ? 1 : 0);
        client.close();
      }
    },
  );

  test('rejects malformed, empty and duplicated prerequisites', () {
    expect(DocumentPrecondition.parse(403, problem()), isNull);
    expect(DocumentPrecondition.parse(428, {'error': 'other'}), isNull);
    expect(
      DocumentPrecondition.parse(428, {...problem(), 'documents': []}),
      isNull,
    );
    final duplicate = problem();
    final items = duplicate['documents'] as List;
    items.add(items.first);
    expect(DocumentPrecondition.parse(428, duplicate), isNull);
    final malformed = problem();
    (malformed['documents'] as List).first['sha256'] = 'invalid';
    expect(DocumentPrecondition.parse(428, malformed), isNull);
  });

  test(
    'notifies once, preserves error and never replays a rejected write',
    () async {
      var calls = 0, refreshes = 0;
      final events = <DocumentPrecondition>[];
      final api = JsonApi(
        'http://test.invalid',
        apiPath: '/api/chat',
        token: () async => 'fixture',
        refresh: () async {
          refreshes++;
        },
        onDocumentsRequired: events.add,
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'POST');
          return http.Response(jsonEncode(problem()), 428);
        }),
      );
      await expectLater(
        api.request('/messages', body: {'text': 'private fixture'}),
        throwsA(isA<ApiException>().having((e) => e.status, 'status', 428)),
      );
      expect(calls, 1);
      expect(refreshes, 0);
      expect(events.single.documents.single.kind, 'privacy');
      expect(() => events.single.documents.clear(), throwsUnsupportedError);
      api.close();
    },
  );
}
