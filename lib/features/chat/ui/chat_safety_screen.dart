import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/widgets/design.dart';
import '../data/chat_api.dart';

const reportStatuses = {
  'abierto': 'Pendiente de revisión',
  'atendido': 'Reporte atendido',
  'desestimado': 'Reporte desestimado',
};

const reportReasons = {
  'acoso': 'Acoso o amenazas',
  'spam': 'Spam o publicidad',
  'contenido_inapropiado': 'Contenido inapropiado',
  'otro': 'Otro motivo',
};

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
  String? error;
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
      if (mounted) {
        setState(
          () => error =
              'No pudimos cargar las opciones de seguridad. Inténtalo de nuevo.',
        );
      }
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
      if (mounted) {
        setState(
          () => error =
              'No pudimos confirmar el cambio. Actualiza para comprobar su estado antes de reintentar.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> block() async {
    final mine = data!['bloqueada_por_mi'] == true;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          mine ? '¿Retirar tu bloqueo?' : '¿Bloquear esta conversación?',
        ),
        content: Text(
          mine
              ? 'Se podrá conversar si la otra persona tampoco mantiene un bloqueo y la reserva sigue activa.'
              : 'Se detendrán los mensajes nuevos de ambos participantes. Conservarás el historial. La reserva y sus condiciones siguen vigentes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(mine ? 'Retirar bloqueo' : 'Confirmar bloqueo'),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Seguridad de la conversación'),
      actions: [
        IconButton(
          onPressed: busy ? null : load,
          tooltip: 'Actualizar seguridad',
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
            'Tu tranquilidad importa',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Estas opciones se aplican a esta conversación. Bloquear y reportar son decisiones independientes.',
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (data == null) ...[
            if (error == null)
              const LinearProgressIndicator()
            else
              OutlinedButton(onPressed: load, child: const Text('Reintentar')),
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
                          ? 'Conversación bloqueada'
                          : 'Controla quién puede escribirte',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data!['bloqueada_por_mi'] == true
                          ? 'Mantienes un bloqueo activo. Puedes retirarlo cuando quieras.'
                          : data!['bloqueada'] == true
                          ? 'Hay un bloqueo activo de la otra persona. El historial sigue disponible.'
                          : 'Puedes detener los mensajes nuevos sin borrar el historial.',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: busy ? null : block,
                      icon: const Icon(Icons.block),
                      label: Text(
                        data!['bloqueada_por_mi'] == true
                            ? 'Retirar mi bloqueo'
                            : 'Bloquear conversación',
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
                        reportStatuses[data!['estado_reporte']] ??
                            'Reporte recibido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Puedes actualizar esta pantalla para consultar el estado de tu reporte. No necesitas enviarlo otra vez.',
                      ),
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
                          'Reportar un problema',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'El equipo de moderación podrá consultar tu descripción y el historial existente al enviar el reporte. Cada consulta requiere una justificación y queda registrada. No incluyas contraseñas ni información privada ajena al incidente.',
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: reason,
                          decoration: const InputDecoration(
                            labelText: 'Motivo del reporte',
                          ),
                          items: [
                            for (final entry in reportReasons.entries)
                              DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
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
                          decoration: const InputDecoration(
                            labelText: 'Describe qué ocurrió',
                          ),
                          validator: (value) =>
                              (value?.trim().runes.length ?? 0) < 10
                              ? 'Cuéntanos lo ocurrido en al menos 10 caracteres.'
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
                          label: const Text('Enviar reporte'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Los reportes se revisan manualmente. Su envío no cancela la reserva ni modifica sus condiciones.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
