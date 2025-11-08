import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/guards/auth_guard.dart';
import 'package:rentacompa/shared/services/logout.dart';
import 'package:rentacompa/features/auth/login_screen.dart';
import 'package:rentacompa/features/auth/register_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Rent-a-Compa')),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Menú', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Compas'),
                onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat (próximo hito)'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Match/Agenda (próximo hito)'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Pagos (próximo hito)'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: const Text('Alertas (próximo hito)'),
                onTap: () {},
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

Map<String, WidgetBuilder> buildRoutes() {
  return {
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/home': (_) => const HomeShell(),
  };
}