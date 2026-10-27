import 'features/documents/ui/document_prompt_host.dart';
import 'l10n/generated/app_localizations.dart';
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
class RACApp extends StatefulWidget {
  const RACApp({super.key, required this.theme, this.requestedRoute = '/'});
  final ThemeController theme;
  final String requestedRoute;

  @override
  State<RACApp> createState() => _RACAppState();
}

class _RACAppState extends State<RACApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.theme,
      builder: (context, _) {
        return DocumentPromptHost(
          navigatorKey: navigatorKey,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            title: 'Rent-a-Compa',
            debugShowCheckedModeBanner: false,
            theme: racTheme(Brightness.light),
            darkTheme: racTheme(Brightness.dark),
            themeMode: widget.theme.mode,
            routes: buildRoutes(requestedRoute: widget.requestedRoute),
            // Ruta inicial que decide si ir a login o home según tokens existentes.
            initialRoute: '/',
          ),
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
  const StartupGate({super.key, this.requestedRoute = '/', this.checkSession});
  final String requestedRoute;
  final Future<bool> Function()? checkSession;

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
      if (widget.checkSession != null) {
        logged = await widget.checkSession!();
      } else {
        logged = await Session.isLoggedIn();
        if (logged) await Services.user.me();
      }
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
      final navigator = Navigator.of(context);
      // A direct URL needs a real home route underneath it; otherwise Back
      // after a page reload can remove the only page and leave a blank app.
      navigator.pushReplacementNamed('/home');
      if (destination != '/home') {
        navigator.pushNamed(destination);
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
