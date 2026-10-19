import 'package:flutter/material.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';
import 'package:rentacompa/features/match/ui/match_screen.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/features/settings/ui/settings_screen.dart';
import 'package:rentacompa/shared/guards/auth_guard.dart';
import 'package:rentacompa/shared/services/logout.dart';
import 'package:rentacompa/shared/widgets/design.dart';
import 'main.dart';
import 'features/plans/ui/plans_screen.dart';
import 'features/alerts/ui/notifications_screen.dart';
import 'features/compa_onboarding/ui/become_compa_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});
  static const destinations = [
    ('Explorar', Icons.explore_outlined, '/home'),
    ('Mis reservas', Icons.calendar_month_outlined, '/match'),
    ('Mensajes', Icons.chat_bubble_outline, '/chat'),
    ('Sé Compa', Icons.auto_awesome_outlined, '/become-compa'),
    ('Planes y pagos', Icons.wallet_outlined, '/payments'),
    ('Notificaciones', Icons.notifications_outlined, '/alerts'),
    ('Mi perfil', Icons.person_outline, '/profile'),
    ('Configuración', Icons.tune, '/settings'),
  ];
  void open(BuildContext context, String route) {
    if (route != '/home') Navigator.of(context).pushNamed(route);
  }

  Widget menu(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        child: Row(
          children: [
            Icon(
              Icons.people_alt_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text('RAC', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
      for (final d in destinations)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            selected: d.$3 == '/home',
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            leading: Icon(d.$2),
            title: Text(d.$1),
            onTap: () {
              if (MediaQuery.sizeOf(context).width < 1000) {
                Navigator.pop(context);
              }
              open(context, d.$3);
            },
          ),
        ),
      const Divider(height: 32),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Salir'),
        onTap: () => performLogout(context),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rent-a-Compa'),
          actions: [
            IconButton(
              tooltip: 'Mi perfil',
              onPressed: () => open(context, '/profile'),
              icon: const Icon(Icons.account_circle_outlined),
            ),
            const SizedBox(width: 12),
          ],
        ),
        drawer: wide ? null : Drawer(child: menu(context)),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: 0,
                onDestinationSelected: (i) =>
                    open(context, ['/home', '/match', '/chat', '/profile'][i]),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    label: 'Explorar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    label: 'Reservas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline),
                    label: 'Mensajes',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Perfil',
                  ),
                ],
              ),
        body: Row(
          children: [
            if (wide) SizedBox(width: 250, child: menu(context)),
            const Expanded(child: PageContent(child: CompaListScreen())),
          ],
        ),
      ),
    );
  }
}

Map<String, WidgetBuilder> buildRoutes() => {
  '/': (_) => const StartupGate(),
  '/login': (_) => const UnifiedAuthScreen(),
  '/home': (_) => const HomeShell(),
  '/match': (_) => const MatchScreen(),
  '/profile': (_) => const ProfileScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/become-compa': (_) => const BecomeCompaScreen(),
  '/chat': (_) => const ConstructionScreen(title: 'Mensajes'),
  '/payments': (_) => const PlansScreen(),
  '/alerts': (_) => const NotificationsScreen(),
};
