import 'document_title.dart';
import 'document_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/brand.dart';
import '../data/documents_api.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.api});
  final DocumentsApi? api;
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  AppLocalizations get t => AppLocalizations.of(context)!;
  late final api = widget.api ?? DocumentsApi(Env.apiBase);
  late Future<List<LegalDocument>> data = api.documents();
  void reload() {
    if (!mounted) return;
    final next = api.documents();
    setState(() {
      data = next;
    });
  }

  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(t.settingsDocuments),
      actions: [
        IconButton(
          tooltip: AppLocalizations.of(context)!.documentHistoryTitle,
          onPressed: () => Navigator.of(context).pushNamed('/document-history'),
          icon: const Icon(Icons.history),
        ),
      ],
    ),
    body: FutureBuilder<List<LegalDocument>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(
            title: t.documentsLoadFailed,
            message: t.documentsRetryLater,
            action: FilledButton(
              onPressed: reload,
              child: Text(t.documentsRetry),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return EmptyState(
            title: t.commonConstruction,
            icon: Icons.description_outlined,
            message: t.documentsPendingReview,
          );
        }
        return SingleChildScrollView(
          child: PageContent(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageIntro(
                  eyebrow: t.documentsAccount,
                  title: t.documentsHeading,
                  description: t.documentsDescription,
                ),
                for (final item in items)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        item.acceptedAt == null
                            ? Icons.description_outlined
                            : Icons.verified_outlined,
                      ),
                      title: Text(item.localizedTitle(t)),
                      subtitle: Text(
                        t.documentsVersionStatus(
                          item.version,
                          item.acceptedAt == null
                              ? t.documentsNotAccepted
                              : t.documentsAccepted,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                DocumentReader(api: api, metadata: item),
                          ),
                        );
                        reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class DocumentReader extends StatefulWidget {
  const DocumentReader({super.key, required this.api, required this.metadata});
  final DocumentsApi api;
  final LegalDocument metadata;
  @override
  State<DocumentReader> createState() => _DocumentReaderState();
}

class _DocumentReaderState extends State<DocumentReader> {
  AppLocalizations get t => AppLocalizations.of(context)!;
  late Future<LegalDocument> data = widget.api.document(widget.metadata.id);
  bool checked = false, busy = false, stale = false;
  String? error;
  void retry() {
    final next = widget.api.document(widget.metadata.id);
    setState(() {
      data = next;
    });
  }

  Future<void> accept(LegalDocument item) async {
    if (!checked || busy || stale) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.accept(item, registry: widget.metadata.registry);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          stale = e is ApiException && e.status == 409;
          if (stale) checked = false;
          error = stale ? t.readerDocumentsChanged : t.documentsAcceptFailed;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.metadata.localizedTitle(t))),
    body: FutureBuilder<LegalDocument>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data;
        if (snapshot.hasError ||
            item == null ||
            item.content == null ||
            item.id != widget.metadata.id ||
            item.sha256 != widget.metadata.sha256 ||
            item.kind != widget.metadata.kind ||
            item.version != widget.metadata.version ||
            (widget.metadata.locale != null &&
                item.locale != widget.metadata.locale)) {
          return EmptyState(
            title: t.documentsOpenFailed,
            message: t.documentsReturnRefresh,
            action: OutlinedButton(
              onPressed: retry,
              child: Text(t.documentsRetry),
            ),
          );
        }
        return SingleChildScrollView(
          child: PageContent(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.documentVersion(item.version),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 20),
                DocumentText(item.content!),
                const SizedBox(height: 28),
                if (widget.metadata.acceptedAt != null)
                  Text(t.documentsAlreadyAccepted)
                else ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: checked,
                    onChanged: busy || stale
                        ? null
                        : (value) => setState(() => checked = value ?? false),
                    title: Text(t.documentsConsent),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: checked && !busy && !stale
                        ? () => accept(item)
                        : null,
                    child: Text(busy ? t.savingConsent : t.documentsConfirm),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
