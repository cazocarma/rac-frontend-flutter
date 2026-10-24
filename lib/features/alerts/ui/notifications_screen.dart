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
  Future<void> markRead(String id) async {
    if (markingAll || busy.contains(id)) return;
    setState(() => busy.add(id));
    try {
      await api.readNotification(id);
      if (mounted) setState(() => data = load());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos actualizar la notificación. Inténtalo otra vez.',
            ),
          ),
        );
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
      if (mounted) setState(() => data = load());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos marcar tus avisos. Actualiza para comprobar su estado.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => markingAll = false);
    }
  }

  String contextLabel(Map<dynamic, dynamic> item) {
    if (item['tipo'] == 'estado_cuenta') return 'Cuenta';
    final session = item['sesion_id'];
    return session is String && session.length >= 8
        ? 'Reserva ${session.substring(0, 8)}'
        : 'Reserva';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notificaciones'),
      actions: [
        IconButton(
          tooltip: 'Actualizar notificaciones',
          onPressed: () => setState(() {
            offset = 0;
            data = load();
          }),
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
              title: 'No pudimos cargar tus notificaciones',
              message: 'Revisa tu conexión e inténtalo nuevamente.',
              action: OutlinedButton(
                onPressed: () => setState(() => data = load()),
                child: const Text('Reintentar'),
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
                'Novedades de tu cuenta y reservas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Aquí verás cambios de tu cuenta y tus reservas. Avisos por correo y al teléfono: en construcción.',
              ),
              const SizedBox(height: 16),
              Text(
                '${snapshot.data!['no_leidas'] ?? 0} sin leer en tu bandeja',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if ((snapshot.data!['no_leidas'] as num? ?? 0) > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: markingAll || busy.isNotEmpty ? null : markAll,
                    icon: const Icon(Icons.done_all),
                    label: Text(
                      markingAll ? 'Actualizando…' : 'Marcar todas como leídas',
                    ),
                  ),
                ),
              if (items.isEmpty)
                const EmptyState(
                  title: 'Estás al día',
                  message:
                      'Los próximos cambios de tu cuenta y tus reservas aparecerán aquí.',
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
                              const Chip(label: Text('Nueva')),
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
                                child: const Text('Marcar como leída'),
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
                                    ? 'Ver estado de mi cuenta'
                                    : 'Ver mis reservas',
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
                      onPressed: () => setState(() {
                        offset -= 20;
                        data = load();
                      }),
                      child: const Text('Más recientes'),
                    ),
                  if (snapshot.data!['has_more'] == true)
                    TextButton(
                      onPressed: () => setState(() {
                        offset += 20;
                        data = load();
                      }),
                      child: const Text('Anteriores'),
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
