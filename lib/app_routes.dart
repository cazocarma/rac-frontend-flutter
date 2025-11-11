import 'package:flutter/material.dart';
import 'package:rentacompa/shared/guards/auth_guard.dart';
import 'package:rentacompa/shared/services/logout.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';
import 'package:rentacompa/features/match/ui/match_screen.dart';
import 'package:rentacompa/features/compa_onboarding/ui/become_compa_screen.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/features/settings/ui/settings_screen.dart';
import 'main.dart';
import 'package:rentacompa/shared/services/theme.dart';

/// Pantalla principal (shell) de la aplicación Rent-a-Compa.
///
/// Contiene el menú lateral y enruta hacia las secciones principales
/// (lista de compas, agenda/match, onboarding de compas, etc.).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rent-a-Compa'),
          actions: [
            Builder(builder: (context) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      Navigator.of(context).pushNamed('/profile');
                      break;
                    case 'settings':
                      Navigator.of(context).pushNamed('/settings');
                      break;
                    case 'match':
                      Navigator.of(context).pushNamed('/match');
                      break;
                    case 'dark_toggle':
                      // Alterna entre claro y oscuro, persiste
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      await appTheme.toggleDark(!isDark);
                      break;
                    case 'logout':
                      performLogout(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'profile', child: Text('Perfil')),
                  const PopupMenuItem(value: 'settings', child: Text('Configuración')),
                  const PopupMenuItem(value: 'match', child: Text('Match / Agenda')),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'dark_toggle',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Modo oscuro'),
                        Switch(
                          value: Theme.of(context).brightness == Brightness.dark,
                          onChanged: (v) async {
                            await appTheme.toggleDark(v);
                            Navigator.pop(context); // cerrar menú tras cambio
                          },
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'logout', child: Text('Salir')),
                ],
              );
            }),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Menú', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Compas'),
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Match / Agenda'),
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/match'),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Sé Compa'),
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/become-compa'),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat (próximo hito)'),
              ),
              const ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text('Match/Agenda (próximo hito)'),
              ),
              const ListTile(
                leading: Icon(Icons.payment),
                title: Text('Pagos (próximo hito)'),
              ),
              const ListTile(
                leading: Icon(Icons.warning_amber_rounded),
                title: Text('Alertas (próximo hito)'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Salir'),
                onTap: () => performLogout(context),
              ),
            ],
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(12),
          child: CompaListScreen(),
        ),
      ),
    );
  }
}

/// Define las rutas principales de la aplicación.
///
/// Retorna un mapa de rutas usado por `MaterialApp` en `main.dart`.
Map<String, WidgetBuilder> buildRoutes() {
  return {
    '/': (_) => const StartupGate(),
    '/login': (_) => const UnifiedAuthScreen(),
    '/home': (_) => const HomeShell(),
    '/match': (_) => const MatchScreen(),
    '/become-compa': (_) => const BecomeCompaScreen(),
    '/profile': (_) => const ProfileScreen(),
    '/settings': (_) => const SettingsScreen(),
  };
}
