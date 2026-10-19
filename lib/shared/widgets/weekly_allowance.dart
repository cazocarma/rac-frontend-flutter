import 'package:flutter/material.dart';
import '../di/services.dart';
import '../services/session.dart';

/// The backend owns the Chilean week calculation and subscription entitlement.
class WeeklyAllowance extends StatefulWidget {
  const WeeklyAllowance({super.key});
  @override
  State<WeeklyAllowance> createState() => _WeeklyAllowanceState();
}

class _WeeklyAllowanceState extends State<WeeklyAllowance> {
  late Future<Map<String, dynamic>?> data = load();
  String? date;
  Future<Map<String, dynamic>?> load() async {
    final role = await Session.role();
    if (role != 'compa' && role != 'admin') return null;
    final me = await Services.user.me();
    return Services.match.allowance(me['id'] as String, date: date);
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
          title: const Text('No pudimos consultar tus cupos'),
          trailing: IconButton(
            tooltip: 'Reintentar cupos',
            onPressed: () => setState(() => data = load()),
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
                    ? 'Suscripción activa'
                    : '${value['disponibles']} de ${value['limite_gratuito']} cupos gratuitos disponibles',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Semana del ${value['semana_inicio']} · Chile · ${value['usados']} reservas confirmadas',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: selectWeek,
                    icon: const Icon(Icons.date_range),
                    label: const Text('Consultar otra semana'),
                  ),
                  IconButton(
                    tooltip: 'Actualizar cupos',
                    onPressed: () => setState(() => data = load()),
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
