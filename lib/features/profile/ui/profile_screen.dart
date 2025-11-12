import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/widgets/modal_shell.dart';
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
  final _picker = ImagePicker();

  Uint8List? _photoData;
  String _role = 'cliente';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPhoto = prefs.getString('profile_photo');
    Uint8List? photo;
    if (storedPhoto != null && storedPhoto.isNotEmpty) {
      try {
        photo = base64Decode(storedPhoto);
      } catch (_) {
        photo = null;
      }
    }

    _nameCtrl.text = prefs.getString('profile_name') ?? '';
    _emailCtrl.text = prefs.getString('profile_email') ?? '';
    _bioCtrl.text = prefs.getString('profile_bio') ?? '';
    final role = await Session.role();

    if (!mounted) return;
    setState(() {
      _photoData = photo;
      _role = role;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', _nameCtrl.text.trim());
      await prefs.setString('profile_email', _emailCtrl.text.trim());
      await prefs.setString('profile_bio', _bioCtrl.text.trim());
      if (_photoData != null) {
        await prefs.setString('profile_photo', base64Encode(_photoData!));
      } else {
        await prefs.remove('profile_photo');
      }
      await Session.setRole(_role);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil guardado')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _photoData = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return ModalShell(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Perfil'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage:
                            _photoData != null ? MemoryImage(_photoData!) : null,
                        child: _photoData == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Cambiar foto'),
                      ),
                      if (_photoData != null)
                        TextButton(
                          onPressed: () => setState(() => _photoData = null),
                          child: const Text('Quitar foto'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de perfil',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'cliente',
                      child: Text('Cliente'),
                    ),
                    DropdownMenuItem(
                      value: 'compa',
                      child: Text('Compa'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _role = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bioCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Biografía (opcional)'),
                  maxLength: 500,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
