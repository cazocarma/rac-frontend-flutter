import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/documents/ui/documents_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'documents_test.dart' show FakeDocuments;
import 'package:rentacompa/features/documents/data/documents_api.dart';

class MismatchedDocuments extends FakeDocuments {
  MismatchedDocuments(this.mutation);
  final String mutation;
  @override
  LegalDocument item({bool detail = false}) {
    final base = super.item(detail: detail);
    return LegalDocument(
      id: base.id,
      kind: detail && mutation == 'kind' ? 'privacy' : base.kind,
      version: detail && mutation == 'version' ? 'other-version' : base.version,
      locale: detail && mutation == 'locale' ? 'en' : 'es',
      sha256: base.sha256,
      content: base.content,
      acceptedAt: base.acceptedAt,
    );
  }
}

void main() {
  for (final mutation in ['kind', 'version', 'locale']) {
    testWidgets(
      'reader rejects mismatched $mutation even with same ID and content hash',
      (tester) async {
        final api = MismatchedDocuments(mutation);
        addTearDown(api.close);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DocumentsScreen(api: api),
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(DocumentsScreen)),
        )!;
        await tester.tap(find.text(t.documentTermsClient));
        await tester.pumpAndSettle();
        expect(find.text(t.documentsOpenFailed), findsOneWidget);
        expect(find.byType(CheckboxListTile), findsNothing);
        expect(api.calls, 0);
      },
    );
  }
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      for (final conflict in [false, true]) {
        testWidgets(
          'document $locale $width conflict=$conflict preserves exact content and explicit consent',
          (tester) async {
            tester.view.physicalSize = Size(width, 900);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final api = FakeDocuments()..conflict = conflict;
            addTearDown(api.close);
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: DocumentsScreen(api: api),
              ),
            );
            await tester.pumpAndSettle();
            final t = AppLocalizations.of(
              tester.element(find.byType(DocumentsScreen)),
            )!;
            await tester.tap(find.text(t.documentTermsClient));
            await tester.pumpAndSettle();
            expect(find.text(api.item(detail: true).content!), findsOneWidget);
            final confirm = find.widgetWithText(
              FilledButton,
              t.documentsConfirm,
            );
            expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
            expect(api.calls, 0);
            await tester.tap(find.byType(CheckboxListTile));
            await tester.pumpAndSettle();
            await tester.ensureVisible(confirm);
            await tester.tap(confirm);
            await tester.pumpAndSettle();
            expect(api.calls, 1);
            if (conflict) {
              expect(find.text(t.readerDocumentsChanged), findsOneWidget);
              expect(
                tester
                    .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                    .value,
                isFalse,
              );
              expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
            } else {
              expect(
                find.text(
                  t.documentsVersionStatus('fixture-1', t.documentsAccepted),
                ),
                findsOneWidget,
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
