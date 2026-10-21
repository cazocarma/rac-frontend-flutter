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
  Map<String, dynamic>? data;
  String? error;
  int offset = 0;
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
    try {
      final result = await api.request('/moderation/reports?offset=$offset');
      if (mounted) {
        setState(() {
          data = result;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is ChatException && e.status == 403
              ? 'Acceso reservado al equipo de moderación.'
              : 'No pudimos cargar los reportes. Inténtalo de nuevo.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Moderación de reportes'),
      actions: [
        IconButton(
          onPressed: load,
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
            'Casos pendientes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'La cola muestra únicamente datos del caso. Para consultar su contenido debes indicar una justificación. Los casos donde participas quedan excluidos.',
          ),
          const SizedBox(height: 24),
          if (error != null) ...[
            Text(error!),
            OutlinedButton(onPressed: load, child: const Text('Reintentar')),
          ] else if (data == null)
            const LinearProgressIndicator()
          else ...[
            if ((data!['items'] as List).isEmpty)
              const Text('No hay reportes pendientes en esta página.'),
            for (final item in data!['items'] as List)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(reportReasons[item['motivo']] ?? 'Reporte'),
                  subtitle: Text(
                    'Caso ${(item['id'] as String).substring(0, 8)} · Reserva ${(item['sesion_id'] as String).substring(0, 8)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ModerationCaseScreen(id: item['id'] as String),
                      ),
                    );
                    if (mounted) await load();
                  },
                ),
              ),
            Wrap(
              spacing: 12,
              children: [
                if (offset > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() => offset -= 20);
                      load();
                    },
                    child: const Text('Anteriores'),
                  ),
                if (data!['has_more'] == true)
                  OutlinedButton(
                    onPressed: () {
                      setState(() => offset += 20);
                      load();
                    },
                    child: const Text('Siguientes'),
                  ),
              ],
            ),
          ],
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
