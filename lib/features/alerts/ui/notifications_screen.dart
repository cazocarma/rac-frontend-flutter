import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../data/alert_api.dart';
import '../../../shared/widgets/design.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.api});
  final AlertApi? api;
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AppLocalizations get t => AppLocalizations.of(context)!;
  late final api = widget.api ?? AlertApi(Env.apiBase);
  late Future<Map<String, dynamic>> data = load();
  bool markingAll = false;
  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  int offset = 0;
  final busy = <String>{};
  Future<Map<String, dynamic>> load() => api.notifications(offset: offset);
  void reload({int? nextOffset}) {
    if (!mounted) return;
    setState(() {
      offset = nextOffset ?? offset;
      data = load();
    });
  }

  Future<void> markRead(String id) async {
    if (markingAll || busy.contains(id)) return;
    setState(() => busy.add(id));
    try {
      await api.readNotification(id);
      reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.notificationsUpdateFailed)));
      }
    } finally {
      if (mounted) setState(() => busy.remove(id));
    }
  }

  Future<void> markAll() async {
    if (markingAll || busy.isNotEmpty) return;
    setState(() => markingAll = true);
    try {
      await api.readAll();
      reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.notificationsAllFailed)));
      }
    } finally {
      if (mounted) setState(() => markingAll = false);
    }
  }

  String contextLabel(Map<dynamic, dynamic> item) {
    if (item['tipo'] == 'estado_cuenta') return t.notificationsAccount;
    final session = item['sesion_id'];
    return session is String && session.length >= 8
        ? t.notificationsBookingReference(session.substring(0, 8))
        : t.notificationsBooking;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(t.notificationsTitle),
      actions: [
        IconButton(
          tooltip: t.notificationsRefresh,
          onPressed: () => reload(nextOffset: 0),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: PageContent(
      width: 850,
      child: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              title: t.notificationsLoadFailed,
              message: t.notificationsRetryMessage,
              action: OutlinedButton(
                onPressed: reload,
                child: Text(t.notificationsRetry),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = (snapshot.data!['items'] as List);
          return ListView(
            children: [
              Text(
                t.notificationsHeading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(t.notificationsDescription),
              const SizedBox(height: 16),
              Text(
                t.notificationsUnread(
                  (snapshot.data!['no_leidas'] as num? ?? 0).toInt(),
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if ((snapshot.data!['no_leidas'] as num? ?? 0) > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: markingAll || busy.isNotEmpty ? null : markAll,
                    icon: const Icon(Icons.done_all),
                    label: Text(
                      markingAll
                          ? t.notificationsUpdating
                          : t.notificationsMarkAll,
                    ),
                  ),
                ),
              if (items.isEmpty)
                EmptyState(
                  title: t.notificationsCaughtUp,
                  message: t.notificationsEmptyMessage,
                  icon: Icons.notifications_none,
                ),
              for (final item in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item['leido_en'] == null
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_none,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['titulo'] as String,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (item['leido_en'] == null)
                              Chip(label: Text(t.notificationsNew)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${contextLabel(item)} · ${dateLabel(DateTime.parse(item['creado_en'] as String).toLocal())}',
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (item['leido_en'] == null)
                              TextButton(
                                onPressed:
                                    (markingAll || busy.contains(item['id']))
                                    ? null
                                    : () => markRead(item['id'] as String),
                                child: Text(t.notificationsMarkRead),
                              ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                item['tipo'] == 'estado_cuenta'
                                    ? '/profile'
                                    : '/match',
                              ),
                              child: Text(
                                item['tipo'] == 'estado_cuenta'
                                    ? t.notificationsViewAccount
                                    : t.notificationsViewBookings,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                children: [
                  if (offset > 0)
                    TextButton(
                      onPressed: () => reload(nextOffset: offset - 20),
                      child: Text(t.notificationsNewer),
                    ),
                  if (snapshot.data!['has_more'] == true)
                    TextButton(
                      onPressed: () => reload(nextOffset: offset + 20),
                      child: Text(t.notificationsOlder),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
