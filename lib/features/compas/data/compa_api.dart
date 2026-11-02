import 'package:rentacompa/shared/services/document_http_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// An offered activity from the closed catalog; names are i18n keys.
class CompaActivity {
  const CompaActivity({required this.slug, required this.nameKey, this.note});
  final String slug, nameKey;
  final String? note;
  factory CompaActivity.fromJson(Map<String, dynamic> j) => CompaActivity(
    slug: j['slug'] as String,
    nameKey: j['name_key'] as String,
    note: j['nota'] as String?,
  );
  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name_key': nameKey,
    if (note != null) 'nota': note,
  };
}

/// The public catalog and the per-compa maximum served by user.
class ActivityCatalog {
  const ActivityCatalog({required this.items, required this.maxPerCompa});
  final List<CompaActivity> items;
  final int maxPerCompa;
}

class CompaCard {
  final String id;
  final String usuarioId;
  final String nombre;
  final double tarifaHora;
  final double ratingPromedio;
  final int cantidadResenas;
  final List<CompaActivity> actividades;
  final String? fotoUrl;
  final String? descripcion;
  final String biografia;
  final List<String> intereses;

  CompaCard({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tarifaHora,
    required this.ratingPromedio,
    required this.actividades,
    this.fotoUrl,
    this.descripcion,
    this.cantidadResenas = 0,
    this.biografia = '',
    this.intereses = const [],
  });

  factory CompaCard.fromJson(Map<String, dynamic> j) => CompaCard(
    id: j['id'] as String,
    usuarioId: (j['usuario_id'] ?? j['usuarioId']) as String,
    nombre: (j['nombre'] as String?) ?? '',
    tarifaHora: _asDouble(j['tarifa_hora'] ?? j['tarifaHora']),
    ratingPromedio: _asDouble(j['rating_promedio'] ?? j['ratingPromedio']),
    cantidadResenas: (j['cantidad_resenas'] as num?)?.toInt() ?? 0,
    actividades: [
      for (final item in (j['actividades'] as List? ?? const []))
        CompaActivity.fromJson(Map<String, dynamic>.from(item as Map)),
    ],
    fotoUrl: j['foto_url'] as String?,
    descripcion: j['descripcion'] as String?,
    biografia: j['biografia'] as String? ?? '',
    intereses: _asStringList(j['intereses']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'nombre': nombre,
    'tarifa_hora': tarifaHora,
    'rating_promedio': ratingPromedio,
    'cantidad_resenas': cantidadResenas,
    'actividades': [for (final a in actividades) a.toJson()],
    'foto_url': fotoUrl,
    'descripcion': descripcion,
    'biografia': biografia,
    'intereses': intereses,
  };
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

List<String> _asStringList(dynamic v) {
  if (v is List) {
    return v.map((e) => e.toString()).toList();
  }
  return const <String>[];
}

class CompaApi {
  /// Base debe ser algo como: `http://localhost` o `http://nginx-proxy`
  /// Si incluye slash final no pasa nada; se normaliza.
  final String base;

  /// Cliente HTTP inyectable (útil para pruebas y para compartir sockets).
  final http.Client _client;

  /// Headers adicionales (p. ej. Authorization).
  final Map<String, String> defaultHeaders;

  CompaApi(this.base, {http.Client? client, Map<String, String>? headers})
    : _client = DocumentHttpClient(client ?? http.Client()),
      defaultHeaders = {'Accept': 'application/json', ...?headers};

  Future<Map<String, dynamic>> reviews(String id, {int offset = 0}) async {
    final response = await _client
        .get(_u('/api/user/compas/$id/reviews', {'offset': '$offset'}))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw StateError('Reseñas no disponibles');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Uri _u(String path, [Map<String, String>? query]) {
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$normalizedBase$normalizedPath',
    ).replace(queryParameters: query);
  }

  Future<List<CompaCard>> list({
    String? category,
    int limit = 20,
    int offset = 0,
    Map<String, String>? headers,
  }) async {
    final uri = _u('/api/user/compas', {
      'limit': '$limit',
      'offset': '$offset',
      if (category != null && category.isNotEmpty) 'categoria': category,
    });

    final res = await _client
        .get(uri, headers: {...defaultHeaders, ...?headers})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 204 || res.body.trim().isEmpty) {
      return <CompaCard>[];
    }
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} → HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded
          .map((e) => CompaCard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw const FormatException(
      'Respuesta inesperada: se esperaba una lista JSON.',
    );
  }

  Future<CompaCard> getById(String id, {Map<String, String>? headers}) async {
    final uri = _u('/api/user/compas/$id');

    final res = await _client
        .get(uri, headers: {...defaultHeaders, ...?headers})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} → HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return CompaCard.fromJson(decoded);
    }
    throw const FormatException(
      'Respuesta inesperada: se esperaba un objeto JSON.',
    );
  }

  /// The closed activity catalog; there is no free-text skill search.
  Future<ActivityCatalog> listActivities({Map<String, String>? headers}) async {
    final uri = _u('/api/user/activities');
    final res = await _client
        .get(uri, headers: {...defaultHeaders, ...?headers})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} → HTTP ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return ActivityCatalog(
      items: [
        for (final item in decoded['items'] as List)
          CompaActivity.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
      maxPerCompa: (decoded['max_per_compa'] as num).toInt(),
    );
  }
}
