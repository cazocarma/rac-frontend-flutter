import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/widgets/design.dart';

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'construction screen $locale $width is localized, neutral and returns',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          String? message;
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ConstructionScreen(
                        title: 'Section',
                        message: message,
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(ConstructionScreen)),
          )!;
          expect(find.text('Section'), findsOneWidget);
          expect(find.text(t.commonConstruction), findsOneWidget);
          expect(find.text(t.constructionDescription), findsOneWidget);
          expect(find.textContaining('Pronto'), findsNothing);
          expect(find.textContaining('soon'), findsNothing);
          expect(
            find.text('Volver'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          await tester.tap(find.text(t.constructionBack));
          await tester.pumpAndSettle();
          expect(find.byType(ConstructionScreen), findsNothing);
          expect(find.text('open'), findsOneWidget);
          message = 'custom message';
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(find.text('custom message'), findsOneWidget);
          expect(find.text(t.constructionDescription), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
