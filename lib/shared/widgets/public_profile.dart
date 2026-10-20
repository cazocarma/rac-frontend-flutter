import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../config/env.dart';

// Only application-managed photos may be embedded. Never load a profile's
// arbitrary external URL (tracking pixels, mixed content or untrusted schemes).
String? managedPhotoUrl(String? path) {
  if (path == null ||
      !RegExp(r'^/api/user/media/profile/[a-f0-9]{32}\.jpg$').hasMatch(path)) {
    return null;
  }
  return Uri.parse(Env.apiBase).resolve(path).toString();
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.bytes,
    this.path,
    this.radius = 36,
  });
  final String name;
  final Uint8List? bytes;
  final String? path;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(fontSize: radius * .7),
      ),
    );
    final url = managedPhotoUrl(path);
    if (bytes == null && url == null) return fallback;
    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: bytes != null
            ? Image.memory(
                bytes!,
                fit: BoxFit.cover,
                semanticLabel: 'Foto de $name',
                errorBuilder: (_, e, s) => fallback,
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                semanticLabel: 'Foto de $name',
                errorBuilder: (_, e, s) => fallback,
              ),
      ),
    );
  }
}

class PublicProfilePresentation extends StatelessWidget {
  const PublicProfilePresentation({
    super.key,
    required this.name,
    required this.biography,
    required this.interests,
    this.photo,
    this.photoPath,
  });
  final String name, biography;
  final List<String> interests;
  final Uint8List? photo;
  final String? photoPath;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              name: name,
              bytes: photo,
              path: photoPath,
              radius: 44,
            ),
            const SizedBox(height: 16),
            Text(
              name.isEmpty ? 'Tu nombre visible' : name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Un interés en común. Un plan para compartir.'),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text('Sobre mí', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Text(biography.isEmpty ? 'Todavía no hay una biografía.' : biography),
      if (interests.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Me gusta', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final interest in interests) Chip(label: Text(interest)),
          ],
        ),
      ],
    ],
  );
}
