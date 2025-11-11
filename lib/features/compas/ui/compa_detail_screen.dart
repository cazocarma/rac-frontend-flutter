import 'package:flutter/material.dart';
import '../../compas/data/compa_api.dart';
import '../../booking/ui/booking_screen.dart';

class CompaDetailScreen extends StatefulWidget {
  final CompaApi api;
  final String id;

  const CompaDetailScreen({
    super.key,
    required this.api,
    required this.id,
  });

  @override
  State<CompaDetailScreen> createState() => _CompaDetailScreenState();
}

class _CompaDetailScreenState extends State<CompaDetailScreen> {
  CompaCard? compa;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.api.getById(widget.id);
      setState(() => compa = data);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = compa;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Compa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: error != null
            ? Text(
                error!,
                style: const TextStyle(color: Colors.red),
              )
            : c == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nombre,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${c.tarifaHora.toStringAsFixed(0)}/h • ★ ${c.ratingPromedio.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.habilidades.join(', '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      if ((c.descripcion ?? '').isNotEmpty)
                        Text(
                          c.descripcion!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text('Reservar'),
                          onPressed: () {
                            final cc = compa;
                            if (cc == null) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(
                                  compaId: cc.id,
                                  compaName: cc.nombre,
                                ),
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
}

