import 'package:flutter/material.dart';

/// Flutter web's selectable text can paint its contents without exposing them
/// to the browser accessibility tree. Keep selection and provide one readable
/// semantic label for the complete immutable document.
class DocumentText extends StatelessWidget {
  const DocumentText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    label: text,
    child: ExcludeSemantics(child: SelectableText(text)),
  );
}
