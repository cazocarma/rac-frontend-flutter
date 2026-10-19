// Limpieza de duplicados: se mantiene solo la versión con ThemeController
import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/services/theme.dart';
import 'app_routes.dart';
import 'shared/widgets/design.dart';
import 'shared/config/env.dart';

/// Punto de entrada principal de la aplicación Rent-a-Compa.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture before MaterialApp installs its startup route and updates the URL.
  final requestedRoute = Uri.base.hasFragment
      ? Uri.base.fragment
      : WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  await Env.load();
  await Session.clearLegacyTokens();
  Services.init(); // Inicializa AuthApi, CompaApi.
  await appTheme.load();
  runApp(RACApp(theme: appTheme, requestedRoute: requestedRoute));
}

/// Widget raíz de la aplicación.
///
/// Configura temas, rutas y la detección automática de sesión al inicio.
class RACApp extends StatelessWidget {
  const RACApp({super.key, required this.theme, this.requestedRoute = '/'});
  final ThemeController theme;
  final String requestedRoute;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return MaterialApp(
          title: 'Rent-a-Compa',
          debugShowCheckedModeBanner: false,
          theme: racTheme(Brightness.light),
          darkTheme: racTheme(Brightness.dark),
          themeMode: theme.mode,
          routes: buildRoutes(requestedRoute: requestedRoute),
          // Ruta inicial que decide si ir a login o home según tokens existentes.
          initialRoute: '/',
        );
      },
    );
  }
}

/// Puerta de arranque inicial.
///
/// Determina si redirigir al usuario a `/home` (si hay sesión)
/// o al `/login` (si no hay sesión activa).
class StartupGate extends StatefulWidget {
  const StartupGate({super.key, this.requestedRoute = '/'});
  final String requestedRoute;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  /// Verifica el estado de sesión y redirige a la ruta correspondiente.
  Future<void> _decide() async {
    final requestedPath = Uri.tryParse(widget.requestedRoute)?.path;
    bool logged = false;
    try {
      logged = await Session.isLoggedIn();
      if (logged) await Services.user.me();
    } catch (_) {
      await Session.clear();
      logged = false;
    }
    if (!mounted) return;
    if (logged) {
      final destination =
          buildRoutes().containsKey(requestedPath) &&
              requestedPath != '/' &&
              requestedPath != '/login'
          ? requestedPath!
          : '/home';
      Navigator.of(context).pushReplacementNamed(destination);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
