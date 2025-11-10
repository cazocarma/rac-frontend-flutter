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
  // register (extended)\r\n  final _regForm = GlobalKey<FormState>();\r\n  final _rNombreCtrl = TextEditingController();\r\n  final _rEmailCtrl = TextEditingController();\r\n  final _rPassCtrl = TextEditingController();\r\n  final _rFechaNacCtrl = TextEditingController();\r\n  String? _rGenero; // masculino,femenino,otro,prefiero_no_decir\r\n  final _rTelefonoCtrl = TextEditingController();\r\n  final _rPaisCtrl = TextEditingController();\r\n  final _rRegionCtrl = TextEditingController();\r\n  final _rCiudadCtrl = TextEditingController();\r\n  final _rDireccionCtrl = TextEditingController();\r\n  final _rInteresesCtrl = TextEditingController(); // comma-separated\r\n  final _rIdiomaCtrl = TextEditingController();\r\n  bool _rNotif = false;\r\n  bool _rTOS = false;\r\n  bool _rPrivacy = false;

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
    _rNombreCtrl.dispose(); _rEmailCtrl.dispose(); _rPassCtrl.dispose();\r\n    _rFechaNacCtrl.dispose();\r\n    _rTelefonoCtrl.dispose(); _rPaisCtrl.dispose(); _rRegionCtrl.dispose(); _rCiudadCtrl.dispose();\r\n    _rDireccionCtrl.dispose(); _rInteresesCtrl.dispose(); _rIdiomaCtrl.dispose();
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
        username: _rEmailCtrl.text.trim(),
        email: _rEmailCtrl.text.trim(),
        password: _rPassCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada. Inicia sesiÃ³n.')));
      _tab.animateTo(0);\n      // Enviar perfil extendido a User Service
      try {
        final intereses = _rInteresesCtrl.text.split(',').map((e)=> e.trim()).where((e)=> e.isNotEmpty).toList();
        await Services.user.upsertProfile({
          'nombre': _rNombreCtrl.text.trim(),
          'correo': _rEmailCtrl.text.trim(),
          'fecha_nacimiento': _rFechaNacCtrl.text.trim(),
          'genero': _rGenero,
          'telefono': _rTelefonoCtrl.text.trim(),
          'pais': _rPaisCtrl.text.trim(),
          'region': _rRegionCtrl.text.trim(),
          'ciudad': _rCiudadCtrl.text.trim(),
          'direccion': _rDireccionCtrl.text.isNotEmpty ? _rDireccionCtrl.text.trim() : null,
          'intereses': intereses,
          'idioma_preferido': _rIdiomaCtrl.text.isNotEmpty ? _rIdiomaCtrl.text.trim() : null,
          'notificaciones_activadas': _rNotif,
          'foto_perfil': null,
          'ubicacion': null,
          'radio_busqueda_km': null,
        });
      } catch (_) {}
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
          // aÃºn no listo
        }
      }
      popup?.close();
      if (!done) throw Exception('Tiempo agotado en autenticaciÃ³n social');
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
              decoration: const InputDecoration(labelText: 'ContraseÃ±a'),
              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rFechaNacCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(context: context, initialDate: DateTime(now.year-18, now.month, now.day), firstDate: DateTime(1900), lastDate: now);
                if (picked != null) setState(() { _rFechaNacCtrl.text = picked.toIso8601String().split('T').first; });
              },
              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _rGenero,
              decoration: const InputDecoration(labelText: 'Género (opcional)'),
              items: const [
                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
                DropdownMenuItem(value: 'prefiero_no_decir', child: Text('Prefiero no decir')),
              ],
              onChanged: (v) => setState(()=> _rGenero = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _rTelefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
            const SizedBox(height: 12),
            TextFormField(controller: _rPaisCtrl, decoration: const InputDecoration(labelText: 'País'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _rRegionCtrl, decoration: const InputDecoration(labelText: 'Región'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _rCiudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _rDireccionCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)')),
            const SizedBox(height: 12),
            TextFormField(controller: _rInteresesCtrl, decoration: const InputDecoration(labelText: 'Intereses (separados por coma)')),
            const SizedBox(height: 12),
            TextFormField(controller: _rIdiomaCtrl, decoration: const InputDecoration(labelText: 'Idioma preferido')),
            const SizedBox(height: 12),
            SwitchListTile(value: _rNotif, onChanged: (v)=> setState(()=> _rNotif=v), title: const Text('Activar notificaciones')),
            CheckboxListTile(value: _rTOS, onChanged: (v)=> setState(()=> _rTOS = v ?? false), title: const Text('Acepto términos y condiciones')),
            CheckboxListTile(value: _rPrivacy, onChanged: (v)=> setState(()=> _rPrivacy = v ?? false), title: const Text('Acepto la política de privacidad')),
            const SizedBox(height: 12),\r\n            TextFormField(\r\n              controller: _rFechaNacCtrl,\r\n              readOnly: true,\r\n              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),\r\n              onTap: () async {\r\n                final now = DateTime.now();\r\n                final picked = await showDatePicker(context: context, initialDate: DateTime(now.year-18, now.month, now.day), firstDate: DateTime(1900), lastDate: now);\r\n                if (picked != null) setState(() { _rFechaNacCtrl.text = picked.toIso8601String().split('T').first; });\r\n              },\r\n              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,\r\n            ),\r\n            const SizedBox(height: 12),\r\n            DropdownButtonFormField<String>(\r\n              value: _rGenero,\r\n              decoration: const InputDecoration(labelText: 'Género (opcional)'),\r\n              items: const [\r\n                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
                DropdownMenuItem(value: 'prefiero_no_decir', child: Text('Prefiero no decir')),
              ],\r\n              onChanged: (v) => setState(()=> _rGenero = v),\r\n            ),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rTelefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rPaisCtrl, decoration: const InputDecoration(labelText: 'País'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),\r\n            const SizedBox(height: 12),\r\n            Row(children: [\r\n              Expanded(child: TextFormField(controller: _rRegionCtrl, decoration: const InputDecoration(labelText: 'Región'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),\r\n              const SizedBox(width: 12),\r\n              Expanded(child: TextFormField(controller: _rCiudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),\r\n            ]),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rDireccionCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)')),
            const SizedBox(height: 12),\r\n            TextFormField(controller: _rInteresesCtrl, decoration: const InputDecoration(labelText: 'Intereses (separados por coma)')),
            const SizedBox(height: 12),\r\n            TextFormField(controller: _rIdiomaCtrl, decoration: const InputDecoration(labelText: 'Idioma preferido')),
            const SizedBox(height: 12),\r\n            SwitchListTile(value: _rNotif, onChanged: (v)=> setState(()=> _rNotif=v), title: const Text('Activar notificaciones')),
            CheckboxListTile(value: _rTOS, onChanged: (v)=> setState(()=> _rTOS = v ?? false), title: const Text('Acepto términos y condiciones')),
            CheckboxListTile(value: _rPrivacy, onChanged: (v)=> setState(()=> _rPrivacy = v ?? false), title: const Text('Acepto la política de privacidad')),
            const SizedBox(height: 12),\r\n            ElevatedButton(
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
            const SizedBox(height: 8),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Cliente')),
                Padding(padding: EdgeInsets.all(8), child: Text('Compa')),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rUserCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),\r\n              validator: (v) => (v==null || v.trim().isEmpty) ? 'Requerido' : null,\r\n            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rEmailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v==null || !v.contains('@')) ? 'Email invÃ¡lido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'ContraseÃ±a'),
              validator: (v) => (v==null || v.length < 6) ? 'MÃ­nimo 6 caracteres' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rFechaNacCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(context: context, initialDate: DateTime(now.year-18, now.month, now.day), firstDate: DateTime(1900), lastDate: now);
                if (picked != null) setState(() { _rFechaNacCtrl.text = picked.toIso8601String().split('T').first; });
              },
              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _rGenero,
              decoration: const InputDecoration(labelText: 'Género (opcional)'),
              items: const [
                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
                DropdownMenuItem(value: 'prefiero_no_decir', child: Text('Prefiero no decir')),
              ],
              onChanged: (v) => setState(()=> _rGenero = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _rTelefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
            const SizedBox(height: 12),
            TextFormField(controller: _rPaisCtrl, decoration: const InputDecoration(labelText: 'País'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _rRegionCtrl, decoration: const InputDecoration(labelText: 'Región'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _rCiudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),
            ]),
            const SizedBox(height: 12),
            TextFormField(controller: _rDireccionCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)')),
            const SizedBox(height: 12),
            TextFormField(controller: _rInteresesCtrl, decoration: const InputDecoration(labelText: 'Intereses (separados por coma)')),
            const SizedBox(height: 12),
            TextFormField(controller: _rIdiomaCtrl, decoration: const InputDecoration(labelText: 'Idioma preferido')),
            const SizedBox(height: 12),
            SwitchListTile(value: _rNotif, onChanged: (v)=> setState(()=> _rNotif=v), title: const Text('Activar notificaciones')),
            CheckboxListTile(value: _rTOS, onChanged: (v)=> setState(()=> _rTOS = v ?? false), title: const Text('Acepto términos y condiciones')),
            CheckboxListTile(value: _rPrivacy, onChanged: (v)=> setState(()=> _rPrivacy = v ?? false), title: const Text('Acepto la política de privacidad')),
            const SizedBox(height: 12),\r\n            TextFormField(\r\n              controller: _rFechaNacCtrl,\r\n              readOnly: true,\r\n              decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),\r\n              onTap: () async {\r\n                final now = DateTime.now();\r\n                final picked = await showDatePicker(context: context, initialDate: DateTime(now.year-18, now.month, now.day), firstDate: DateTime(1900), lastDate: now);\r\n                if (picked != null) setState(() { _rFechaNacCtrl.text = picked.toIso8601String().split('T').first; });\r\n              },\r\n              validator: (v) => (v==null || v.isEmpty) ? 'Requerido' : null,\r\n            ),\r\n            const SizedBox(height: 12),\r\n            DropdownButtonFormField<String>(\r\n              value: _rGenero,\r\n              decoration: const InputDecoration(labelText: 'Género (opcional)'),\r\n              items: const [\r\n                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'otro', child: Text('Otro')),
                DropdownMenuItem(value: 'prefiero_no_decir', child: Text('Prefiero no decir')),
              ],\r\n              onChanged: (v) => setState(()=> _rGenero = v),\r\n            ),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rTelefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rPaisCtrl, decoration: const InputDecoration(labelText: 'País'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null),\r\n            const SizedBox(height: 12),\r\n            Row(children: [\r\n              Expanded(child: TextFormField(controller: _rRegionCtrl, decoration: const InputDecoration(labelText: 'Región'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),\r\n              const SizedBox(width: 12),\r\n              Expanded(child: TextFormField(controller: _rCiudadCtrl, decoration: const InputDecoration(labelText: 'Ciudad'), validator: (v)=> (v==null||v.isEmpty)?'Requerido':null)),\r\n            ]),\r\n            const SizedBox(height: 12),\r\n            TextFormField(controller: _rDireccionCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)')),
            const SizedBox(height: 12),\r\n            TextFormField(controller: _rInteresesCtrl, decoration: const InputDecoration(labelText: 'Intereses (separados por coma)')),
            const SizedBox(height: 12),\r\n            TextFormField(controller: _rIdiomaCtrl, decoration: const InputDecoration(labelText: 'Idioma preferido')),
            const SizedBox(height: 12),\r\n            SwitchListTile(value: _rNotif, onChanged: (v)=> setState(()=> _rNotif=v), title: const Text('Activar notificaciones')),
            CheckboxListTile(value: _rTOS, onChanged: (v)=> setState(()=> _rTOS = v ?? false), title: const Text('Acepto términos y condiciones')),
            CheckboxListTile(value: _rPrivacy, onChanged: (v)=> setState(()=> _rPrivacy = v ?? false), title: const Text('Acepto la política de privacidad')),
            const SizedBox(height: 12),\r\n            ElevatedButton(
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









