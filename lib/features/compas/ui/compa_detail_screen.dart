import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../booking/ui/booking_screen.dart';
import '../data/compa_api.dart';

class CompaDetailScreen extends StatefulWidget {
  const CompaDetailScreen({super.key, required this.api, required this.id});
  final CompaApi api;
  final String id;
  @override
  State<CompaDetailScreen> createState() => _CompaDetailScreenState();
}

class _CompaDetailScreenState extends State<CompaDetailScreen> {
  late Future<CompaCard> data;
  @override
  void initState() {
    super.initState();
    data = widget.api.getById(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Conoce a tu compa')),
    body: FutureBuilder<CompaCard>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            title: 'No pudimos cargar el perfil',
            message: 'Revisa tu conexión e inténtalo nuevamente.',
            action: OutlinedButton(
              onPressed: () =>
                  setState(() => data = widget.api.getById(widget.id)),
              child: const Text('Reintentar'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final c = snapshot.data!;
        return SingleChildScrollView(
          child: PageContent(
            width: 800,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      child: Text(
                        c.nombre.isEmpty ? '?' : c.nombre[0].toUpperCase(),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      c.nombre,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      c.ratingPromedio > 0
                          ? '★ ${c.ratingPromedio.toStringAsFixed(1)} · Calificación promedio'
                          : 'Nuevo en RAC · Aún sin calificaciones',
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in c.habilidades)
                          Chip(
                            label: Text(skill),
                            avatar: const Icon(
                              Icons.auto_awesome_outlined,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Un poco sobre mí',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (c.descripcion ?? '').isEmpty
                          ? 'Este compa todavía no agregó una descripción.'
                          : c.descripcion!,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      '${money(c.tarifaHora)} CLP / hora',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Consulta horarios y envía una solicitud. Sin cobro por ahora.',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(
                              compaId: c.id,
                              compaName: c.nombre,
                              rate: c.tarifaHora,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Reservar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
