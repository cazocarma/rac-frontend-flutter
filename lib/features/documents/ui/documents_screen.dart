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
      title: const Text('Documentos y acuerdos'),
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
            title: 'No pudimos cargar los documentos',
            message: 'Inténtalo otra vez en unos momentos.',
            action: FilledButton(
              onPressed: reload,
              child: const Text('Reintentar'),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const EmptyState(
            title: 'En construcción',
            icon: Icons.description_outlined,
            message:
                'Los documentos estarán disponibles cuando termine su revisión.',
          );
        }
        return SingleChildScrollView(
          child: PageContent(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageIntro(
                  eyebrow: 'Tu cuenta',
                  title: 'Información y acuerdos',
                  description:
                      'Consulta cada versión y revisa cuáles has aceptado.',
                ),
                for (final item in items)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        item.acceptedAt == null
                            ? Icons.description_outlined
                            : Icons.verified_outlined,
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        'Versión ${item.version} · ${item.acceptedAt == null ? 'Sin aceptar' : 'Aceptada'}',
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
          error = stale
              ? 'Los documentos cambiaron. Vuelve a la lista para actualizarlos.'
              : 'No pudimos confirmar la aceptación. Puedes reintentar.';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.metadata.title)),
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
            item.sha256 != widget.metadata.sha256) {
          return EmptyState(
            title: 'No pudimos abrir esta versión',
            message:
                'Vuelve a intentarlo o regresa a la lista para actualizarla.',
            action: OutlinedButton(
              onPressed: retry,
              child: const Text('Reintentar'),
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
                  'Versión ${item.version}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 20),
                SelectableText(item.content!),
                const SizedBox(height: 28),
                if (widget.metadata.acceptedAt != null)
                  const Text('Ya aceptaste esta versión.')
                else ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: checked,
                    onChanged: busy || stale
                        ? null
                        : (value) => setState(() => checked = value ?? false),
                    title: const Text('Acepto esta versión del documento.'),
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
                    child: Text(busy ? 'Guardando…' : 'Confirmar aceptación'),
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
