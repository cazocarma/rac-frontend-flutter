import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _nameCtrl.text = p.getString('profile_name') ?? '';
    _emailCtrl.text = p.getString('profile_email') ?? '';
    _bioCtrl.text = p.getString('profile_bio') ?? '';
    setState(() {});
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('profile_name', _nameCtrl.text.trim());
    await p.setString('profile_email', _emailCtrl.text.trim());
    await p.setString('profile_bio', _bioCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Perfil guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Requerido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Email inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtrl,
                decoration:
                    const InputDecoration(labelText: 'Biografía (opcional)'),
                maxLength: 500,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Guardar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

