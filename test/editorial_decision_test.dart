import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_decision.dart';
import 'editorial_api_test.dart' show StaffFixture;

Map<String, dynamic> revision() => {
  'id': '11111111-1111-4111-8111-111111111111',
  'sha256': 'a' * 64,
  'author_id': 'author',
  'decision': null,
  'published_at': null,
};

void main() {
  test(
    'durable attempt persists before dispatch and resolves only exact receipt',
    () async {
      final journal = EditorialJournal(store: OidcMemoryStore());
      var calls = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((_) async {
          calls++;
          expect(
            await journal.pending(
              subject: 'reviewer',
              issuer: 'issuer',
              origin: 'origin',
            ),
            hasLength(1),
          );
          return http.Response(
            '{"document_id":"11111111-1111-4111-8111-111111111111"}',
            200,
          );
        }),
      );
      final cmd = editorialDecision(
        resource: 'documents',
        revision: revision(),
        action: 'approved',
        permissions: {'documents.approve'},
        subject: 'reviewer',
      );
      final invalid = EditorialDecisionAttempt.durable(
        cmd,
        journal: journal,
        subject: '',
        issuer: 'issuer',
        origin: 'origin',
      );
      await expectLater(invalid.submit(api), throwsStateError);
      expect(calls, 0);
      final valid = EditorialDecisionAttempt.durable(
        cmd,
        journal: journal,
        subject: 'reviewer',
        issuer: 'issuer',
        origin: 'origin',
      );
      await valid.submit(api);
      expect(calls, 1);
      expect(valid.resolved, isTrue);
      expect(
        await journal.pending(
          subject: 'reviewer',
          issuer: 'issuer',
          origin: 'origin',
        ),
        isEmpty,
      );
    },
  );

  test(
    'review binds exact revision with fresh UUID; self approval forbidden',
    () {
      final source = revision();
      final command = editorialDecision(
        resource: 'documents',
        revision: source,
        action: 'approved',
        permissions: {'documents.approve'},
        subject: 'reviewer',
      );
      source['sha256'] = 'b' * 64;
      final body = jsonDecode(command.encodedBody);
      expect(body['sha256'], 'a' * 64);
      expect(
        body['event_id'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(
        body.keys,
        unorderedEquals(['event_id', 'document_id', 'sha256', 'decision']),
      );
      expect(
        () => editorialDecision(
          resource: 'documents',
          revision: revision(),
          action: 'approved',
          permissions: {'documents.approve'},
          subject: 'author',
        ),
        throwsStateError,
      );
    },
  );

  test('publication requires prior approval and its own permission', () {
    for (final decision in [null, 'rejected']) {
      expect(
        () => editorialDecision(
          resource: 'assessments',
          revision: {...revision(), 'decision': decision},
          action: 'publish',
          permissions: {'documents.publish'},
          subject: 'legal',
        ),
        throwsStateError,
      );
    }
    final approved = {...revision(), 'decision': 'approved'};
    expect(
      () => editorialDecision(
        resource: 'assessments',
        revision: approved,
        action: 'publish',
        permissions: {'documents.approve'},
        subject: 'legal',
      ),
      throwsStateError,
    );
    final result = editorialDecision(
      resource: 'assessments',
      revision: approved,
      action: 'publish',
      permissions: {'documents.publish'},
      subject: 'legal',
    );
    expect(result.path, '/api/admin/staff/assessments/publications');
    expect(jsonDecode(result.encodedBody)['definition_id'], approved['id']);
    expect(jsonDecode(result.encodedBody).containsKey('decision'), isFalse);
  });

  test('expired retry cannot resolve an earlier uncertain commit', () async {
    var calls = 0;
    final bodies = <String>[];
    final api = EditorialApi(
      session: StaffFixture(),
      origin: Uri.parse('https://rac.test'),
      client: MockClient((request) async {
        bodies.add(request.body);
        calls++;
        return http.Response(
          calls == 3
              ? '{"document_id":"11111111-1111-4111-8111-111111111111"}'
              : '{}',
          calls == 1
              ? 503
              : calls == 2
              ? 401
              : 200,
        );
      }),
    );
    final attempt = EditorialDecisionAttempt(
      editorialDecision(
        resource: 'documents',
        revision: revision(),
        action: 'approved',
        permissions: {'documents.approve'},
        subject: 'reviewer',
      ),
    );
    await expectLater(attempt.submit(api), throwsA(isA<EditorialFailure>()));
    expect(attempt.uncertain, isTrue);
    await expectLater(attempt.submit(api), throwsA(isA<EditorialFailure>()));
    expect(attempt.uncertain, isTrue);
    expect(attempt.resolved, isFalse);
    await attempt.submit(api);
    expect(attempt.resolved, isTrue);
    expect(bodies.toSet(), hasLength(1));
    await expectLater(attempt.submit(api), throwsStateError);
    expect(calls, 3);
  });
}
