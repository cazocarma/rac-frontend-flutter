import '../../l10n/generated/app_localizations.dart';
import '../services/user_api.dart';
import '../../features/match/data/match_api.dart';
import 'package:flutter/material.dart';
import '../di/services.dart';
import '../services/session.dart';

/// The backend owns the Chilean week calculation and subscription entitlement.
class WeeklyAllowance extends StatefulWidget {
  const WeeklyAllowance({super.key, this.userApi, this.matchApi});
  final UserApi? userApi;
  final MatchApi? matchApi;
  @override
  State<WeeklyAllowance> createState() => _WeeklyAllowanceState();
}

class _WeeklyAllowanceState extends State<WeeklyAllowance> {
  AppLocalizations get t => AppLocalizations.of(context)!;
  late Future<Map<String, dynamic>?> data = load();
  String? date;
  Future<Map<String, dynamic>?> load() async {
    final role = await Session.role();
    if (role != 'compa' && role != 'admin') return null;
    final me = await (widget.userApi ?? Services.user).me();
    return (widget.matchApi ?? Services.match).allowance(
      me['id'] as String,
      date: date,
    );
  }

  void reload() {
    if (!mounted) return;
    setState(() {
      data = load();
    });
  }

  Future<void> selectWeek() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(date ?? '') ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (selected == null || !mounted) return;
    setState(() {
      date =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
      data = load();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ListTile(
          title: Text(t.allowanceLoadFailed),
          trailing: IconButton(
            tooltip: t.allowanceRetry,
            onPressed: reload,
            icon: const Icon(Icons.refresh),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const LinearProgressIndicator();
      }
      final value = snapshot.data;
      if (value == null) return const SizedBox.shrink();
      final subscribed = value['suscripcion_activa'] == true;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subscribed
                    ? t.allowanceActive
                    : t.allowanceAvailable(
                        (value['disponibles'] as num).toInt(),
                        (value['limite_gratuito'] as num).toInt(),
                      ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                t.allowanceWeek(
                  value['semana_inicio'] as String,
                  (value['usados'] as num).toInt(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: selectWeek,
                    icon: const Icon(Icons.date_range),
                    label: Text(t.allowanceSelectWeek),
                  ),
                  IconButton(
                    tooltip: t.allowanceRefresh,
                    onPressed: reload,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
