import 'package:flutter/material.dart';
import 'package:rentacompa/shared/guards/auth_guard.dart';
import 'package:rentacompa/shared/services/logout.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';
import 'package:rentacompa/features/match/ui/match_screen.dart';
import 'package:rentacompa/features/compa_onboarding/ui/become_compa_screen.dart';
import 'main.dart';

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
              const DrawerHeader(child: Text('Menú', style: TextStyle(fontSize: 18))),
              ListTile(leading: const Icon(Icons.group), title: const Text('Compas'),
                onTap: () => Navigator.of(context).pushReplacementNamed('/home')),
              ListTile(leading: const Icon(Icons.calendar_month), title: const Text('Match / Agenda'),
                onTap: () => Navigator.of(context).pushReplacementNamed('/match')),
              ListTile(leading: const Icon(Icons.star), title: const Text('Sé Compa'),
                onTap: () => Navigator.of(context).pushReplacementNamed('/become-compa')),
              const Divider(),
              ListTile(leading: const Icon(Icons.chat), title: const Text('Chat (próximo hito)')),
              ListTile(leading: const Icon(Icons.calendar_month), title: const Text('Match/Agenda (próximo hito)')),
              ListTile(leading: const Icon(Icons.payment), title: const Text('Pagos (próximo hito)')),
              ListTile(leading: const Icon(Icons.warning_amber_rounded), title: const Text('Alertas (próximo hito)')),
              const Divider(),
              ListTile(leading: const Icon(Icons.logout), title: const Text('Salir'),
                onTap: () => performLogout(context)),
            ],
          ),
        ),
        body: const Padding(padding: EdgeInsets.all(12), child: CompaListScreen()),
      ),
    );
  }
}

Map<String, WidgetBuilder> buildRoutes() {
  return {
    '/': (_) => const StartupGate(),
    '/login': (_) => const UnifiedAuthScreen(),
    '/home': (_) => const HomeShell(),
    '/match': (_) => const MatchScreen(),
    '/become-compa': (_) => const BecomeCompaScreen(),
  };
}
