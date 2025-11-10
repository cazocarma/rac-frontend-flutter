import 'package:flutter/material.dart';

class BecomeCompaScreen extends StatelessWidget {
  const BecomeCompaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sé Compa')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gana dinero siendo buena compañía',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comparte tu tiempo, habilidades y buena onda. '
                'Define tu disponibilidad, tarifas y recibe reservas con '
                'protección y pagos seguros.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _Benefit(
                    icon: Icons.schedule,
                    title: 'Agenda flexible',
                    desc: 'Tú eliges cuándo estás disponible.',
                  ),
                  _Benefit(
                    icon: Icons.star,
                    title: 'Valoraciones',
                    desc: 'Construye tu reputación y gana más.',
                  ),
                  _Benefit(
                    icon: Icons.security,
                    title: 'Protección',
                    desc: 'Pagos confiables y botón de ayuda.',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '¿Cómo empiezo?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1) Crea tu cuenta o inicia sesión.\n'
                        '2) Completa tu perfil con foto, descripción y habilidades.\n'
                        '3) Configura tu disponibilidad.\n'
                        '4) ¡Listo! Empieza a recibir reservas.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Próximamente'),
                      content: Text(
                        'El registro completo de compas se habilitará tras '
                        'verificación de perfil. Por ahora, completa tu perfil '
                        'y disponibilidad desde el menú.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Quiero ser Compa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(desc),
            ],
          ),
        ),
      ),
    );
  }
}
