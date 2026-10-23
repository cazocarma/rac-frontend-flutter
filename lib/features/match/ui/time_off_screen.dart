import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({super.key, this.api, this.compaId});
  final JsonApi? api;
  final String? compaId;
  @override
  State<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  late final api = widget.api ?? JsonApi(Env.apiBase, apiPath: '/api/match');
  String? owner, zone, error;
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
    });
    try {
      owner ??= widget.compaId ?? (await Services.user.me())['id'] as String;
      final data = await api.request(path);
      if (mounted) {
        setState(() {
          items = data['items'] as List;
          zone = data['zona_horaria'] as String;
          minimum = DateTime.parse(data['fecha_min'] as String);
          maximum = DateTime.parse(data['fecha_max'] as String);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e is ApiException && e.status == 403
              ? 'Solo puedes gestionar tu propia agenda.'
              : 'No pudimos cargar los días libres. Inténtalo nuevamente.';
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
              ? 'El período se cruza con una reserva o con otro bloqueo. Tus reservas se conservan.'
              : 'No pudimos guardar el cambio. Revisa las fechas e inténtalo nuevamente.',
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
      helpText: 'Días sin disponibilidad',
      saveText: 'Bloquear días',
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
      setState(() => error = 'Puedes bloquear hasta 366 días por período.');
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
        title: const Text('¿Volver a ofrecer estos días?'),
        content: Text(
          'Se quitará el bloqueo del ${item['desde']} al ${item['hasta']}. Se conserva tu horario semanal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Conservar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar bloqueo'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      await change('$path/${item['id']}', method: 'DELETE');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis días libres'),
      actions: [
        IconButton(
          tooltip: 'Actualizar días libres',
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
                  'Una pausa en tu agenda',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bloquea días completos para vacaciones u otros compromisos. Las fechas usan la zona de tu agenda${zone == null ? '' : ': $zone'}. El último día también queda bloqueado.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'No se cancelan reservas existentes. Si hay una pendiente o confirmada, resuélvela antes de bloquear ese período.',
                ),
                const SizedBox(height: 20),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (zone == null)
                  OutlinedButton(
                    onPressed: load,
                    child: const Text('Reintentar'),
                  )
                else
                  FilledButton.icon(
                    onPressed: busy ? null : add,
                    icon: const Icon(Icons.event_busy_outlined),
                    label: Text(busy ? 'Guardando…' : 'Agregar días libres'),
                  ),
                const SizedBox(height: 24),
                if (items.isEmpty && zone != null)
                  const Text(
                    'No tienes bloqueos vigentes. Se aplica tu disponibilidad semanal.',
                  ),
                for (final raw in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        isThreeLine: true,
                        title: Text('${raw['desde']} → ${raw['hasta']}'),
                        subtitle: Text(
                          'Días completos · ${raw['zona_horaria']}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Quitar bloqueo',
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
