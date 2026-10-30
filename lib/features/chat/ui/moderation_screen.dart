import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/chat_api.dart';
import 'chat_safety_screen.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key, this.api});
  final ChatApi? api;
  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  late final api = widget.api ?? ChatApi(Env.apiBase);
  static const filters = ['abierto', 'atendido', 'desestimado', 'todos'];
  Map<String, dynamic>? data;
  // null: no failure; true: the account is not a moderator.
  bool? forbidden;
  String selectedState = 'abierto';
  final cursors = <String>[''];
  bool loading = false;
  int requestVersion = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  Future<void> load() async {
    final version = ++requestVersion;
    final query = Uri(
      queryParameters: {
        'estado': selectedState,
        if (cursors.last.isNotEmpty) 'despues': cursors.last,
      },
    ).query;
    setState(() {
      loading = true;
      data = null;
      forbidden = null;
    });
    try {
      final result = await api.request('/moderation/reports?$query');
      if (mounted && version == requestVersion) {
        setState(() {
          data = result;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted && version == requestVersion) {
        setState(() {
          loading = false;
          forbidden = e is ChatException && e.status == 403;
        });
      }
    }
  }

  void selectState(String state) {
    if (selectedState == state) return;
    selectedState = state;
    cursors
      ..clear()
      ..add('');
    load();
  }

  String filterLabel(AppLocalizations t, String code) => switch (code) {
    'abierto' => t.moderationFilterOpen,
    'atendido' => t.moderationFilterHandled,
    'desestimado' => t.moderationFilterDismissed,
    _ => t.moderationFilterAll,
  };

  String dateLabel(BuildContext context, dynamic value) {
    final date = value is String ? DateTime.tryParse(value)?.toLocal() : null;
    if (date == null) {
      return AppLocalizations.of(context)!.moderationDateUnavailable;
    }
    final localizations = MaterialLocalizations.of(context);
    String two(int value) => value.toString().padLeft(2, '0');
    final day = '${two(date.day)}/${two(date.month)}/${date.year}';
    return '$day · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: true)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.chatModeration),
        actions: [
          IconButton(
            onPressed: loading
                ? null
                : () {
                    cursors
                      ..clear()
                      ..add('');
                    load();
                  },
            tooltip: t.moderationRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 900,
        child: ListView(
          children: [
            Text(
              selectedState == 'abierto'
                  ? t.moderationPending
                  : t.moderationHistory,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(t.moderationIntro),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in filters)
                  ChoiceChip(
                    label: Text(filterLabel(t, filter)),
                    selected: selectedState == filter,
                    onSelected: (selected) {
                      if (selected) selectState(filter);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(t.moderationOrder),
            const SizedBox(height: 20),
            if (loading) const LinearProgressIndicator(),
            if (forbidden != null) ...[
              Text(forbidden! ? t.moderationForbidden : t.moderationLoadFailed),
              OutlinedButton(onPressed: load, child: Text(t.moderationRetry)),
            ],
            if (data != null) ...[
              if ((data!['items'] as List).isEmpty) Text(t.moderationEmpty),
              for (final item in data!['items'] as List)
                Card(
                  child: ListTile(
                    leading: Icon(
                      item['estado'] == 'abierto'
                          ? Icons.flag_outlined
                          : Icons.task_alt,
                    ),
                    title: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Text(reportReasonLabel(t, item['motivo'])),
                        Chip(
                          label: Text(
                            reportStatusLabel(t, item['estado']) ??
                                t.moderationStatusUnavailable,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.moderationCaseRef(
                            (item['id'] as String).substring(0, 8),
                            (item['sesion_id'] as String).substring(0, 8),
                          ),
                        ),
                        Text(
                          t.moderationReported(
                            dateLabel(context, item['creado_en']),
                          ),
                        ),
                        if (item['estado'] != 'abierto') ...[
                          Text(
                            t.moderationClosedAt(
                              dateLabel(context, item['resuelto_en']),
                            ),
                          ),
                          Text(t.moderationClosedNote),
                        ],
                      ],
                    ),
                    trailing: item['estado'] == 'abierto'
                        ? const Icon(Icons.chevron_right)
                        : null,
                    onTap: item['estado'] == 'abierto'
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ModerationCaseScreen(
                                  id: item['id'] as String,
                                ),
                              ),
                            );
                            if (mounted) await load();
                          }
                        : null,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(t.moderationPage(cursors.length)),
                if (cursors.length > 1)
                  OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                            cursors.removeLast();
                            load();
                          },
                    child: Text(t.moderationPrevious),
                  ),
                if (data?['has_more'] == true &&
                    (data?['next_cursor'] as String? ?? '').isNotEmpty)
                  OutlinedButton(
                    onPressed: loading
                        ? null
                        : () {
                            cursors.add(data!['next_cursor'] as String);
                            load();
                          },
                    child: Text(t.moderationNext),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ModerationCaseScreen extends StatefulWidget {
  const ModerationCaseScreen({super.key, required this.id, this.api});
  final String id;
  final ChatApi? api;
  @override
  State<ModerationCaseScreen> createState() => _ModerationCaseScreenState();
}

class _ModerationCaseScreenState extends State<ModerationCaseScreen> {
  late final api = widget.api ?? ChatApi(Env.apiBase);
  final justification = TextEditingController();
  final form = GlobalKey<FormState>();
  Map<String, dynamic>? data;
  // null: no failure; true: closing failed; false: access failed.
  bool? closeFailed;
  bool busy = false;
  @override
  void dispose() {
    justification.dispose();
    if (widget.api == null) api.close();
    super.dispose();
  }

  Future<void> access({String before = ''}) async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      closeFailed = null;
    });
    try {
      final result = await api.request(
        '/moderation/reports/${widget.id}/access',
        body: {'justificacion': justification.text.trim(), 'antes': before},
      );
      if (mounted) setState(() => data = result);
    } catch (_) {
      if (mounted) {
        setState(() => closeFailed = false);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resolve(String state) async {
    if (!form.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.moderationCloseTitle),
        content: Text(
          state == 'atendido'
              ? t.moderationCloseHandled
              : t.moderationCloseDismissed,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.moderationBack),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.moderationConfirmClose),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => busy = true);
    try {
      await api.request(
        '/moderation/reports/${widget.id}/resolve',
        body: {'estado': state, 'justificacion': justification.text.trim()},
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => closeFailed = true);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.moderationCaseTitle(widget.id.substring(0, 8))),
      ),
      body: PageContent(
        width: 900,
        child: ListView(
          children: [
            const Icon(Icons.policy_outlined, size: 40),
            const SizedBox(height: 16),
            Text(
              t.moderationHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(t.moderationCaseIntro),
            const SizedBox(height: 20),
            Form(
              key: form,
              child: TextFormField(
                controller: justification,
                enabled: !busy,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: t.moderationJustification,
                ),
                validator: (value) => (value?.trim().runes.length ?? 0) < 10
                    ? t.moderationJustificationTooShort
                    : null,
              ),
            ),
            FilledButton.icon(
              onPressed: busy ? null : () => access(),
              icon: const Icon(Icons.visibility_outlined),
              label: Text(t.moderationAccess),
            ),
            if (busy) const LinearProgressIndicator(),
            if (closeFailed != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  closeFailed!
                      ? t.moderationCloseFailed
                      : t.moderationAccessFailed,
                ),
              ),
            if (data != null) ...[
              const SizedBox(height: 24),
              Text(
                reportReasonLabel(t, data!['motivo']),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Semantics(
                container: true,
                label: data!['detalle'] as String,
                excludeSemantics: true,
                child: SelectableText(data!['detalle'] as String),
              ),
              const Divider(height: 32),
              Text(t.moderationLinkedHistory),
              for (final item in (data!['items'] as List).reversed)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['propio'] == true ? t.moderationReporter : t.moderationOtherPerson} · ${item['enviado_en']}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          container: true,
                          label: item['contenido'] as String,
                          excludeSemantics: true,
                          child: SelectableText(item['contenido'] as String),
                        ),
                      ],
                    ),
                  ),
                ),
              if (data!['has_more'] == true)
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => access(before: data!['before'] as String),
                  child: Text(t.moderationOlder),
                ),
              const Divider(height: 32),
              Text(t.moderationResolveHint),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: busy ? null : () => resolve('atendido'),
                    child: Text(t.moderationMarkHandled),
                  ),
                  OutlinedButton(
                    onPressed: busy ? null : () => resolve('desestimado'),
                    child: Text(t.moderationDismiss),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
