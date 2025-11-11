import 'package:flutter/material.dart';
import 'package:rentacompa/shared/services/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: isDark,
            onChanged: (v) => appTheme.toggleDark(v),
          ),
          const ListTile(
            title: Text('Otras opciones'),
            subtitle: Text('Stub pendiente de implementar'),
          ),
        ],
      ),
    );
  }
}

