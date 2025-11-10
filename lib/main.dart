import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'app_routes.dart';

/// Punto de entrada principal de la aplicación Rent-a-Compa.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Services.init(); // Inicializa AuthApi, CompaApi, MatchApi y UserApi.
  runApp(const RACApp());
}

/// Widget raíz de la aplicación.
///
/// Configura temas, rutas y la detección automática de sesión al inicio.
class RACApp extends StatelessWidget {
  const RACApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent-a-Compa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Detecta el tema del sistema.
      routes: buildRoutes(),
      // Ruta inicial que decide si ir a login o home según tokens existentes.
      initialRoute: '/',
    );
  }
}

/// Puerta de arranque inicial.
///
/// Determina si redirigir al usuario a `/home` (si hay sesión)
/// o al `/login` (si no hay sesión activa).
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

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
    final logged = await Session.isLoggedIn();
    if (!mounted) return;
    if (logged) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
