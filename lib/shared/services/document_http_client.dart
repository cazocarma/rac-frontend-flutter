import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pending_documents.dart';

/// Observe bounded prerequisite metadata without buffering other responses,
/// changing the original response, or replaying the caller's operation.
class DocumentHttpClient extends http.BaseClient {
  DocumentHttpClient(
    this.inner, {
    this.onDocumentsRequired = DocumentPreconditions.notify,
    this.onAssessmentRequired = DocumentPreconditions.requireAssessment,
  });
  final http.Client inner;
  final void Function(DocumentPrecondition) onDocumentsRequired;
  final void Function() onAssessmentRequired;
  static const maxMetadataBytes = 16 * 1024;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await inner.send(request);
    if (response.statusCode != 428) return response;
    return http.StreamedResponse(
      _observe(response.stream),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Stream<List<int>> _observe(Stream<List<int>> source) async* {
    final metadata = <int>[];
    var oversized = false;
    await for (final chunk in source) {
      if (!oversized) {
        if (metadata.length + chunk.length > maxMetadataBytes) {
          oversized = true;
          metadata.clear();
        } else {
          metadata.addAll(chunk);
        }
      }
      yield chunk;
    }
    if (oversized) return;
    DocumentPrecondition? pending;
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(metadata));
      pending = DocumentPrecondition.parse(428, decoded);
    } on FormatException {
      return;
    }
    if (pending != null) onDocumentsRequired(pending);
    if (decoded is Map && decoded['error'] == 'COMPA_ATTESTATION_REQUIRED') {
      onAssessmentRequired();
    }
  }

  @override
  void close() => inner.close();
}
