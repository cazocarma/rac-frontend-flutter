import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'features/staff/staff_screen.dart';
import 'features/documents/ui/document_history_screen.dart';
import 'features/compa_onboarding/ui/assessment_screen.dart';
import 'features/match/ui/time_off_screen.dart';
import 'features/documents/ui/documents_screen.dart';
import 'features/admin/ui/admin_screen.dart';
import 'shared/services/session.dart';
import 'package:flutter/material.dart';
import 'features/chat/ui/chat_screen.dart';
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
  List<(String, IconData, String)> destinations(BuildContext context) => [
    (AppLocalizations.of(context)!.navExplore, Icons.explore_outlined, '/home'),
    (
      AppLocalizations.of(context)!.navBookings,
      Icons.calendar_month_outlined,
      '/match',
    ),
    (
      AppLocalizations.of(context)!.navMessages,
      Icons.chat_bubble_outline,
      '/chat',
    ),
    (
      AppLocalizations.of(context)!.compaTitle,
      Icons.auto_awesome_outlined,
      '/become-compa',
    ),
    (
      AppLocalizations.of(context)!.navPayments,
      Icons.wallet_outlined,
      '/payments',
    ),
    (
      AppLocalizations.of(context)!.navNotifications,
      Icons.notifications_outlined,
      '/alerts',
    ),
    (
      AppLocalizations.of(context)!.navProfile,
      Icons.person_outline,
      '/profile',
    ),
    (AppLocalizations.of(context)!.settingsTitle, Icons.tune, '/settings'),
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
          AppLocalizations.of(context)!.navTagline,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 14),
        child: Text(
          AppLocalizations.of(context)!.navSpace,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      for (final d in destinations(context))
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
      FutureBuilder<String>(
        future: Session.role(),
        builder: (context, snapshot) => snapshot.data == 'admin'
            ? ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(AppLocalizations.of(context)!.navAdmin),
                onTap: () {
                  if (MediaQuery.sizeOf(context).width < 1000) {
                    Navigator.pop(context);
                  }
                  open(context, '/admin');
                },
              )
            : const SizedBox.shrink(),
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
            Text(
              AppLocalizations.of(context)!.navShare,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.navProfileInfo,
              style: const TextStyle(fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
      const Divider(height: 32),
      ListTile(
        leading: const Icon(Icons.logout, size: 20),
        title: Text(
          AppLocalizations.of(context)!.navLogout,
          style: const TextStyle(fontSize: 13),
        ),
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
          title: wide
              ? Text(AppLocalizations.of(context)!.navExploreTitle)
              : const RacBrand(),
          actions: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.navOpenNotifications,
              onPressed: () => open(context, '/alerts'),
              icon: const Icon(Icons.notifications_outlined),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context)!.navProfile,
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
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.explore_outlined),
                    label: AppLocalizations.of(context)!.navExplore,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: AppLocalizations.of(context)!.navBookingsShort,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: AppLocalizations.of(context)!.navMessages,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    label: AppLocalizations.of(context)!.navProfileShort,
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
  '/staff': (_) => StaffScreen.connected(),
  '/login': (_) => const UnifiedAuthScreen(),
  '/home': (_) => const HomeShell(),
  '/match': (_) => const MatchScreen(),
  '/profile': (_) => const ProfileScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/document-history': (_) => const AuthGuard(child: DocumentHistoryScreen()),
  '/documents': (_) => const AuthGuard(child: DocumentsScreen()),
  '/compa-rules': (_) => const AuthGuard(child: AssessmentScreen()),
  '/become-compa': (_) => const BecomeCompaScreen(),
  '/chat': (_) => const AuthGuard(child: ChatListScreen()),
  '/payments': (_) => const PlansScreen(),
  '/time-off': (_) => const AuthGuard(child: TimeOffScreen()),
  '/admin': (_) => const AuthGuard(child: AdminScreen()),
  '/alerts': (_) => const NotificationsScreen(),
};
