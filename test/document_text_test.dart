import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/documents/ui/document_text.dart';

void main() {
  testWidgets(
    'complete document is readable to accessibility and remains selectable',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        const content =
            'Documento sintético completo.\nSegunda línea que también debe poder leerse.';
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: DocumentText(content))),
        );
        expect(find.bySemanticsLabel(content), findsOneWidget);
        expect(find.byType(SelectableText), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
