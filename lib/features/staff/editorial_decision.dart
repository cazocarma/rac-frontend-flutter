import 'dart:math';
import 'dart:convert';

import 'editorial_api.dart';
import 'editorial_journal.dart';

String newEditorialReference() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

bool canEditorialDecide({
  required String resource,
  required Map<String, dynamic> revision,
  required String action,
  required Set<String> permissions,
  required String subject,
}) {
  final review = action == 'approved' || action == 'rejected';
  return !(!{'documents', 'assessments'}.contains(resource) ||
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
      !RegExp(r'^[0-9a-f]{64}$').hasMatch(revision['sha256'] as String));
}

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
  if (!canEditorialDecide(
    resource: resource,
    revision: revision,
    action: action,
    permissions: permissions,
    subject: subject,
  )) {
    throw StateError('Editorial decision unavailable');
  }
  final event = newEditorialReference();
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
  EditorialDecisionAttempt(this.command)
    : journal = null,
      subject = '',
      issuer = '',
      origin = '';
  EditorialDecisionAttempt.durable(
    this.command, {
    required this.journal,
    required this.subject,
    required this.issuer,
    required this.origin,
    bool recovered = false,
  }) : uncertain = recovered;
  final EditorialCommand command;
  final EditorialJournal? journal;
  final String subject;
  final String issuer;
  final String origin;
  bool uncertain = false;
  bool resolved = false;
  Map<String, dynamic>? receipt;
  bool sending = false;

  Future<void> submit(EditorialApi api) async {
    if (sending || resolved) throw StateError('Attempt unavailable');
    sending = true;
    var dispatched = false;
    try {
      await journal?.save(
        command: command,
        subject: subject,
        issuer: issuer,
        origin: origin,
      );
      dispatched = true;
      final result = await api.submit(command);
      final body = jsonDecode(command.encodedBody) as Map<String, dynamic>;
      final field = body.containsKey('document_id')
          ? 'document_id'
          : 'definition_id';
      final assessmentDraft =
          command.path == '/api/admin/staff/assessments/drafts';
      if (result.length != (assessmentDraft ? 2 : 1) ||
          result[field] != body[field] ||
          (assessmentDraft &&
              (result['sha256'] is! String ||
                  !RegExp(
                    r'^[0-9a-f]{64}$',
                  ).hasMatch(result['sha256'] as String)))) {
        throw const EditorialFailure(200, uncertain: true);
      }
      await journal?.resolve(
        command: command,
        subject: subject,
        issuer: issuer,
        origin: origin,
      );
      receipt = Map.unmodifiable(result);
      resolved = true;
    } on EditorialFailure catch (error) {
      uncertain = uncertain || error.uncertain;
      rethrow;
    } catch (_) {
      uncertain = uncertain || dispatched;
      rethrow;
    } finally {
      sending = false;
    }
  }
}
