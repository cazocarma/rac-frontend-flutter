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
import 'shared/widgets/brand.dart';
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
    padding: const EdgeInsets.all(18),
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 8),
        child: RacBrand(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
        child: Text(
          'Tiempo para compartir.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 14),
        child: Text(
          'TU ESPACIO',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      for (final d in destinations)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: ListTile(
            dense: true,
            minVerticalPadding: 14,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            selected: d.$3 == '/home',
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            leading: Icon(d.$2, size: 21),
            title: Text(
              d.$1,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              if (MediaQuery.sizeOf(context).width < 1000) {
                Navigator.pop(context);
              }
              open(context, d.$3);
            },
          ),
        ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Comparte lo que te gusta',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'Publica tu perfil de compa y empieza con 3 reservas gratis por semana.',
              style: TextStyle(fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
      const Divider(height: 32),
      ListTile(
        leading: const Icon(Icons.logout, size: 20),
        title: const Text('Salir', style: TextStyle(fontSize: 13)),
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
          title: wide ? const Text('Explorar compas') : const RacBrand(),
          actions: [
            IconButton(
              tooltip: 'Ver notificaciones',
              onPressed: () => open(context, '/alerts'),
              icon: const Icon(Icons.notifications_outlined),
            ),
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
            if (wide)
              Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: menu(context),
              ),
            const Expanded(child: PageContent(child: CompaListScreen())),
          ],
        ),
      ),
    );
  }
}

Map<String, WidgetBuilder> buildRoutes({String requestedRoute = '/'}) => {
  '/': (_) => StartupGate(requestedRoute: requestedRoute),
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
