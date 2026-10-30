import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/chat_api.dart';

const reportStatusCodes = ['abierto', 'atendido', 'desestimado'];
const reportReasonCodes = ['acoso', 'spam', 'contenido_inapropiado', 'otro'];

String? reportStatusLabel(AppLocalizations t, Object? code) => switch (code) {
  'abierto' => t.reportStatusOpen,
  'atendido' => t.reportStatusHandled,
  'desestimado' => t.reportStatusDismissed,
  _ => null,
};

String reportReasonLabel(AppLocalizations t, Object? code) => switch (code) {
  'acoso' => t.reportReasonHarassment,
  'spam' => t.reportReasonSpam,
  'contenido_inapropiado' => t.reportReasonInappropriate,
  'otro' => t.reportReasonOther,
  _ => t.reportReasonGeneric,
};

enum _SafetyFailure { load, change }

class ChatSafetyScreen extends StatefulWidget {
  const ChatSafetyScreen({super.key, required this.bookingId, this.api});
  final String bookingId;
  final ChatApi? api;
  @override
  State<ChatSafetyScreen> createState() => _ChatSafetyScreenState();
}

class _ChatSafetyScreenState extends State<ChatSafetyScreen> {
  late final api = widget.api ?? ChatApi(Env.apiBase);
  Map<String, dynamic>? data;
  String reason = 'acoso';
  final detail = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  _SafetyFailure? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    detail.dispose();
    if (widget.api == null) api.close();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final result = await api.safety(widget.bookingId);
      if (mounted) {
        setState(() {
          data = result;
          error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => error = _SafetyFailure.load);
    }
  }

  Future<void> act(Future<void> Function() operation) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await operation();
      await load();
    } catch (_) {
      if (mounted) setState(() => error = _SafetyFailure.change);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> block() async {
    final t = AppLocalizations.of(context)!;
    final mine = data!['bloqueada_por_mi'] == true;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mine ? t.safetyUnblockTitle : t.safetyBlockTitle),
        content: Text(mine ? t.safetyUnblockMessage : t.safetyBlockMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.safetyBack),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(mine ? t.safetyConfirmUnblock : t.safetyConfirmBlock),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      await act(() async {
        await api.block(widget.bookingId, !mine);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.chatSafety),
        actions: [
          IconButton(
            onPressed: busy ? null : load,
            tooltip: t.safetyRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 720,
        child: ListView(
          children: [
            const Icon(Icons.shield_outlined, size: 44),
            const SizedBox(height: 16),
            Text(
              t.safetyHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(t.safetyIntro),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  error == _SafetyFailure.load
                      ? t.safetyLoadFailed
                      : t.safetyChangeFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (data == null) ...[
              if (error == null)
                const LinearProgressIndicator()
              else
                OutlinedButton(onPressed: load, child: Text(t.safetyRetry)),
            ] else ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data!['bloqueada'] == true
                            ? t.safetyBlocked
                            : t.safetyControl,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data!['bloqueada_por_mi'] == true
                            ? t.safetyOwnBlock
                            : data!['bloqueada'] == true
                            ? t.safetyOtherBlock
                            : t.safetyCanBlock,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: busy ? null : block,
                        icon: const Icon(Icons.block),
                        label: Text(
                          data!['bloqueada_por_mi'] == true
                              ? t.safetyRemoveOwnBlock
                              : t.safetyBlock,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (data!['reportada'] == true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reportStatusLabel(t, data!['estado_reporte']) ??
                              t.reportStatusReceived,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(t.safetyReportPending),
                      ],
                    ),
                  ),
                )
              else
                Form(
                  key: form,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t.safetyReportTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(t.safetyReportNotice),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: reason,
                            decoration: InputDecoration(
                              labelText: t.safetyReason,
                            ),
                            items: [
                              for (final code in reportReasonCodes)
                                DropdownMenuItem(
                                  value: code,
                                  child: Text(reportReasonLabel(t, code)),
                                ),
                            ],
                            onChanged: busy
                                ? null
                                : (value) => setState(() => reason = value!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: detail,
                            enabled: !busy,
                            minLines: 3,
                            maxLines: 6,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              labelText: t.safetyDetail,
                            ),
                            validator: (value) =>
                                (value?.trim().runes.length ?? 0) < 10
                                ? t.safetyDetailTooShort
                                : null,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: busy
                                ? null
                                : () {
                                    if (form.currentState!.validate()) {
                                      act(() async {
                                        await api.report(
                                          widget.bookingId,
                                          reason,
                                          detail.text.trim(),
                                        );
                                        detail.clear();
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.flag_outlined),
                            label: Text(t.safetySendReport),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            Text(t.safetyManualReview),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
