import 'package:flutter/material.dart';
import '../../../shared/di/services.dart';
import '../../../shared/widgets/design.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = Services.user.me();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi perfil')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            title: 'No pudimos cargar tu cuenta',
            message: 'Inténtalo nuevamente.',
            action: OutlinedButton(
              onPressed: () => setState(() => data = Services.user.me()),
              child: const Text('Reintentar'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final me = snapshot.data!;
        final name = me['nombre'] as String? ?? 'Usuario';
        return SingleChildScrollView(
          child: PageContent(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu espacio en RAC',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          child: Text(
                            name.isEmpty ? '?' : name[0],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Correo de tu cuenta'),
                          subtitle: Text(me['correo'] as String? ?? ''),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.verified_user_outlined),
                          title: const Text('Tipo de cuenta'),
                          subtitle: Text(
                            {
                                  'cliente': 'Usuario base',
                                  'compa': 'Compa',
                                  'admin': 'Administrador',
                                }[me['role']] ??
                                'Usuario base',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: Icon(Icons.handyman_outlined),
                    title: Text('Edición de perfil · En construcción'),
                    subtitle: Text(
                      'La edición de datos, biografía y foto estará disponible aquí. Los datos mostrados vienen de tu cuenta autenticada.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/match'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Ver mis reservas'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
