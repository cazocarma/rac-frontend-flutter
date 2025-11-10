import 'dart:async';
import 'dart:html' as html; // solo web
import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';

class UnifiedAuthScreen extends StatefulWidget {
  const UnifiedAuthScreen({super.key});
  @override
  State<UnifiedAuthScreen> createState() => _UnifiedAuthScreenState();
}

class _UnifiedAuthScreenState extends State<UnifiedAuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  // login
  final _loginForm = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // register
  final _regForm = GlobalKey<FormState>();
  final _rUserCtrl = TextEditingController();
  final _rEmailCtrl = TextEditingController();
  final _rPassCtrl = TextEditingController();
  String _regRole = 'cliente';

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
    _userCtrl.dispose(); _passCtrl.dispose();
    _rUserCtrl.dispose(); _rEmailCtrl.dispose(); _rPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await Services.auth.login(username: _userCtrl.text.trim(), password: _passCtrl.text.trim());
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
    setState(() { _loading = true; _error = null; });
    try {
      await Services.auth.register(
        username: _rUserCtrl.text.trim(),
        email: _rEmailCtrl.text.trim(),
        password: _rPassCtrl.text.trim(),
        role: _regRole,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada. Inicia sesión.')));
      _tab.animateTo(0);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _social(String provider) async {
    setState(() { _loading = true; _error = null; });
    try {
      final start = await Services.auth.oauthStart(provider);
      final authUrl = start['auth_url']!;
      final state = start['state']!;

      // abre popup
      final popup = html.window.open(authUrl, '_blank',
          'width=600,height=700,menubar=no,toolbar=no,location=no,status=no');
      // espera unos segundos y consume (polling simple)
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

  @override
  Widget build(BuildContext context) {
    final content = [
      // LOGIN TAB
      Form(
        key: _loginForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Usuario o email'),
              validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _doLogin,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Google'),
                  onPressed: _loading ? null : () => _social('google'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  icon: const Icon(Icons.code),
                  label: const Text('GitHub'),
                  onPressed: _loading ? null : () => _social('github'),
                )),
              ],
            ),
          ],
        ),
      ),

      // REGISTER TAB
      Form(
        key: _regForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToggleButtons(
              isSelected: [_regRole=='cliente', _regRole=='compa'],
              onPressed: (i) => setState(() { _regRole = i==0 ? 'cliente' : 'compa'; }),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Cliente')),
                Padding(padding: EdgeInsets.all(8), child: Text('Compa')),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rUserCtrl,
              decoration: const InputDecoration(labelText: 'Usuario'),
              validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v==null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              validator: (v) => (v==null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _doRegister,
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
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
                  const Text('Rent-a-Compa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tab,
                    tabs: const [Tab(text: 'Ingresar'), Tab(text: 'Registrarse')],
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                  SizedBox(
                    height: 360,
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
