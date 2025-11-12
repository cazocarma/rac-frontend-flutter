import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/features/compa_onboarding/ui/become_compa_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';
import 'package:rentacompa/features/match/ui/match_screen.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/features/settings/ui/settings_screen.dart';
import 'package:rentacompa/shared/guards/auth_guard.dart';
import 'package:rentacompa/shared/services/logout.dart';
import 'package:rentacompa/shared/services/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

/// Pantalla principal (shell) de la aplicación Rent-a-Compa.
///
/// Contiene el menú lateral y enruta hacia las secciones principales
/// (lista de compas, agenda/match, onboarding de compas, etc.).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  String _displayName = 'Usuario';
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadUserSummary();
  }

  Future<void> _loadUserSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('profile_name')?.trim();
    final encodedAvatar = prefs.getString('profile_photo');
    Uint8List? avatar;
    if (encodedAvatar != null && encodedAvatar.isNotEmpty) {
      try {
        avatar = base64Decode(encodedAvatar);
      } catch (_) {
        avatar = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _displayName = (storedName != null && storedName.isNotEmpty)
          ? storedName
          : 'Usuario';
      _avatarBytes = avatar;
    });
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'profile':
        await _navigateAndRefresh('/profile');
        break;
      case 'settings':
        await _navigateAndRefresh('/settings');
        break;
      case 'match':
        await Navigator.of(context).pushNamed('/match');
        break;
      case 'dark_toggle':
        final isDark = Theme.of(context).brightness == Brightness.dark;
        await appTheme.toggleDark(!isDark);
        break;
      case 'logout':
        performLogout(context);
        break;
    }
  }

  Future<void> _navigateAndRefresh(String route) async {
    await Navigator.of(context).pushNamed(route);
    await _loadUserSummary();
  }

  String get _initials {
    final trimmed = _displayName.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    String buildInitial(String word) =>
        word.isNotEmpty ? word[0].toUpperCase() : '';
    final first = buildInitial(parts.first);
    final last = buildInitial(parts.length > 1 ? parts.last : parts.first);
    final raw = (first + last).trim();
    if (raw.isEmpty) return 'U';
    return raw.length == 1 ? raw : raw.substring(0, 2);
  }

  Widget _buildAccountMenuButton(BuildContext context) {
    final avatar = _avatarBytes;
    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      onSelected: (value) {
        _handleMenuSelection(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: avatar != null ? MemoryImage(avatar) : null,
              child: avatar == null ? Text(_initials) : null,
            ),
            title: Text(_displayName),
            subtitle: const Text('Cuenta'),
          ),
        ),
        const PopupMenuDivider(),
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
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'logout', child: Text('Salir')),
      ],
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: avatar != null ? MemoryImage(avatar) : null,
              child: avatar == null
                  ? Text(
                      _initials,
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rent-a-Compa'),
          actions: [
            Builder(
              builder: (context) => _buildAccountMenuButton(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                      child: _avatarBytes == null
                          ? Text(
                              _initials,
                              style: const TextStyle(fontSize: 20),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _displayName,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Compas'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Match / Agenda'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/match');
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Sé Compa'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/become-compa');
                },
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
