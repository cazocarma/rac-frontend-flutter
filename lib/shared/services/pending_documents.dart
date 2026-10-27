import 'dart:async';

/// A server precondition is a prompt to read documents, never consent or a
/// command to replay a booking, payment, or message automatically.
class PendingDocument {
  const PendingDocument(this.id, this.kind, this.sha256, this.materialVersion);
  final String id, kind, sha256, materialVersion;
}

class DocumentPrecondition {
  const DocumentPrecondition._(this.documents);
  final List<PendingDocument> documents;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final _hash = RegExp(r'^[0-9a-f]{64}$');
  static const _kinds = {
    'terms_client',
    'terms_compa',
    'community_rules',
    'privacy',
    'safety_rules',
  };
  static bool _identity(dynamic value) =>
      value is String &&
      _uuid.hasMatch(value) &&
      value != '00000000-0000-0000-0000-000000000000';

  static DocumentPrecondition? parse(int status, dynamic body) {
    if (status != 428 ||
        body is! Map ||
        body['error'] != 'DOCUMENT_ACCEPTANCE_REQUIRED') {
      return null;
    }
    final items = body['documents'];
    if (items is! List || items.isEmpty || items.length > 5) return null;
    final ids = <String>{}, kinds = <String>{};
    final result = <PendingDocument>[];
    for (final item in items) {
      if (item is! Map ||
          !_identity(item['id']) ||
          !_identity(item['material_version']) ||
          !_kinds.contains(item['kind']) ||
          item['sha256'] is! String ||
          !_hash.hasMatch(item['sha256'] as String) ||
          !ids.add((item['id'] as String).toLowerCase()) ||
          !kinds.add(item['kind'] as String)) {
        return null;
      }
      result.add(
        PendingDocument(
          item['id'] as String,
          item['kind'] as String,
          item['sha256'] as String,
          item['material_version'] as String,
        ),
      );
    }
    return DocumentPrecondition._(List.unmodifiable(result));
  }
}

/// Ephemeral notifications carry document identity only. No request bodies,
/// session credentials, legal text, or automatic retries are retained.
class DocumentPreconditions {
  static final _events = StreamController<DocumentPrecondition>.broadcast();
  static Stream<DocumentPrecondition> get events => _events.stream;
  static void notify(DocumentPrecondition value) => _events.add(value);
}
