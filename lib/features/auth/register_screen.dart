import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/config/env.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'cliente';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerBackend() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Services.auth.register(
        username: _userCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        role: _role,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada. Inicia sesión.')));
        Navigator.of(context).pop(); // volver a login
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _registerKeycloak() async {
    const realm = 'rentacompa';
    const clientId = 'frontend';
    final redirectUri = Uri.encodeComponent(_defaultRedirect());
    final url = '${Env.keycloakPublicUrl}/realms/$realm/protocol/openid-connect/registrations'
                '?client_id=$clientId&response_type=code&scope=openid&redirect_uri=$redirectUri';
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) setState(() { _error = 'No se pudo abrir el registro de Keycloak'; });
  }

  String _defaultRedirect() {
    if (kIsWeb) return Uri.base.origin; // ej: http://localhost
    return 'rentacompa://callback';     // para mobile más adelante
  }

  @override
  Widget build(BuildContext context) {
    // Cambia a true si expones /register en backend-auth
    const backendRegisterAvailable = false;

    final routeRole = ModalRoute.of(context)?.settings.arguments;
    if (routeRole is String && (routeRole == 'cliente' || routeRole == 'compa')) {
      _role = routeRole;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToggleButtons(
                      isSelected: [_role=='cliente', _role=='compa'],
                      onPressed: (i) => setState(() { _role = i==0 ? 'cliente' : 'compa'; }),
                      children: const [
                        Padding(padding: EdgeInsets.all(8), child: Text('Cliente')),
                        Padding(padding: EdgeInsets.all(8), child: Text('Compa'))
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                      validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => (v==null || !v.contains('@')) ? 'Email inválido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (v) => (v==null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () async {
                          if (!_form.currentState!.validate()) return;
                          if (backendRegisterAvailable) {
                            await _registerBackend();
                          } else {
                            await _registerKeycloak();
                          }
                        },
                        child: _loading
                          ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(backendRegisterAvailable ? 'Crear cuenta' : 'Abrir registro de Keycloak'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
