import 'package:flutter/material.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/staff/editorial_draft.dart';

void main() {
  testWidgets(
    'incomplete draft does not dispatch and no fields are preselected',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: EditorialDraft(
                onSubmit: (_) async {
                  calls++;
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Create document draft'));
      await tester.pumpAndSettle();
      for (final dropdown in tester.widgetList<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      )) {
        expect(dropdown.initialValue, isNull);
      }
      expect(
        tester
            .widget<DropdownButtonFormField<bool>>(
              find.byType(DropdownButtonFormField<bool>),
            )
            .initialValue,
        isNull,
      );
      final button = find.widgetWithText(FilledButton, 'Create document draft');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(
        find.text(
          'Check selections, version and text. The limit is 128 KiB of UTF-8 text.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  test(
    'draft hashes exact UTF-8 text including whitespace without caller authority',
    () {
      final command = draftDocument(
        kind: 'privacy',
        version: 'candidate-1',
        locale: 'es',
        content: '  Texto ñ\n',
        materialChange: false,
      );
      final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
      expect(body['content'], '  Texto ñ\n');
      expect(
        body['sha256'],
        '33ac0db591f74946277ee985dc4e28c17b133d120b24869fbf02b4912440ff35',
      );
      expect(body['material_change'], isFalse);
      expect(body['document_id'], isNot(body['event_id']));
      expect(
        body.keys,
        unorderedEquals([
          'event_id',
          'document_id',
          'kind',
          'version',
          'locale',
          'content',
          'material_change',
          'sha256',
        ]),
      );
      expect(command.path, '/api/admin/staff/documents/drafts');
    },
  );

  test('text bound measures bytes rather than characters', () {
    expect(
      () => draftDocument(
        kind: 'privacy',
        version: '1',
        locale: 'es',
        content: 'ñ' * 65536,
        materialChange: true,
      ),
      returnsNormally,
    );
    expect(
      () => draftDocument(
        kind: 'privacy',
        version: '1',
        locale: 'es',
        content: 'ñ' * 65537,
        materialChange: true,
      ),
      throwsFormatException,
    );
    for (final content in ['', ' \n', 'text\u0000']) {
      expect(
        () => draftDocument(
          kind: 'privacy',
          version: '1',
          locale: 'es',
          content: content,
          materialChange: true,
        ),
        throwsFormatException,
      );
    }
  });

  test('unknown document kind, locale or ambiguous version are rejected', () {
    for (final values in [
      ('terms', '1', 'es'),
      ('privacy', '../v1', 'es'),
      ('privacy', '1', 'unknown'),
    ]) {
      expect(
        () => draftDocument(
          kind: values.$1,
          version: values.$2,
          locale: values.$3,
          content: 'synthetic',
          materialChange: true,
        ),
        throwsFormatException,
      );
    }
  });
}
