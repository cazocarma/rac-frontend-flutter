import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/documents_api.dart';
import 'documents_screen.dart';

class DocumentHistoryScreen extends StatefulWidget {
  const DocumentHistoryScreen({super.key, this.api});
  final DocumentsApi? api;
  @override
  State<DocumentHistoryScreen> createState() => _DocumentHistoryScreenState();
}

class _DocumentHistoryScreenState extends State<DocumentHistoryScreen> {
  late final api = widget.api ?? DocumentsApi(Env.apiBase);
  final items = <DocumentAcceptance>[];
  String? cursor;
  bool busy = false, loaded = false, failed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (busy) return;
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      final page = await api.history(cursor: cursor);
      if (!mounted) return;
      final ids = items.map((e) => e.document.id).toSet();
      if ((page.nextCursor != null && page.nextCursor == cursor) ||
          page.items.any((e) => ids.contains(e.document.id))) {
        throw const FormatException('History page did not advance');
      }
      setState(() {
        items.addAll(page.items);
        cursor = page.nextCursor;
        loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.documentHistoryTitle)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loaded && items.isEmpty) Text(strings.documentHistoryEmpty),
              for (final entry in items)
                Card(
                  child: ListTile(
                    title: Text(
                      '${entry.document.title} · ${entry.document.version}',
                    ),
                    subtitle: Text(
                      strings.documentHistoryAt(
                        '${DateFormat.yMMMd(strings.localeName).add_Hm().format(entry.document.acceptedAt!.toLocal())} ${entry.document.acceptedAt!.toLocal().timeZoneName}',
                        switch (entry.context) {
                          'account' => strings.documentHistoryAccount,
                          'compa_onboarding' =>
                            strings.documentHistoryOnboarding,
                          _ => strings.documentHistoryBooking,
                        },
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DocumentReader(api: api, metadata: entry.document),
                      ),
                    ),
                  ),
                ),
              if (busy) const Center(child: CircularProgressIndicator()),
              if (failed) ...[
                Text(strings.documentHistoryFailed),
                OutlinedButton(
                  onPressed: busy ? null : load,
                  child: Text(strings.documentHistoryRetry),
                ),
              ] else if (loaded && cursor != null)
                OutlinedButton(
                  onPressed: busy ? null : load,
                  child: Text(strings.documentHistoryMore),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
