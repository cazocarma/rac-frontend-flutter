import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/brand.dart';
import '../../../shared/widgets/weekly_allowance.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Planes y suscripción')),
    body: SingleChildScrollView(
      child: PageContent(
        width: 960,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageIntro(
              eyebrow: 'A tu ritmo',
              title: 'Empieza gratis. Crece a tu ritmo.',
              description:
                  'La suscripción amplía tu capacidad para aceptar reservas como compa.',
            ),
            const WeeklyAllowance(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final free = _plan(context, false);
                final paid = _plan(context, true);
                return constraints.maxWidth >= 700
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: free),
                          const SizedBox(width: 20),
                          Expanded(child: paid),
                        ],
                      )
                    : Column(
                        children: [free, const SizedBox(height: 20), paid],
                      );
              },
            ),
            const SizedBox(height: 24),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Las solicitudes que superen tu cupo permanecen pendientes. Tú decides cuáles confirmar cuando tengas capacidad disponible.',
                    style: TextStyle(height: 1.6, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _plan(BuildContext context, bool paid) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                paid ? Icons.auto_awesome_outlined : Icons.wb_sunny_outlined,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              paid ? 'Más espacio para crecer' : 'Plan gratuito',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              paid ? 'En construcción' : '\$0',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paid
                  ? 'Estamos preparando la suscripción.'
                  : '3 reservas por semana',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 36),
            if (!paid) ...[
              _feature(context, 'Recibe solicitudes sin límite de cupos.'),
              _feature(context, 'Confirma hasta 3 reservas cada semana.'),
              _feature(context, 'Publica tu perfil y administra tu agenda.'),
              const SizedBox(height: 12),
              const Text(
                'El cupo se calcula de lunes a domingo, según la fecha de la actividad y la zona horaria de Chile. Si cancelas antes del inicio, recuperas el cupo; después del inicio, se mantiene consumido.',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
            ] else ...[
              _feature(
                context,
                'Acepta más reservas con una suscripción activa.',
              ),
              _feature(
                context,
                'Conserva el control de tus solicitudes pendientes.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Estamos definiendo el precio, la renovación y el proveedor de pago. No se realizarán cobros ni se simularán suscripciones. Tus solicitudes no se aceptarán automáticamente.',
                style: TextStyle(fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Chip(
                avatar: Icon(Icons.handyman_outlined, size: 16),
                label: Text('Pagos en construcción'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feature(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
        ),
      ],
    ),
  );
}
