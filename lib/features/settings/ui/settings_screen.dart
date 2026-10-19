import 'package:flutter/material.dart';
import '../../../shared/services/theme.dart';
import '../../../shared/widgets/design.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configuración')),
    body: SingleChildScrollView(
      child: PageContent(
        width: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A tu manera',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Personaliza cómo se ve RAC en este dispositivo.'),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.palette_outlined),
                      title: Text('Apariencia'),
                    ),
                    for (final mode in ThemeMode.values)
                      ListTile(
                        leading: Icon(
                          appTheme.mode == mode
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(switch (mode) {
                          ThemeMode.system =>
                            'Usar configuración del dispositivo',
                          ThemeMode.light => 'Claro',
                          ThemeMode.dark => 'Oscuro',
                        }),
                        onTap: () => appTheme.setMode(mode),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(20),
                leading: Icon(Icons.handyman_outlined),
                title: Text('En construcción'),
                subtitle: Text(
                  'Preferencias de notificaciones, privacidad e idioma.',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
