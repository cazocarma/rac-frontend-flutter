import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/shared/widgets/reviews.dart';
import 'package:rentacompa/shared/widgets/design.dart';

void main() {
  testWidgets(
    'review requires stars, retains edits after failure and retries on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var calls = 0;
      var selected = 0;
      var saved = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: racTheme(Brightness.light),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => ReviewDialog(
                    submit: (score, comment) async {
                      calls++;
                      selected = score;
                      saved = comment;
                      if (calls == 1) throw StateError('offline');
                    },
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Publicar reseña'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('5 ★'));
      await tester.enterText(find.byType(TextField), 'Una experiencia genial');
      await tester.ensureVisible(find.text('Publicar reseña'));
      await tester.tap(find.text('Publicar reseña'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No pudimos confirmar'), findsOneWidget);
      expect(find.text('Una experiencia genial'), findsOneWidget);
      await tester.tap(find.text('Publicar reseña'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(selected, 5);
      expect(saved, 'Una experiencia genial');
      expect(find.byType(ReviewDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
