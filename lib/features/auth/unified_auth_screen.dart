import 'package:flutter/material.dart';
import '../../shared/di/services.dart';
import '../../shared/services/auth_api.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key, this.auth});
  final AuthApi? auth;
  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> {
  bool loading = false;
  String? error;
  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await (widget.auth ?? Services.auth).login();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'No pudimos iniciar sesión. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 600 ? 24 : 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: colors.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Rent-A-Compa',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Chip(label: Text('Bienvenido')),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Más planes.\nMás conexiones.\nMás historias.',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              color: colors.primary,
                            ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Encuentra compañía para compartir lo que te gusta. Desde una salida al cine hasta tu próxima aventura.',
                      ),
                      const SizedBox(height: 24),
                      const Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: Icon(Icons.movie_outlined, size: 18),
                            label: Text('Cine'),
                          ),
                          Chip(
                            avatar: Icon(Icons.directions_run, size: 18),
                            label: Text('Running'),
                          ),
                          Chip(
                            avatar: Icon(Icons.mic_none, size: 18),
                            label: Text('Karaoke'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: loading ? null : login,
                          icon: Icon(
                            loading ? Icons.hourglass_top : Icons.arrow_forward,
                          ),
                          label: Text(
                            loading
                                ? 'Abriendo inicio de sesión…'
                                : 'Ingresar o crear cuenta',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu cuenta, protegida. Al ingresar, volverás aquí automáticamente.',
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            error!,
                            style: TextStyle(color: colors.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
