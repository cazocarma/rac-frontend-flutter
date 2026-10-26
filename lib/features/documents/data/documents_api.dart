import '../../../shared/services/json_api.dart';

class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.kind,
    required this.version,
    required this.sha256,
    this.acceptedAt,
    this.content,
  });
  final String id, kind, version, sha256;
  final DateTime? acceptedAt;
  final String? content;

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    id: json['id'] as String,
    kind: json['kind'] as String,
    version: json['version'] as String,
    sha256: json['sha256'] as String,
    acceptedAt: json['accepted_at'] == null
        ? null
        : DateTime.parse(json['accepted_at'] as String),
    content: json['content'] as String?,
  );
  String get title => switch (kind) {
    'terms_client' => 'Términos para clientes',
    'terms_compa' => 'Términos para compas',
    'community_rules' => 'Reglas de la comunidad',
    'privacy' => 'Privacidad',
    'safety_rules' => 'Reglas de seguridad',
    _ => 'Documento',
  };
}

class DocumentsApi extends JsonApi {
  DocumentsApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/user');

  Future<List<LegalDocument>> documents() async {
    final value = await request('/me/documents?locale=es');
    return (value['items'] as List)
        .map((e) => LegalDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LegalDocument> document(String id) async => LegalDocument.fromJson(
    await request('/documents/${Uri.encodeComponent(id)}'),
  );
  Future<void> accept(LegalDocument document) async {
    await request(
      '/me/documents/acceptances',
      body: {
        'context': 'account',
        'documents': [
          {'id': document.id, 'sha256': document.sha256},
        ],
      },
    );
  }
}
