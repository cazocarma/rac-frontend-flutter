import 'package:flutter/material.dart';
import 'shared/config/env.dart';
import 'features/compas/data/compa_api.dart';
import 'features/compas/ui/compa_list_screen.dart';

void main() {
  runApp(const RACApp());
}

class RACApp extends StatelessWidget {
  const RACApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = CompaApi(Env.apiBase); // ej: http://localhost (NGINX)
    return MaterialApp(
      title: 'Rent-a-Compa',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: CompaListScreen(api: api),
    );
  }
}
