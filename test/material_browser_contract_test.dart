import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

void main() {
  for (final language in ['es', 'en']) {
    testWidgets('Material browser labels and counter follow $language', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      try {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TextField(controller: controller, maxLength: 2000),
            ),
          ),
        );
        final labels = MaterialLocalizations.of(
          tester.element(find.byType(TextField)),
        );
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(labels.remainingTextFieldCharacterCount(2000)),
          findsWidgets,
        );
        await tester.enterText(find.byType(TextField), 'hello');
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(labels.remainingTextFieldCharacterCount(1995)),
          findsWidgets,
        );
        controller.clear();
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(labels.remainingTextFieldCharacterCount(2000)),
          findsWidgets,
        );
        debugPrint(
          'MATERIAL_LABELS_JSON:${jsonEncode({
            'locale': language,
            'back': labels.backButtonTooltip,
            'open_navigation': labels.openAppDrawerTooltip,
            'remaining': {
              for (final count in [0, 1, 1995, 2000]) '$count': labels.remainingTextFieldCharacterCount(count),
            },
          })}',
          wrapWidth: 100000,
        );
      } finally {
        semantics.dispose();
      }
    });
  }
}
