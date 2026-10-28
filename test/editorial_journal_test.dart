import 'package:flutter_test/flutter_test.dart';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';

EditorialCommand command(int n) => EditorialCommand('documents/reviews', {
  'event_id': '11111111-1111-4111-8111-${n.toString().padLeft(12, '0')}',
  'document_id': '22222222-2222-4222-8222-222222222222',
  'sha256': 'a' * 64,
  'decision': 'approved',
});

void main() {
  test(
    'reload restores exact bodies; distinct pending events cannot overwrite each other',
    () async {
      final store = OidcMemoryStore();
      final original = EditorialJournal(store: store);
      for (final item in [command(1), command(2)]) {
        await original.save(
          command: item,
          subject: 'legal-a',
          issuer: 'issuer-a',
          origin: 'origin-a',
        );
      }
      final restored = EditorialJournal(store: store);
      final pending = await restored.pending(
        subject: 'legal-a',
        issuer: 'issuer-a',
        origin: 'origin-a',
      );
      expect(pending.map((item) => item.encodedBody).toSet(), {
        command(1).encodedBody,
        command(2).encodedBody,
      });
      expect(
        await store.getAllKeys(
          OidcStoreNamespace.session,
          managerId: EditorialJournal.manager,
        ),
        isEmpty,
      );
      expect(
        await store.getAllKeys(
          OidcStoreNamespace.secureTokens,
          managerId: 'rac-staff-console',
        ),
        isEmpty,
      );
      await restored.resolve(
        command: command(1),
        subject: 'legal-a',
        issuer: 'issuer-a',
        origin: 'origin-a',
      );
      expect(
        await restored.pending(
          subject: 'legal-a',
          issuer: 'issuer-a',
          origin: 'origin-a',
        ),
        hasLength(1),
      );
    },
  );

  test(
    'reauthentication with a different identity or environment cannot read or remove the command',
    () async {
      final journal = EditorialJournal(store: OidcMemoryStore());
      await journal.save(
        command: command(1),
        subject: 'legal-a',
        issuer: 'issuer-a',
        origin: 'origin-a',
      );
      for (final context in [
        ('legal-b', 'issuer-a', 'origin-a'),
        ('legal-a', 'issuer-b', 'origin-a'),
        ('legal-a', 'issuer-a', 'origin-b'),
      ]) {
        expect(
          await journal.pending(
            subject: context.$1,
            issuer: context.$2,
            origin: context.$3,
          ),
          isEmpty,
        );
        await expectLater(
          journal.resolve(
            command: command(1),
            subject: context.$1,
            issuer: context.$2,
            origin: context.$3,
          ),
          throwsStateError,
        );
      }
      expect(
        await journal.pending(
          subject: 'legal-a',
          issuer: 'issuer-a',
          origin: 'origin-a',
        ),
        hasLength(1),
      );
    },
  );

  test(
    'same event with different payload is rejected without losing original',
    () async {
      final journal = EditorialJournal(store: OidcMemoryStore());
      await journal.save(
        command: command(1),
        subject: 'legal-a',
        issuer: 'issuer-a',
        origin: 'origin-a',
      );
      final changed = EditorialCommand('documents/publications', {
        'event_id': '11111111-1111-4111-8111-000000000001',
        'document_id': 'other',
      });
      await expectLater(
        journal.save(
          command: changed,
          subject: 'legal-a',
          issuer: 'issuer-a',
          origin: 'origin-a',
        ),
        throwsStateError,
      );
      expect(
        (await journal.restore(
          command: command(1),
          subject: 'legal-a',
          issuer: 'issuer-a',
          origin: 'origin-a',
        ))!.encodedBody,
        command(1).encodedBody,
      );
    },
  );

  test('saved body must be canonical and operation allowlisted', () {
    expect(
      () =>
          EditorialCommand.restore('documents/reviews', '{ "event_id": "x" }'),
      throwsFormatException,
    );
    expect(
      () => EditorialCommand.restore('../users', '{"event_id":"x"}'),
      throwsArgumentError,
    );
  });
}
