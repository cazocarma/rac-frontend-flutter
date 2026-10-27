import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/pending_documents.dart';
import '../data/documents_api.dart';
import 'document_prompt.dart';

class DocumentPromptHost extends StatefulWidget {
  const DocumentPromptHost({
    super.key,
    required this.navigatorKey,
    required this.child,
    this.events,
    this.createApi,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  final Stream<DocumentPrecondition>? events;
  final DocumentsApi Function()? createApi;
  @override
  State<DocumentPromptHost> createState() => _DocumentPromptHostState();
}

class _DocumentPromptHostState extends State<DocumentPromptHost> {
  late final StreamSubscription<DocumentPrecondition> subscription;
  bool showing = false;
  @override
  void initState() {
    super.initState();
    subscription = (widget.events ?? DocumentPreconditions.events).listen(open);
  }

  Future<void> open(DocumentPrecondition pending) async {
    if (!mounted || showing) return;
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;
    showing = true;
    final api = widget.createApi?.call() ?? DocumentsApi(Env.apiBase);
    try {
      await navigator.push<bool>(
        MaterialPageRoute(
          builder: (_) => DocumentPrompt(pending: pending, api: api),
        ),
      );
    } finally {
      api.close();
      showing = false;
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
