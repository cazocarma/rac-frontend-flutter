import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/weekly_allowance.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Planes y suscripción')),
    body: SingleChildScrollView(
      child: PageContent(
        width: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empieza gratis. Crece a tu ritmo.',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'La suscripción amplía tu capacidad para aceptar reservas como compa.',
            ),
            const SizedBox(height: 24),
            const WeeklyAllowance(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Chip(label: Text('Plan gratuito')),
                    const SizedBox(height: 16),
                    Text(
                      '3 reservas por semana',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Recibe solicitudes sin límite de cupos. Confirma hasta tres reservas por semana, de lunes a domingo, según la fecha de la actividad y la zona horaria de Chile.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Si cancelas antes del inicio, recuperas el cupo. Una cancelación después del inicio mantiene el cupo consumido.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.handyman_outlined, size: 36),
                    SizedBox(height: 16),
                    Text(
                      'Suscripción · En construcción',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Con una suscripción activa podrás aceptar más reservas. Las solicitudes pendientes requerirán tu confirmación; no se aceptarán automáticamente.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Estamos definiendo el precio, la renovación y el proveedor de pago. No se realizarán cobros ni se simularán suscripciones.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
