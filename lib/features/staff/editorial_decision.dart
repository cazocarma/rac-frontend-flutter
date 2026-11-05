import '../../shared/services/request_id.dart';
import 'dart:convert';

import 'editorial_api.dart';
import 'editorial_journal.dart';

String newEditorialReference() {
  return newRequestId();
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
      if (command.path == '/api/admin/staff/documents/activations') {
        final expected = body['expected_version'];
        if (expected is! int ||
            expected < 0 ||
            expected > 9007199254740990 ||
            result.length != 1 ||
            result['registry_version'] is! int ||
            result['registry_version'] != expected + 1) {
          throw const EditorialFailure(200, uncertain: true);
        }
      } else {
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
