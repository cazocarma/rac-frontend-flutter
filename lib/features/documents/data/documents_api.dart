import '../../../shared/services/json_api.dart';

class DocumentRegistry {
  const DocumentRegistry({
    required this.locale,
    required this.version,
    required this.policyVersion,
    this.summary = const [],
  });
  final String locale, policyVersion;
  final int version;
  final List<String> summary;
  static final _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  factory DocumentRegistry.fromJson(Map<String, dynamic> json) {
    final locale = json['locale'],
        version = json['version'],
        policy = json['policy_version'],
        summary = json['summary'];
    if ((locale != 'es' && locale != 'en') ||
        version is! int ||
        version <= 0 ||
        policy is! String ||
        !_uuid.hasMatch(policy) ||
        policy == '00000000-0000-0000-0000-000000000000' ||
        summary is! List ||
        summary.length > 3 ||
        summary.any(
          (point) =>
              point is! String ||
              point.trim().isEmpty ||
              point.runes.length > 280,
        )) {
      throw const FormatException('Invalid document registry');
    }
    return DocumentRegistry(
      locale: locale as String,
      version: version,
      policyVersion: policy,
      summary: List<String>.unmodifiable(summary.cast<String>()),
    );
  }
  Map<String, dynamic> get reference => {
    'locale': locale,
    'version': version,
    'policy_version': policyVersion,
  };
}

class DocumentCollection {
  const DocumentCollection({required this.items, this.registry});
  final List<LegalDocument> items;
  final DocumentRegistry? registry;
}

class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.kind,
    required this.version,
    required this.sha256,
    this.acceptedAt,
    this.content,
    this.registry,
  });
  final String id, kind, version, sha256;
  final DateTime? acceptedAt;
  final String? content;
  final DocumentRegistry? registry;

  factory LegalDocument.fromJson(
    Map<String, dynamic> json, {
    DocumentRegistry? registry,
  }) => LegalDocument(
    id: json['id'] as String,
    kind: json['kind'] as String,
    version: json['version'] as String,
    sha256: json['sha256'] as String,
    acceptedAt: json['accepted_at'] == null
        ? null
        : DateTime.parse(json['accepted_at'] as String),
    content: json['content'] as String?,
    registry: registry,
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

  Future<DocumentCollection> collection() async {
    final value = await request('/me/documents?locale=es');
    final registry = value['registry'] == null
        ? null
        : DocumentRegistry.fromJson(value['registry'] as Map<String, dynamic>);
    final items = (value['items'] as List)
        .map(
          (e) => LegalDocument.fromJson(
            e as Map<String, dynamic>,
            registry: registry,
          ),
        )
        .toList(growable: false);
    return DocumentCollection(items: items, registry: registry);
  }

  Future<List<LegalDocument>> documents() async => (await collection()).items;

  Future<LegalDocument> document(String id) async => LegalDocument.fromJson(
    await request('/documents/${Uri.encodeComponent(id)}'),
  );
  Future<void> acceptBatch(
    List<LegalDocument> documents,
    DocumentRegistry registry,
  ) async {
    if (documents.isEmpty || documents.length > 5) {
      throw const FormatException('Invalid consent batch');
    }
    await request(
      '/me/documents/acceptances',
      body: {
        'context': 'account',
        'registry': registry.reference,
        'documents': [
          for (final document in documents)
            {'id': document.id, 'sha256': document.sha256},
        ],
      },
    );
  }

  Future<void> accept(
    LegalDocument document, {
    DocumentRegistry? registry,
  }) async {
    await request(
      '/me/documents/acceptances',
      body: {
        'context': 'account',
        if ((registry ?? document.registry) != null)
          'registry': (registry ?? document.registry)!.reference,
        'documents': [
          {'id': document.id, 'sha256': document.sha256},
        ],
      },
    );
  }
}
