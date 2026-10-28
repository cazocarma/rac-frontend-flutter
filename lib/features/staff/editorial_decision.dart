import 'dart:math';
import 'dart:convert';

import 'editorial_api.dart';

/// Binds a decision to the exact reviewed revision, never to editable fields.
/// UI checks are convenience; owner authorization and four-eyes are mandatory.
EditorialCommand editorialDecision({
  required String resource,
  required Map<String, dynamic> revision,
  required String action,
  required Set<String> permissions,
  required String subject,
}) {
  final review = action == 'approved' || action == 'rejected';
  if (!{'documents', 'assessments'}.contains(resource) ||
      (!review && action != 'publish') ||
      subject.isEmpty ||
      !permissions.contains(
        review ? 'documents.approve' : 'documents.publish',
      ) ||
      (review &&
          (revision['author_id'] == subject || revision['decision'] != null)) ||
      (!review && revision['decision'] != 'approved') ||
      revision['published_at'] != null ||
      revision['id'] is! String ||
      revision['sha256'] is! String ||
      !RegExp(r'^[0-9a-f]{64}$').hasMatch(revision['sha256'] as String)) {
    throw StateError('Editorial decision unavailable');
  }
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final event =
      '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  return EditorialCommand('$resource/${review ? 'reviews' : 'publications'}', {
    'event_id': event,
    resource == 'documents' ? 'document_id' : 'definition_id': revision['id'],
    'sha256': revision['sha256'],
    if (review) 'decision': action,
  });
}

/// Once any attempt is uncertain, a later rejection cannot prove that the
/// original attempt rolled back. Preserve the command until a success receipt.
class EditorialDecisionAttempt {
  EditorialDecisionAttempt(this.command);
  final EditorialCommand command;
  bool uncertain = false;
  bool resolved = false;
  bool sending = false;

  Future<void> submit(EditorialApi api) async {
    if (sending || resolved) throw StateError('Attempt unavailable');
    sending = true;
    try {
      final result = await api.submit(command);
      final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
      final field = body.containsKey('document_id')
          ? 'document_id'
          : 'definition_id';
      if (result.length != 1 || result[field] != body[field]) {
        throw const EditorialFailure(200, uncertain: true);
      }
      resolved = true;
    } on EditorialFailure catch (error) {
      uncertain = uncertain || error.uncertain;
      rethrow;
    } finally {
      sending = false;
    }
  }
}
