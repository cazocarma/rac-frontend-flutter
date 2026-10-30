import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';

enum _TimeOffFailure { forbidden, load, conflict, save, tooLong }

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({super.key, this.api, this.compaId});
  final JsonApi? api;
  final String? compaId;
  @override
  State<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  AppLocalizations get t => AppLocalizations.of(context)!;
  late final api = widget.api ?? JsonApi(Env.apiBase, apiPath: '/api/match');
  String? owner, zone;
  _TimeOffFailure? error;
  DateTime? minimum, maximum;
  List<dynamic> items = [];
  bool loading = true, busy = false;
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

  String get path => '/availability/$owner/time-off';
  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
      items = [];
      zone = null;
      minimum = null;
      maximum = null;
    });
    try {
      owner ??= widget.compaId ?? (await Services.user.me())['id'] as String;
      final data = await api.request(path);
      // Publish a complete response together. A failed refresh must not leave
      // stale date bounds or imply that an unobserved schedule has no blocks.
      final nextItems = data['items'] as List;
      final nextZone = data['zona_horaria'] as String;
      final nextMinimum = DateTime.parse(data['fecha_min'] as String);
      final nextMaximum = DateTime.parse(data['fecha_max'] as String);
      if (nextZone.isEmpty || nextMaximum.isBefore(nextMinimum)) {
        throw const FormatException('invalid_time_off_window');
      }
      if (mounted) {
        setState(() {
          items = nextItems;
          zone = nextZone;
          minimum = nextMinimum;
          maximum = nextMaximum;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e is ApiException && e.status == 403
              ? _TimeOffFailure.forbidden
              : _TimeOffFailure.load;
        });
      }
    }
  }

  Future<void> change(
    String url, {
    Map<String, dynamic>? body,
    String? method,
  }) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await api.request(url, body: body, method: method);
      if (mounted) {
        await load();
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ApiException && e.status == 409
              ? _TimeOffFailure.conflict
              : _TimeOffFailure.save,
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<void> add() async {
    final today = minimum!;
    final range = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: maximum!,
      helpText: t.timeOffPickerHelp,
      saveText: t.timeOffPickerSave,
    );
    if (range == null || !mounted) {
      return;
    }
    if (DateTime.utc(range.end.year, range.end.month, range.end.day)
            .difference(
              DateTime.utc(
                range.start.year,
                range.start.month,
                range.start.day,
              ),
            )
            .inDays >=
        366) {
      setState(() => error = _TimeOffFailure.tooLong);
      return;
    }
    String date(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    await change(
      path,
      body: {'desde': date(range.start), 'hasta': date(range.end)},
    );
  }

  Future<void> remove(Map<String, dynamic> item) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.timeOffRemoveTitle),
        content: Text(
          t.timeOffRemoveMessage(
            item['desde'] as String,
            item['hasta'] as String,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.timeOffKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.timeOffRemove),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      await change('$path/${item['id']}', method: 'DELETE');
    }
  }

  String _errorText(_TimeOffFailure failure) => switch (failure) {
    _TimeOffFailure.forbidden => t.timeOffForbidden,
    _TimeOffFailure.load => t.timeOffLoadFailed,
    _TimeOffFailure.conflict => t.timeOffConflict,
    _TimeOffFailure.save => t.timeOffSaveFailed,
    _TimeOffFailure.tooLong => t.timeOffTooLong,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(t.timeOffTitle),
      actions: [
        IconButton(
          tooltip: t.timeOffRefresh,
          onPressed: loading || busy ? null : load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: PageContent(
      width: 850,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text(
                  t.timeOffHeading,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  zone == null
                      ? t.timeOffDescription
                      : t.timeOffDescriptionWithZone(zone!),
                ),
                const SizedBox(height: 12),
                Text(t.timeOffReservationsHelp),
                const SizedBox(height: 20),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorText(error!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (zone == null)
                  OutlinedButton(onPressed: load, child: Text(t.timeOffRetry))
                else
                  FilledButton.icon(
                    onPressed: busy ? null : add,
                    icon: const Icon(Icons.event_busy_outlined),
                    label: Text(busy ? t.timeOffSaving : t.timeOffAdd),
                  ),
                const SizedBox(height: 24),
                if (items.isEmpty && zone != null) Text(t.timeOffEmpty),
                for (final raw in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        isThreeLine: true,
                        title: Text('${raw['desde']} → ${raw['hasta']}'),
                        subtitle: Text(
                          t.timeOffFullDays(raw['zona_horaria'] as String),
                        ),
                        trailing: IconButton(
                          tooltip: t.timeOffRemove,
                          onPressed: busy
                              ? null
                              : () => remove(Map<String, dynamic>.from(raw)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    ),
  );
}
