import 'dart:convert';
import 'package:oidc/oidc.dart';

import '../../shared/services/auth_store_native.dart'
    if (dart.library.js_interop) '../../shared/services/auth_store_web.dart';
import 'editorial_api.dart';

/// Unresolved commands survive navigation; each event has a separate entry. The OIDC secure namespace uses required
/// encryption on web and hardened secure storage on native platforms.
/// It is isolated from token manager buckets and never cleared by OIDC logout.
class EditorialJournal {
  EditorialJournal({OidcStore? store}) : store = store ?? createAuthStore();
  final OidcStore store;
  static const manager = 'rac-editorial-recovery-v1';
  static const prefix = 'command-';
  String commandKey(EditorialCommand command) {
    final event =
        (jsonDecode(command.encodedBody) as Map<String, dynamic>)['event_id'];
    if (event is! String || !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(event)) {
      throw StateError('UUID event reference required');
    }
    return '$prefix$event';
  }

  Future<void> save({
    required EditorialCommand command,
    required String subject,
    required String issuer,
    required String origin,
  }) async {
    if (subject.isEmpty || issuer.isEmpty || origin.isEmpty) {
      throw StateError('Verified session context required');
    }
    await store.init();
    final key = commandKey(command);
    final existing = await store.get(
      OidcStoreNamespace.secureTokens,
      key: key,
      managerId: manager,
    );
    final encoded = jsonEncode({
      'version': 1,
      'subject': subject,
      'issuer': issuer,
      'origin': origin,
      'operation': command.path.substring('/api/admin/staff/'.length),
      'body': command.encodedBody,
    });
    if (existing != null && existing != encoded) {
      throw StateError('An unresolved editorial command already exists');
    }
    // Must complete before any request can be dispatched.
    await store.set(
      OidcStoreNamespace.secureTokens,
      key: key,
      managerId: manager,
      value: encoded,
    );
  }

  Future<EditorialCommand?> restore({
    required EditorialCommand command,
    required String subject,
    required String issuer,
    required String origin,
  }) async {
    final key = commandKey(command);
    await store.init();
    final raw = await store.get(
      OidcStoreNamespace.secureTokens,
      key: key,
      managerId: manager,
    );
    if (raw == null) return null;
    final value = jsonDecode(raw);
    if (value is! Map<String, dynamic> ||
        value.length != 6 ||
        value['version'] != 1 ||
        value['subject'] != subject ||
        value['issuer'] != issuer ||
        value['origin'] != origin ||
        value['operation'] is! String ||
        value['body'] is! String) {
      // Preserve the original for its owner. Never replace it or expose it to
      // a different staff identity/environment after reauthentication.
      throw StateError('Saved editorial context does not match');
    }
    return EditorialCommand.restore(
      value['operation'] as String,
      value['body'] as String,
    );
  }

  Future<List<EditorialCommand>> pending({
    required String subject,
    required String issuer,
    required String origin,
  }) async {
    await store.init();
    final keys = await store.getAllKeys(
      OidcStoreNamespace.secureTokens,
      managerId: manager,
    );
    final values = await store.getMany(
      OidcStoreNamespace.secureTokens,
      keys: keys.where((key) => key.startsWith(prefix)).toSet(),
      managerId: manager,
    );
    final commands = <EditorialCommand>[];
    for (final raw in values.values) {
      final value = jsonDecode(raw);
      if (value is! Map<String, dynamic> || value['version'] != 1) {
        throw StateError('Invalid recovery entry');
      }
      if (value['subject'] != subject ||
          value['issuer'] != issuer ||
          value['origin'] != origin)
        continue;
      if (value.length != 6 ||
          value['operation'] is! String ||
          value['body'] is! String) {
        throw StateError('Invalid recovery entry');
      }
      commands.add(
        EditorialCommand.restore(
          value['operation'] as String,
          value['body'] as String,
        ),
      );
    }
    return commands;
  }

  Future<void> resolve({
    required EditorialCommand command,
    required String subject,
    required String issuer,
    required String origin,
  }) async {
    final existing = await restore(
      command: command,
      subject: subject,
      issuer: issuer,
      origin: origin,
    );
    if (existing == null ||
        existing.path != command.path ||
        existing.encodedBody != command.encodedBody) {
      throw StateError('Saved command does not match receipt');
    }
    await store.remove(
      OidcStoreNamespace.secureTokens,
      key: commandKey(command),
      managerId: manager,
    );
  }
}
