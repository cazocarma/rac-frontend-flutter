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
  static const filters = {
    'abierto': 'Abiertos',
    'atendido': 'Atendidos',
    'desestimado': 'Desestimados',
    'todos': 'Todos',
  };
  Map<String, dynamic>? data;
  String? error;
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
      error = null;
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
          error = e is ChatException && e.status == 403
              ? 'Acceso reservado al equipo de moderación.'
              : 'No pudimos cargar los reportes. Inténtalo de nuevo.';
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

  String dateLabel(BuildContext context, dynamic value) {
    final date = value is String ? DateTime.tryParse(value)?.toLocal() : null;
    if (date == null) return 'Fecha no disponible';
    final localizations = MaterialLocalizations.of(context);
    String two(int value) => value.toString().padLeft(2, '0');
    final day = '${two(date.day)}/${two(date.month)}/${date.year}';
    return '$day · ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date), alwaysUse24HourFormat: true)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Moderación de reportes'),
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
          tooltip: 'Actualizar reportes',
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
                ? 'Casos pendientes'
                : 'Historial de reportes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Consulta el estado y las fechas de cada reporte. Los casos donde participas quedan excluidos. El contenido de un caso abierto requiere una consulta justificada y registrada.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in filters.entries)
                ChoiceChip(
                  label: Text(filter.value),
                  selected: selectedState == filter.key,
                  onSelected: (selected) {
                    if (selected) selectState(filter.key);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ordenados por fecha del reporte, del más antiguo al más reciente.',
          ),
          const SizedBox(height: 20),
          if (loading) const LinearProgressIndicator(),
          if (error != null) ...[
            Text(error!, semanticsLabel: error),
            OutlinedButton(onPressed: load, child: const Text('Reintentar')),
          ],
          if (data != null) ...[
            if ((data!['items'] as List).isEmpty)
              const Text('No hay reportes para este filtro en esta página.'),
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
                      Text(reportReasons[item['motivo']] ?? 'Reporte'),
                      Chip(
                        label: Text(
                          reportStatuses[item['estado']] ??
                              'Estado no disponible',
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caso ${(item['id'] as String).substring(0, 8)} · Reserva ${(item['sesion_id'] as String).substring(0, 8)}',
                      ),
                      Text(
                        'Reportado: ${dateLabel(context, item['creado_en'])}',
                      ),
                      if (item['estado'] != 'abierto') ...[
                        Text(
                          'Cierre: ${dateLabel(context, item['resuelto_en'])}',
                        ),
                        const Text(
                          'Caso cerrado. La consulta del contenido está deshabilitada.',
                        ),
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
              Text('Página ${cursors.length}'),
              if (cursors.length > 1)
                OutlinedButton(
                  onPressed: loading
                      ? null
                      : () {
                          cursors.removeLast();
                          load();
                        },
                  child: const Text('Anteriores'),
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
                  child: const Text('Siguientes'),
                ),
            ],
          ),
        ],
      ),
    ),
  );
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
  String? error;
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
      error = null;
    });
    try {
      final result = await api.request(
        '/moderation/reports/${widget.id}/access',
        body: {'justificacion': justification.text.trim(), 'antes': before},
      );
      if (mounted) setState(() => data = result);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'No pudimos autorizar la consulta. El caso puede estar cerrado o fuera de tu acceso.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resolve(String state) async {
    if (!form.currentState!.validate()) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar este caso?'),
        content: Text(
          'Se registrará como ${state == 'atendido' ? 'atendido' : 'desestimado'} junto a tu justificación. El cierre no aplica sanciones ni retira bloqueos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar cierre'),
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
        setState(
          () => error =
              'No pudimos confirmar el cierre. Actualiza la cola para comprobar su estado.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Caso ${widget.id.substring(0, 8)}')),
    body: PageContent(
      width: 900,
      child: ListView(
        children: [
          const Icon(Icons.policy_outlined, size: 40),
          const SizedBox(height: 16),
          Text(
            'Consulta con responsabilidad',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Solo se permite revisar el historial existente al enviar este reporte. Cada consulta y cada cierre registran tu identidad, justificación y hora. No copies información fuera del proceso de moderación.',
          ),
          const SizedBox(height: 20),
          Form(
            key: form,
            child: TextFormField(
              controller: justification,
              enabled: !busy,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Justificación de la consulta o resolución',
              ),
              validator: (value) => (value?.trim().runes.length ?? 0) < 10
                  ? 'Escribe una justificación de al menos 10 caracteres.'
                  : null,
            ),
          ),
          FilledButton.icon(
            onPressed: busy ? null : () => access(),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Consultar y registrar acceso'),
          ),
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Padding(padding: const EdgeInsets.all(16), child: Text(error!)),
          if (data != null) ...[
            const SizedBox(height: 24),
            Text(
              reportReasons[data!['motivo']] ?? 'Reporte',
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
            const Text('Historial asociado al reporte'),
            for (final item in (data!['items'] as List).reversed)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['propio'] == true ? 'Quien reportó' : 'Otra persona'} · ${item['enviado_en']}',
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
                child: const Text(
                  'Consultar mensajes anteriores y registrar acceso',
                ),
              ),
            const Divider(height: 32),
            const Text(
              'Describe la gestión realizada en la justificación antes de cerrar el caso.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: busy ? null : () => resolve('atendido'),
                  child: const Text('Marcar atendido'),
                ),
                OutlinedButton(
                  onPressed: busy ? null : () => resolve('desestimado'),
                  child: const Text('Desestimar reporte'),
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
