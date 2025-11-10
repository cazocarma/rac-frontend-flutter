import 'dart:async';
import 'dart:html' as html; // solo web
import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key});

  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // login
  final _loginForm = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // register (extended)
  final _regForm = GlobalKey<FormState>();
  final _rNombreCtrl = TextEditingController();
  final _rEmailCtrl = TextEditingController();
  final _rPassCtrl = TextEditingController();
  final _rFechaNacCtrl = TextEditingController();
  String? _rGenero; // masculino,femenino,otro,prefiero_no_decir
  final _rTelefonoCtrl = TextEditingController();
  final _rPaisCtrl = TextEditingController();
  final _rRegionCtrl = TextEditingController();
  final _rCiudadCtrl = TextEditingController();
  final _rDireccionCtrl = TextEditingController();
  final _rInteresesCtrl = TextEditingController(); // comma-separated
  final _rIdiomaCtrl = TextEditingController();
  bool _rNotif = true;
  bool _rTOS = false;
  bool _rPrivacy = false;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();

    _rNombreCtrl.dispose();
    _rEmailCtrl.dispose();
    _rPassCtrl.dispose();
    _rFechaNacCtrl.dispose();
    _rTelefonoCtrl.dispose();
    _rPaisCtrl.dispose();
    _rRegionCtrl.dispose();
    _rCiudadCtrl.dispose();
    _rDireccionCtrl.dispose();
    _rInteresesCtrl.dispose();
    _rIdiomaCtrl.dispose();

    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Services.auth
          .login(username: _userCtrl.text.trim(), password: _passCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doRegister() async {
    if (!_regForm.currentState!.validate()) return;
    if (!_rTOS || !_rPrivacy) {
      setState(() {
        _error =
            'Debes aceptar los términos y condiciones y la política de privacidad.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Crear cuenta en Auth
      await Services.auth.register(
        username: _rEmailCtrl.text.trim(),
        email: _rEmailCtrl.text.trim(),
        password: _rPassCtrl.text.trim(),
      );

      if (!mounted) return;

      // 2) Enviar perfil extendido al User Service
      try {
        final intereses = _rInteresesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await Services.user.upsertProfile({
          'nombre': _rNombreCtrl.text.trim(),
          'correo': _rEmailCtrl.text.trim(),
          'fecha_nacimiento': _rFechaNacCtrl.text.trim(),
          'genero': _rGenero,
          'telefono': _rTelefonoCtrl.text.trim(),
          'pais': _rPaisCtrl.text.trim(),
          'region': _rRegionCtrl.text.trim(),
          'ciudad': _rCiudadCtrl.text.trim(),
          'direccion':
              _rDireccionCtrl.text.isNotEmpty ? _rDireccionCtrl.text.trim() : null,
          'intereses': intereses,
          'idioma_preferido':
              _rIdiomaCtrl.text.isNotEmpty ? _rIdiomaCtrl.text.trim() : null,
          'notificaciones_activadas': _rNotif,
          'foto_perfil': null,
          'ubicacion': null,
          'radio_busqueda_km': null,
        });
      } catch (_) {
        // si falla, no interrumpe el alta de cuenta
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Inicia sesión.')),
      );
      _tab.animateTo(0);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _social(String provider) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final start = await Services.auth.oauthStart(provider);
      final authUrl = start['auth_url']!;
      final state = start['state']!;

      // abre popup
      final popup = html.window.open(
        authUrl,
        '_blank',
        'width=600,height=700,menubar=no,toolbar=no,location=no,status=no',
      );

      // polling simple para consumir
      bool done = false;
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        try {
          await Services.auth.oauthConsume(provider, state);
          done = true;
          break;
        } catch (_) {
          // aún no listo
        }
      }

      popup?.close();
      if (!done) throw Exception('Tiempo agotado en autenticación social');

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _loginTab() {
    return Form(
      key: _loginForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: 'Usuario o email'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _doLogin,
            child: const Text('Entrar'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Google'),
                  onPressed: _loading ? null : () => _social('google'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.code),
                  label: const Text('GitHub'),
                  onPressed: _loading ? null : () => _social('github'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    }

  Widget _registerTab() {
    return Form(
      key: _regForm,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Nombre
            TextFormField(
              controller: _rNombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Email
            TextFormField(
              controller: _rEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _rPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),

            // Fecha de nacimiento
            TextFormField(
              controller: _rFechaNacCtrl,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Fecha de nacimiento'),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(now.year - 18, now.month, now.day),
                  firstDate: DateTime(1900),
                  lastDate: now,
                );
                if (picked != null) {
                  setState(() {
                    _rFechaNacCtrl.text =
                        picked.toIso8601String().split('T').first;
                  });
                }
              },
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Género
            DropdownButtonFormField<String>(
              value: _rGenero,
              decoration:
                  const InputDecoration(labelText: 'Género (opcional)'),
              items: const [
                DropdownMenuItem(
                    value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
                DropdownMenuItem(
                    value: 'prefiero_no_decir',
                    child: Text('Prefiero no decir')),
              ],
              onChanged: (v) => setState(() => _rGenero = v),
            ),
            const SizedBox(height: 12),

            // Teléfono
            TextFormField(
              controller: _rTelefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // País
            TextFormField(
              controller: _rPaisCtrl,
              decoration: const InputDecoration(labelText: 'País'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            // Región / Ciudad
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rRegionCtrl,
                    decoration: const InputDecoration(labelText: 'Región'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rCiudadCtrl,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dirección (opcional)
            TextFormField(
              controller: _rDireccionCtrl,
              decoration:
                  const InputDecoration(labelText: 'Dirección (opcional)'),
            ),
            const SizedBox(height: 12),

            // Intereses (opcional)
            TextFormField(
              controller: _rInteresesCtrl,
              decoration: const InputDecoration(
                labelText: 'Intereses (separados por coma)',
              ),
            ),
            const SizedBox(height: 12),

            // Idioma preferido (opcional)
            TextFormField(
              controller: _rIdiomaCtrl,
              decoration:
                  const InputDecoration(labelText: 'Idioma preferido'),
            ),
            const SizedBox(height: 12),

            // Notificaciones + consentimientos
            SwitchListTile(
              value: _rNotif,
              onChanged: (v) => setState(() => _rNotif = v),
              title: const Text('Activar notificaciones'),
            ),
            CheckboxListTile(
              value: _rTOS,
              onChanged: (v) => setState(() => _rTOS = v ?? false),
              title: const Text('Acepto términos y condiciones'),
            ),
            CheckboxListTile(
              value: _rPrivacy,
              onChanged: (v) => setState(() => _rPrivacy = v ?? false),
              title: const Text('Acepto la política de privacidad'),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _doRegister,
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = [
      _loginTab(),
      _registerTab(),
    ];

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rent-a-Compa',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tab,
                    tabs: const [Tab(text: 'Ingresar'), Tab(text: 'Registrarse')],
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    height: 520, // más alto para permitir scroll interno del form
                    child: TabBarView(controller: _tab, children: content),
                  ),
                  if (_loading) const LinearProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
