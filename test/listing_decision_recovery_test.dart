import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_decision.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';

import 'editorial_api_test.dart' show StaffFixture;

const revisionId = '11111111-1111-4111-8111-111111111111';
const issuer = 'https://issuer.example/realms/rac';
const origin = 'https://rac.test';

EditorialCommand command() =>
    EditorialCommand('listings/revisions/$revisionId/photo-approval', {
      'event_id': '22222222-2222-4222-8222-222222222222',
      'expected_version': '9007199254740993',
      'sha256': 'a' * 64,
    });

void main() {
  test(
    'MFA response survives restart with the exact event and 64-bit version',
    () async {
      final store = OidcMemoryStore();
      final session = StaffFixture();
      final bodies = <String>[];
      final journal = EditorialJournal(store: store, managerId: 'listing-test');
      var calls = 0;
      final api = EditorialApi(
        session: session,
        origin: Uri.parse(origin),
        client: MockClient((request) async {
          bodies.add(request.body);
          expect(
            await journal.pending(
              subject: session.subject,
              issuer: issuer,
              origin: origin,
            ),
            hasLength(1),
          );
          calls++;
          if (calls == 1)
            return http.Response('{"error":"staff_step_up_required"}', 403);
          return http.Response(
            jsonEncode({
              'event_id': jsonDecode(request.body)['event_id'],
              'revision_id': revisionId,
              'decision': 'approved',
              'listing_version': '9007199254740994',
            }),
            200,
          );
        }),
      );
      final first = EditorialDecisionAttempt.durable(
        command(),
        journal: journal,
        subject: session.subject,
        issuer: issuer,
        origin: origin,
      );
      await expectLater(
        first.submit(api),
        throwsA(
          isA<EditorialFailure>().having(
            (e) => e.authenticationRequired,
            'MFA',
            true,
          ),
        ),
      );
      expect(first.uncertain, isTrue);
      final restarted = EditorialJournal(
        store: store,
        managerId: 'listing-test',
      );
      final pending = await restarted.pending(
        subject: session.subject,
        issuer: issuer,
        origin: origin,
      );
      expect(pending, hasLength(1));
      expect(
        await EditorialJournal(
          store: store,
        ).pending(subject: session.subject, issuer: issuer, origin: origin),
        isEmpty,
      );
      expect(
        await restarted.pending(
          subject: 'other',
          issuer: issuer,
          origin: origin,
        ),
        isEmpty,
      );
      final retry = EditorialDecisionAttempt.durable(
        pending.single,
        journal: restarted,
        subject: session.subject,
        issuer: issuer,
        origin: origin,
        recovered: true,
      );
      await retry.submit(api);
      expect(retry.resolved, isTrue);
      expect(bodies.toSet(), hasLength(1));
      expect(
        await restarted.pending(
          subject: session.subject,
          issuer: issuer,
          origin: origin,
        ),
        isEmpty,
      );
    },
  );

  test(
    'account change before dispatch sends nothing; change after dispatch preserves recovery',
    () async {
      for (final before in [true, false]) {
        final session = StaffFixture();
        final owner = session.subject;
        final journal = EditorialJournal(store: OidcMemoryStore());
        var calls = 0;
        final api = EditorialApi(
          session: session,
          origin: Uri.parse(origin),
          client: MockClient((_) async {
            calls++;
            session.subject = 'other';
            return http.Response('{}', 200);
          }),
        );
        final attempt = EditorialDecisionAttempt.durable(
          command(),
          journal: journal,
          subject: owner,
          issuer: issuer,
          origin: origin,
        );
        if (before) session.subject = 'other';
        await expectLater(
          attempt.submit(api),
          throwsA(isA<EditorialFailure>()),
        );
        expect(calls, before ? 0 : 1);
        expect(attempt.resolved, isFalse);
        expect(
          await journal.pending(subject: owner, issuer: issuer, origin: origin),
          hasLength(1),
        );
        expect(
          await journal.pending(
            subject: 'other',
            issuer: issuer,
            origin: origin,
          ),
          isEmpty,
        );
      }
    },
  );

  test(
    'listing commands reject extra fields, invalid versions and alternate routes',
    () {
      final body = jsonDecode(command().encodedBody) as Map<String, dynamic>;
      for (final version in ['01', '-1', '9223372036854775807', 1]) {
        expect(
          () => EditorialCommand('listings/revisions/$revisionId/approval', {
            ...body,
            'expected_version': version,
          }),
          throwsArgumentError,
        );
      }
      expect(
        () => EditorialCommand('listings/revisions/$revisionId/approval', {
          ...body,
          'actor': 'forged',
        }),
        throwsArgumentError,
      );
      expect(
        () => EditorialCommand('listings/revisions/$revisionId/delete', body),
        throwsArgumentError,
      );
    },
  );
}
