import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../../chat/ui/moderation_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, this.api});
  final JsonApi? api;
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final api = widget.api ?? JsonApi(Env.apiBase, apiPath: '/api/admin');
  Map<String, dynamic>? values;
  Object? failure;
  bool loading = true;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    if (widget.api == null) {
      api.close();
    }
    super.dispose();
  }

  Future<void> load() async {
    final request = ++generation;
    setState(() {
      loading = true;
      failure = null;
      values = null;
    });
    try {
      final result = await api.request('/overview');
      if (mounted && request == generation) {
        setState(() {
          values = result;
          loading = false;
        });
      }
    } catch (error) {
      if (mounted && request == generation) {
        setState(() {
          failure = error;
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.adminTitle),
        actions: [
          IconButton(
            tooltip: t.adminRefresh,
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContent(
        width: 1000,
        child: Builder(
          builder: (context) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (failure != null) {
              final forbidden =
                  failure is ApiException &&
                  (failure as ApiException).status == 403;
              return EmptyState(
                title: forbidden ? t.adminForbiddenTitle : t.adminLoadFailed,
                message: forbidden ? t.adminForbiddenMessage : t.adminLoadHelp,
                action: forbidden
                    ? null
                    : OutlinedButton(
                        onPressed: load,
                        child: Text(t.adminRetry),
                      ),
              );
            }
            final values = this.values!;
            final users = values['usuarios'] as Map<String, dynamic>;
            final bookings = values['reservas'] as Map<String, dynamic>;
            final reports = values['reportes'] as Map<String, dynamic>;
            final date = DateTime.tryParse(
              values['consultado_en'] as String? ?? '',
            )?.toLocal();
            final theme = Theme.of(context);
            Widget section(String title, Map<String, dynamic> counts) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, size) {
                    final width = size.maxWidth < 500
                        ? size.maxWidth
                        : (size.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: counts.entries
                          .map(
                            (e) => SizedBox(
                              width: width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.key,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${e.value}',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            );
            return ListView(
              children: [
                Text(t.adminHeadline, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(t.adminIntro),
                const SizedBox(height: 12),
                if (date != null)
                  Text(
                    t.adminQueriedAt(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: true)}',
                    ),
                  ),
                const SizedBox(height: 28),
                section(t.adminCommunity, {
                  t.adminUsers: users['total'],
                  t.adminCompas: users['compas'],
                }),
                section(t.adminBookings, {
                  t.adminPending: bookings['pendiente'],
                  t.adminConfirmed: bookings['activa'],
                  t.adminFinished: bookings['finalizada'],
                  t.adminCancelled: bookings['cancelada'],
                  t.adminExpired: bookings['expirada'],
                }),
                section(t.adminModeration, {
                  t.moderationFilterOpen: reports['abierto'],
                  t.moderationFilterHandled: reports['atendido'],
                  t.moderationFilterDismissed: reports['desestimado'],
                }),
                Text(t.adminModerationNote),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ModerationScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.shield_outlined),
                  label: Text(t.adminReviewReports),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
