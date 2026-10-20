import 'package:flutter/material.dart';
import 'package:rentacompa/shared/widgets/reviews.dart';
import '../data/match_api.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/widgets/design.dart';
import 'package:rentacompa/shared/widgets/weekly_allowance.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<List<List<dynamic>>> data;
  bool provider = false;
  final busy = <String>{};
  String? actionError;
  @override
  void initState() {
    super.initState();
    data = load();
  }

  Future<List<List<dynamic>>> load() async {
    final me = await Services.user.me();
    final role = await Session.role();
    provider = role == 'compa' || role == 'admin';
    final bought = await Services.match.listClient(
      me['id'] as String,
      limit: 100,
    );
    final received = provider
        ? await Services.match.listCompa(me['id'] as String, limit: 100)
        : <String, dynamic>{};
    return [(bought['items'] ?? []) as List, (received['items'] ?? []) as List];
  }

  Future<void> transition(String id, String state) async {
    if (busy.contains(id)) return;
    if (state == 'cancelada') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('¿Cancelar esta reserva?'),
          content: const Text(
            'La solicitud quedará cancelada. Puedes crear otra reserva cuando quieras.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Conservar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Cancelar reserva'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      busy.add(id);
      actionError = null;
    });
    try {
      await Services.match.updateState(id, state);
      if (mounted) setState(() => data = load());
    } on SubscriptionRequired catch (e) {
      if (!mounted) return;
      final showPlans = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Alcanzaste tus 3 reservas gratis'),
          content: Text(
            'Ya utilizaste ${e.allowance['usados']} cupos en la semana que empieza el ${e.allowance['semana_inicio']} (Chile).\n\nEsta solicitud sigue pendiente. Para aceptar más necesitarás una suscripción. Los pagos todavía están en construcción.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Entendido'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Ver planes'),
            ),
          ],
        ),
      );
      if (mounted && showPlans == true) {
        await Navigator.of(context).pushNamed('/payments');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => actionError =
              'No se pudo actualizar la reserva. Revisa su estado e inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => busy.remove(id));
    }
  }

  Widget list(List<dynamic> items, bool received) => items.isEmpty
      ? EmptyState(
          title: received
              ? 'Tu agenda está libre'
              : 'Tu próximo plan te espera',
          message: received
              ? 'Las solicitudes que recibas aparecerán aquí.'
              : 'Explora los compas y encuentra una experiencia para compartir.',
          icon: Icons.calendar_month_outlined,
          action: received
              ? null
              : OutlinedButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (_) => false),
                  child: const Text('Explorar compas'),
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
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          side: BorderSide.none,
                          label: Text(
                            {
                                  'pendiente': 'Pendiente de aceptación',
                                  'activa': 'Confirmada',
                                  'cancelada': 'Cancelada',
                                  'finalizada': 'Finalizada',
                                }[state] ??
                                state,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${clockLabel(date)} → ${dateLabel(end)} ${clockLabel(end)}',
                    ),
                    const SizedBox(height: 8),
                    const Text('Pagos en construcción · Sin cobro'),
                    Text(
                      'Reserva ${id.substring(0, 8)} · ${received ? 'Solicitud recibida' : 'Tu contratación'}',
                    ),
                    if (state == 'finalizada' &&
                        !received &&
                        end.isAfter(DateTime.now()))
                      const Text(
                        'Podrás dejar una reseña cuando termine el horario reservado.',
                      ),
                    if (state == 'finalizada')
                      BookingReview(
                        key: ValueKey(id),
                        id: id,
                        canWrite: !received && !end.isAfter(DateTime.now()),
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
                                child: const Text('Aceptar'),
                              ),
                            if (state == 'activa' &&
                                !date.isAfter(DateTime.now()))
                              OutlinedButton(
                                onPressed: busy.contains(id)
                                    ? null
                                    : () => transition(id, 'finalizada'),
                                child: const Text('Finalizar'),
                              ),
                            TextButton(
                              onPressed: busy.contains(id)
                                  ? null
                                  : () => transition(id, 'cancelada'),
                              child: Text(
                                busy.contains(id)
                                    ? 'Actualizando…'
                                    : 'Cancelar',
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
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis reservas'),
      actions: [
        IconButton(
          tooltip: 'Actualizar reservas',
          onPressed: () => setState(() => data = load()),
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
            'Tus planes, en un solo lugar.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sigue tus solicitudes y gestiona las experiencias confirmadas.',
          ),
          const SizedBox(height: 16),
          if (actionError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                actionError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<List<dynamic>>>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return EmptyState(
                    title: 'No pudimos cargar tus reservas',
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
                if (!provider) return list(snapshot.data![0], false);
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Mis contrataciones'),
                          Tab(text: 'Solicitudes recibidas'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            list(snapshot.data![0], false),
                            Column(
                              children: [
                                WeeklyAllowance(key: ObjectKey(snapshot.data)),
                                Expanded(child: list(snapshot.data![1], true)),
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
