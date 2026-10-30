import 'profile_text.dart';
import '../../../l10n/generated/app_localizations.dart';
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
  AppLocalizations get t => AppLocalizations.of(context)!;
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
  bool loadFailed = false, saveFailed = false;
  ProfilePhotoFailure? photoError;
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
      loadFailed = false;
    });
    try {
      final value = await api.me();
      Uint8List? loadedPhoto;
      ProfilePhotoFailure? photoFailure;
      if ((value['foto_version'] as String? ?? '').isNotEmpty) {
        try {
          loadedPhoto = await api.ownPhoto();
        } catch (_) {
          photoFailure = ProfilePhotoFailure.load;
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
          loadFailed = true;
        });
      }
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate() || saving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      saving = true;
      saveFailed = false;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.profileSaved)));
    } catch (_) {
      if (mounted) {
        setState(() => saveFailed = true);
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
        throw const ProfilePhotoException(ProfilePhotoFailure.tooLarge);
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
        throw const ProfilePhotoException(
          ProfilePhotoFailure.unsupportedFormat,
        );
      }
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.profilePhotoConfirm),
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
                  Text(t.profilePhotoPreviewNote),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.profileCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.profilePhotoSave),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.profilePhotoSaved)));
    } catch (error) {
      if (mounted) {
        setState(
          () => photoError = error is ProfilePhotoException
              ? error.failure
              : ProfilePhotoFailure.process,
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
        title: Text(t.profilePhotoRemoveTitle),
        content: Text(t.profilePhotoRemoveNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.profilePhotoKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.profilePhotoRemove),
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
        setState(() => photoError = ProfilePhotoFailure.remove);
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
          appBar: AppBar(title: Text(t.profilePublicPreview)),
          body: SingleChildScrollView(
            child: PageContent(
              width: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: Text(t.profilePreviewTitle),
                      subtitle: Text(t.profilePreviewNote),
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
      saveFailed = false;
    }),
    validator: (value) {
      final text = value?.trim() ?? '';
      if (required && text.runes.length < 2) {
        return t.profileNameValidation;
      }
      if (key == 'telefono' &&
          text.isNotEmpty &&
          (RegExp(r'[0-9]').allMatches(text).length < 6 ||
              !RegExp(r'^[0-9+() -]+$').hasMatch(text))) {
        return t.profilePhoneValidation;
      }
      if (key == 'intereses') {
        final interests = text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (interests.length > 15 ||
            interests.any((e) => e.runes.length > 40)) {
          return t.profileInterestsValidation;
        }
      }
      return null;
    },
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving && !photoBusy,
    child: Scaffold(
      appBar: AppBar(title: Text(t.profileTitle)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadFailed
          ? EmptyState(
              title: t.profileLoadFailed,
              message: t.profileRetryMessage,
              action: OutlinedButton(
                onPressed: load,
                child: Text(t.profileRetry),
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
                      PageIntro(
                        eyebrow: t.profileAccount,
                        title: t.profileHeading,
                        description: t.profileDescription,
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
                                                'cliente': t.profileBaseRole,
                                                'compa': t.profileCompaRole,
                                                'admin': t.profileAdminRole,
                                              }[me!['role']] ??
                                              t.profileBaseRole,
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
                                          ? t.profilePhotoProcessing
                                          : t.profilePhotoChange,
                                    ),
                                  ),
                                  if (photo != null)
                                    TextButton(
                                      onPressed: saving || photoBusy
                                          ? null
                                          : removePhoto,
                                      child: Text(t.profilePhotoRemove),
                                    ),
                                  TextButton.icon(
                                    onPressed: saving || photoBusy
                                        ? null
                                        : preview,
                                    icon: const Icon(Icons.visibility_outlined),
                                    label: Text(t.profilePublicPreview),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(t.profilePhotoHelp),
                              if (photoError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    photoError!.localized(t),
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
                                t.profileName,
                                120,
                                required: true,
                                helper: t.profileNameHelp,
                              ),
                              const SizedBox(height: 12),
                              field(
                                'biografia',
                                t.profileBiography,
                                600,
                                lines: 4,
                                helper: t.profileBiographyHelp,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: me!['correo'] as String? ?? '',
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: t.profileEmail,
                                  helperText: t.profileEmailHelp,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                t.profileContact,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(t.profileContactHelp),
                              const SizedBox(height: 16),
                              field(
                                'telefono',
                                t.profilePhone,
                                30,
                                keyboard: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final items = [
                                    field('pais', t.profileCountry, 80),
                                    field('region', t.profileRegion, 100),
                                    field('ciudad', t.profileCity, 100),
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
                                t.profileInterests,
                                628,
                                helper: t.profileInterestsHelp,
                              ),
                              if (saveFailed)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    t.profileSaveFailed,
                                    semanticsLabel: t.profileSaveFailed,
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
                                      saving ? t.profileSaving : t.profileSave,
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: saving || photoBusy || !dirty
                                        ? null
                                        : load,
                                    child: Text(t.profileDiscard),
                                  ),
                                ],
                              ),
                              if (dirty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(t.profileUnsaved),
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
                        label: Text(t.profileBookings),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    ),
  );
}
