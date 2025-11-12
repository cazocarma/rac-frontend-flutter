import 'package:flutter/material.dart';
import 'package:rentacompa/shared/widgets/modal_shell.dart';

class BecomeCompaScreen extends StatelessWidget {
  const BecomeCompaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Sé Compa'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Comparte tu talento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Rent-a-Compa conecta anfitriones locales con personas que buscan experiencias auténticas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _StatCard(
              title: 'Clientes felices',
              value: '1.200+',
              icon: Icons.emoji_emotions,
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Promedio por hora',
              value: '\$18.000 CLP',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 24),
            Text('Cómo funciona',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const _StepTile(
              step: 1,
              title: 'Completa tu perfil',
              description:
                  'Sube fotos, describe tus habilidades y define las experiencias que ofreces.',
            ),
            const _StepTile(
              step: 2,
              title: 'Activa tu disponibilidad',
              description:
                  'Indica horarios y zonas donde aceptas solicitudes. Recibirás alertas en Match.',
            ),
            const _StepTile(
              step: 3,
              title: 'Acepta y agenda',
              description:
                  'Confirma las solicitudes que te interesen y coordina los detalles en la app.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Actualizar mi perfil'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/match'),
              icon: const Icon(Icons.calendar_today),
              label: const Text('Ver agenda'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.title,
    required this.description,
  });

  final int step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(step.toString()),
      ),
      title: Text(title),
      subtitle: Text(description),
    );
  }
}
