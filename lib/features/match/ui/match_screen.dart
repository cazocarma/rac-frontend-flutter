import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../chat/ui/chat_screen.dart';
import 'package:rentacompa/shared/widgets/reviews.dart';
import '../data/match_api.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/widgets/design.dart';
import 'package:rentacompa/shared/widgets/weekly_allowance.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, this.api, this.users});
  final MatchApi? api;
  final UserApi? users;
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<List<List<dynamic>>> data;
  bool provider = false;
  final busy = <String>{};
  bool actionFailed = false;
  MatchApi get api => widget.api ?? Services.match;
  UserApi get users => widget.users ?? Services.user;
  @override
  void initState() {
    super.initState();
    data = load();
  }

  Future<List<List<dynamic>>> load() async {
    final me = await users.me();
    final role = await Session.role();
    provider = role == 'compa' || role == 'admin';
    final bought = await api.listClient(me['id'] as String, limit: 100);
    final received = provider
        ? await api.listCompa(me['id'] as String, limit: 100)
        : <String, dynamic>{};
    return [(bought['items'] ?? []) as List, (received['items'] ?? []) as List];
  }

  void reload() => setState(() {
    data = load();
  });

  String statusLabel(AppLocalizations t, String state) => switch (state) {
    'pendiente' => t.bookingsStatusPending,
    'activa' => t.bookingsStatusActive,
    'cancelada' => t.bookingsStatusCancelled,
    'expirada' => t.bookingsStatusExpired,
    'finalizada' => t.bookingsStatusFinished,
    _ => t.bookingsStatusUnknown,
  };

  Future<void> transition(String id, String state) async {
    if (busy.contains(id)) return;
    final t = AppLocalizations.of(context)!;
    if (state == 'cancelada') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(t.bookingsCancelTitle),
          content: Text(t.bookingsCancelMessage),
          actions: [
            FutureBuilder<String>(
              future: Session.role(),
              builder: (context, snapshot) =>
                  snapshot.data == 'compa' || snapshot.data == 'admin'
                  ? IconButton(
                      tooltip: t.bookingsTimeOff,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/time-off'),
                      icon: const Icon(Icons.event_busy_outlined),
                    )
                  : const SizedBox.shrink(),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(t.bookingsKeep),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(t.bookingsConfirmCancel),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      busy.add(id);
      actionFailed = false;
    });
    try {
      await api.updateState(id, state);
      if (mounted) reload();
    } on SubscriptionRequired catch (e) {
      if (!mounted) return;
      final showPlans = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(t.bookingsLimitTitle),
          content: Text(
            t.bookingsLimitMessage(
              '${e.allowance['usados']}',
              '${e.allowance['semana_inicio']}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(t.bookingsLimitOk),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(t.bookingsLimitPlans),
            ),
          ],
        ),
      );
      if (mounted && showPlans == true) {
        await Navigator.of(context).pushNamed('/payments');
      }
    } catch (_) {
      if (mounted) setState(() => actionFailed = true);
    } finally {
      if (mounted) setState(() => busy.remove(id));
    }
  }

  Widget list(List<dynamic> items, bool received) {
    final t = AppLocalizations.of(context)!;
    return items.isEmpty
        ? EmptyState(
            title: received
                ? t.bookingsEmptyReceivedTitle
                : t.bookingsEmptyTitle,
            message: received
                ? t.bookingsEmptyReceivedMessage
                : t.bookingsEmptyMessage,
            icon: Icons.calendar_month_outlined,
            action: received
                ? null
                : OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/home', (_) => false),
                    child: Text(t.bookingsExplore),
                  ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = items[i] as Map;
              final state = item['estado'] as String;
              final id = item['id'] as String;
              final date = DateTime.parse(
                item['fecha_inicio'] as String,
              ).toLocal();
              final end = DateTime.parse(item['fecha_fin'] as String).toLocal();
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(Icons.event_outlined),
                          Text(
                            dateLabel(date),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Chip(
                            backgroundColor: state == 'activa'
                                ? Theme.of(context).colorScheme.primaryContainer
                                : state == 'pendiente'
                                ? Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            side: BorderSide.none,
                            label: Text(statusLabel(t, state)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${clockLabel(date)} → ${dateLabel(end)} ${clockLabel(end)}',
                      ),
                      const SizedBox(height: 8),
                      Text(t.bookingsNoCharge),
                      Text(
                        t.bookingsReference(
                          id.substring(0, 8),
                          received
                              ? t.bookingsRoleReceived
                              : t.bookingsRoleHired,
                        ),
                      ),
                      if (state != 'pendiente')
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ChatConversationScreen(bookingId: id),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: Text(t.bookingsOpenChat),
                        ),
                      if (state == 'finalizada' &&
                          !received &&
                          end.isAfter(DateTime.now()))
                        Text(t.bookingsReviewLater),
                      if (state == 'finalizada')
                        BookingReview(
                          key: ValueKey(id),
                          id: id,
                          canWrite: !received && !end.isAfter(DateTime.now()),
                          api: widget.users,
                        ),
                      if (state == 'pendiente' || state == 'activa')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (received && state == 'pendiente')
                                FilledButton(
                                  onPressed: busy.contains(id)
                                      ? null
                                      : () => transition(id, 'activa'),
                                  child: Text(t.bookingsAccept),
                                ),
                              if (state == 'activa' &&
                                  !date.isAfter(DateTime.now()))
                                OutlinedButton(
                                  onPressed: busy.contains(id)
                                      ? null
                                      : () => transition(id, 'finalizada'),
                                  child: Text(t.bookingsFinish),
                                ),
                              TextButton(
                                onPressed: busy.contains(id)
                                    ? null
                                    : () => transition(id, 'cancelada'),
                                child: Text(
                                  busy.contains(id)
                                      ? t.bookingsUpdating
                                      : t.bookingsCancel,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.bookingsTitle),
        actions: [
          IconButton(
            tooltip: t.bookingsRefresh,
            onPressed: reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.bookingsHeadline,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(t.bookingsIntro),
            const SizedBox(height: 16),
            if (actionFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  t.bookingsUpdateFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: FutureBuilder<List<List<dynamic>>>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return EmptyState(
                      title: t.bookingsLoadFailed,
                      message: t.bookingsLoadHelp,
                      action: OutlinedButton(
                        onPressed: reload,
                        child: Text(t.bookingsRetry),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!provider) return list(snapshot.data![0], false);
                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: t.bookingsTabHired),
                            Tab(text: t.bookingsTabReceived),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              list(snapshot.data![0], false),
                              Column(
                                children: [
                                  WeeklyAllowance(
                                    key: ObjectKey(snapshot.data),
                                    userApi: widget.users,
                                    matchApi: widget.api,
                                  ),
                                  Expanded(
                                    child: list(snapshot.data![1], true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
