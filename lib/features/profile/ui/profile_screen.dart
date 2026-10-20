import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/public_profile.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/user_api.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/brand.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.api});
  final UserApi? api;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserApi get api => widget.api ?? Services.user;
  final form = GlobalKey<FormState>();
  final fields = {
    for (final key in [
      'nombre',
      'telefono',
      'pais',
      'region',
      'ciudad',
      'intereses',
      'biografia',
    ])
      key: TextEditingController(),
  };
  Map<String, dynamic>? me;
  bool loading = true, saving = false, dirty = false;
  String? loadError, saveError, photoError;
  Uint8List? photo;
  bool photoBusy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      loadError = null;
    });
    try {
      final value = await api.me();
      Uint8List? loadedPhoto;
      String? photoFailure;
      if ((value['foto_version'] as String? ?? '').isNotEmpty) {
        try {
          loadedPhoto = await api.ownPhoto();
        } catch (_) {
          photoFailure =
              'No pudimos cargar tu foto. Puedes volver a intentarlo.';
        }
      }
      if (!mounted) return;
      for (final key in fields.keys) {
        fields[key]!.text = key == 'intereses'
            ? (value[key] as List? ?? []).join(', ')
            : value[key] as String? ?? '';
      }
      setState(() {
        me = value;
        photo = loadedPhoto;
        photoError = photoFailure;
        loading = false;
        dirty = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          loadError = 'No pudimos cargar tu perfil.';
        });
      }
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      saving = true;
      saveError = null;
    });
    final payload = <String, dynamic>{
      for (final key in fields.keys) key: fields[key]!.text.trim(),
    };
    payload['intereses'] = fields['intereses']!.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    try {
      await api.savePersonalProfile(payload);
      if (!mounted) return;
      setState(() {
        me = {...me!, ...payload};
        dirty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu perfil se guardó correctamente')),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => saveError =
              'No pudimos guardar tus cambios. Se conservan en el formulario; vuelve a intentarlo.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> changePhoto() async {
    setState(() {
      photoBusy = true;
      photoError = null;
    });
    try {
      final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (selected == null || !mounted) return;
      if (await selected.length() > 5 * 1024 * 1024) {
        throw const ProfilePhotoException(
          'La imagen debe pesar como máximo 5 MB.',
        );
      }
      final bytes = await selected.readAsBytes();
      final png =
          bytes.length > 8 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71;
      final jpeg = bytes.length > 2 && bytes[0] == 255 && bytes[1] == 216;
      if (!png && !jpeg) {
        throw const ProfilePhotoException('Elige una foto JPG o PNG.');
      }
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirma tu foto'),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      cacheWidth: 512,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Se recortará al centro en formato cuadrado. Será pública al activar tu perfil compa.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar foto'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await api.savePhoto(bytes, png ? 'image/png' : 'image/jpeg');
      Uint8List? normalized;
      try {
        normalized = await api.ownPhoto();
      } catch (_) {
        /* A successful save is not reversed by a preview download failure. */
      }
      if (!mounted) return;
      setState(() => photo = normalized ?? bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu foto se guardó correctamente')),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => photoError = error is ProfilePhotoException
              ? error.message
              : 'No pudimos procesar la foto. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => photoBusy = false);
    }
  }

  Future<void> removePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Quitar tu foto?'),
        content: const Text('Tu perfil volverá a mostrar tu inicial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Conservar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar foto'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      photoBusy = true;
      photoError = null;
    });
    try {
      await api.deletePhoto();
      if (mounted) setState(() => photo = null);
    } catch (error) {
      if (mounted) {
        setState(
          () => photoError = 'No pudimos quitar tu foto. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => photoBusy = false);
    }
  }

  void preview() {
    final interests = fields['intereses']!.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Vista previa pública')),
          body: SingleChildScrollView(
            child: PageContent(
              width: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.visibility_outlined),
                      title: Text('Así se verá tu presentación'),
                      subtitle: Text(
                        'Esta vista incluye tus cambios sin guardar. No publica ni activa tu perfil compa.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PublicProfilePresentation(
                    name: fields['nombre']!.text.trim(),
                    biography: fields['biografia']!.text.trim(),
                    interests: interests,
                    photo: photo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field(
    String key,
    String label,
    int max, {
    bool required = false,
    TextInputType? keyboard,
    String? helper,
    int lines = 1,
  }) => TextFormField(
    controller: fields[key],
    enabled: !saving && !photoBusy,
    maxLength: max,
    minLines: lines,
    maxLines: lines,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
    ),
    onChanged: (_) => setState(() {
      dirty = true;
      saveError = null;
    }),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (required && text.runes.length < 2) {
        return 'Ingresa al menos dos caracteres';
      }
      if (key == 'telefono' &&
          text.isNotEmpty &&
          (RegExp(r'[0-9]').allMatches(text).length < 6 ||
              !RegExp(r'^[0-9+() -]+$').hasMatch(text))) {
        return 'Ingresa un teléfono válido';
      }
      if (key == 'intereses') {
        final interests = text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (interests.length > 15 ||
            interests.any((e) => e.runes.length > 40)) {
          return 'Máximo 15 intereses de 40 caracteres';
        }
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving && !photoBusy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? EmptyState(
              title: loadError!,
              message: 'Inténtalo nuevamente.',
              action: OutlinedButton(
                onPressed: load,
                child: const Text('Reintentar'),
              ),
            )
          : SingleChildScrollView(
              child: PageContent(
                width: 820,
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageIntro(
                        eyebrow: 'Tu cuenta',
                        title: 'Hagamos tu perfil más tuyo',
                        description:
                            'Cuéntanos cómo te llamas y qué te gusta hacer.',
                      ),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ProfileAvatar(
                                    name: me!['nombre'] as String,
                                    bytes: photo,
                                    radius: 30,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          me!['nombre'] as String,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          {
                                                'cliente': 'Usuario base',
                                                'compa': 'Compa',
                                                'admin': 'Administrador',
                                              }[me!['role']] ??
                                              'Usuario base',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: saving || photoBusy
                                        ? null
                                        : changePhoto,
                                    icon: const Icon(
                                      Icons.add_a_photo_outlined,
                                    ),
                                    label: Text(
                                      photoBusy
                                          ? 'Procesando foto…'
                                          : 'Cambiar foto',
                                    ),
                                  ),
                                  if (photo != null)
                                    TextButton(
                                      onPressed: saving || photoBusy
                                          ? null
                                          : removePhoto,
                                      child: const Text('Quitar foto'),
                                    ),
                                  TextButton.icon(
                                    onPressed: saving || photoBusy
                                        ? null
                                        : preview,
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: const Text('Vista previa pública'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Foto y biografía serán públicas al activar tu perfil compa. JPG o PNG, máximo 5 MB. La foto se guarda por separado.',
                              ),
                              if (photoError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    photoError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              field(
                                'nombre',
                                'Nombre visible',
                                120,
                                required: true,
                                helper:
                                    'Este nombre aparece en tu perfil compa y tus reservas.',
                              ),
                              const SizedBox(height: 12),
                              field(
                                'biografia',
                                'Biografía pública (opcional)',
                                600,
                                lines: 4,
                                helper:
                                    'Cuenta qué te gusta compartir. Evita incluir datos de contacto privados.',
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: me!['correo'] as String? ?? '',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Correo de acceso',
                                  helperText:
                                      'Gestionado por tu cuenta de acceso.',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Datos de contacto',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Son opcionales. Tu teléfono y ubicación general no se muestran en el catálogo público.',
                              ),
                              const SizedBox(height: 16),
                              field(
                                'telefono',
                                'Teléfono (opcional)',
                                30,
                                keyboard: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final items = [
                                    field('pais', 'País (opcional)', 80),
                                    field('region', 'Región (opcional)', 100),
                                    field('ciudad', 'Ciudad (opcional)', 100),
                                  ];
                                  return constraints.maxWidth < 600
                                      ? Column(
                                          children: [
                                            for (final item in items)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: item,
                                              ),
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (final item in items)
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                  child: item,
                                                ),
                                              ),
                                          ],
                                        );
                                },
                              ),
                              const SizedBox(height: 12),
                              field(
                                'intereses',
                                'Tus intereses (opcionales)',
                                628,
                                helper:
                                    'Sepáralos con comas. Por ejemplo: cine, trekking, videojuegos.',
                              ),
                              if (saveError != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    saveError!,
                                    semanticsLabel: saveError,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton.icon(
                                    onPressed: saving || photoBusy || !dirty
                                        ? null
                                        : save,
                                    icon: saving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    label: Text(
                                      saving ? 'Guardando…' : 'Guardar cambios',
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: saving || photoBusy || !dirty
                                        ? null
                                        : load,
                                    child: const Text('Descartar cambios'),
                                  ),
                                ],
                              ),
                              if (dirty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text('Tienes cambios sin guardar.'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/match'),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Ver mis reservas'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    ),
  );
}
