import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'app_routes.dart';

void main() {
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      routes: buildRoutes(),
      initialRoute: '/login',
    );
  }
}
