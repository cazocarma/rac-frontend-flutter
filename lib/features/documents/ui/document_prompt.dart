import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/pending_documents.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../data/documents_api.dart';

class DocumentPrompt extends StatefulWidget {
  const DocumentPrompt({super.key, required this.pending, required this.api});
  final DocumentPrecondition pending;
  final DocumentsApi api;
  @override
  State<DocumentPrompt> createState() => _DocumentPromptState();
}

class _DocumentPromptState extends State<DocumentPrompt> {
  late final Future<(DocumentRegistry, List<LegalDocument>)> data = load();
  final opened = <String>{};
  bool checked = false, busy = false, stale = false;
  String? error;

  Future<(DocumentRegistry, List<LegalDocument>)> load() async {
    final collection = await widget.api.collection();
    final registry = collection.registry;
    if (registry == null) throw StateError('Active registry required');
    final selected = <LegalDocument>[];
    for (final pending in widget.pending.documents) {
      final matches = collection.items
          .where(
            (d) =>
                d.id == pending.id &&
                d.kind == pending.kind &&
                d.sha256 == pending.sha256,
          )
          .toList();
      if (matches.length != 1) throw StateError('Registry changed');
      selected.add(matches.single);
    }
    return (registry, selected);
  }

  Future<void> read(LegalDocument metadata) async {
    final strings = AppLocalizations.of(context)!;
    try {
      final exact = await widget.api.document(metadata.id);
      if (!mounted) return;
      if (exact.id != metadata.id ||
          exact.sha256 != metadata.sha256 ||
          exact.kind != metadata.kind ||
          exact.content == null) {
        throw StateError('Document changed');
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(metadata.title),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(child: SelectableText(exact.content!)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.readDone),
            ),
          ],
        ),
      );
      if (mounted && confirmed == true) setState(() => opened.add(metadata.id));
    } catch (_) {
      if (mounted) setState(() => error = strings.documentReadFailed);
    }
  }

  Future<void> accept(
    DocumentRegistry registry,
    List<LegalDocument> documents,
  ) async {
    if (!checked || busy || stale || opened.length != documents.length) return;
    final strings = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.acceptBatch(documents, registry);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          stale = e is ApiException && e.status == 409;
          if (stale) checked = false;
          error = stale ? strings.documentsChanged : strings.consentFailed;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.updatedRules)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.readDocuments),
              const SizedBox(height: 20),
              FutureBuilder<(DocumentRegistry, List<LegalDocument>)>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(strings.documentsUnavailable);
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final (registry, documents) = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final point in registry.summary)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $point'),
                        ),
                      for (final document in documents)
                        Card(
                          child: ListTile(
                            title: Text(document.title),
                            subtitle: Text(
                              strings.pendingVersion(document.version),
                            ),
                            trailing: Icon(
                              opened.contains(document.id)
                                  ? Icons.check_circle_outline
                                  : Icons.description_outlined,
                            ),
                            onTap: busy || stale ? null : () => read(document),
                          ),
                        ),
                      Text(strings.readFullText),
                      CheckboxListTile(
                        value: checked,
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.explicitConsent),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged:
                            busy || stale || opened.length != documents.length
                            ? null
                            : (value) =>
                                  setState(() => checked = value ?? false),
                      ),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      FilledButton(
                        onPressed: checked && !busy && !stale
                            ? () => accept(registry, documents)
                            : null,
                        child: Text(
                          busy ? strings.savingConsent : strings.acceptContinue,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.backToAction),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DocumentPrivacyEscape(),
                  ),
                ),
                child: Text(strings.privacyEscape),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accessible independently of consent. The P12 request workflow is not yet
/// implemented; do not imply an export/deletion request has been submitted.
class DocumentPrivacyEscape extends StatelessWidget {
  const DocumentPrivacyEscape({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.privacyTitle)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.privacyPending),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                child: Text(strings.viewProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
