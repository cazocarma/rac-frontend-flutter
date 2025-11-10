import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Services.init(); // inicializa AuthApi y CompaApi
  runApp(const RACApp());
}

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
      themeMode: ThemeMode.system, // detecta configuracion del sistema
      routes: buildRoutes(),
      // Ruta inicial que decide si ir a login u home segun tokens existentes
      initialRoute: '/',
    );
  }
}

/// Puerta de arranque: redirige a /home si hay sesion, de lo contrario a /login
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
