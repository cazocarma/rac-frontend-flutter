import 'dart:convert';
import 'package:http/http.dart' as http;

class CompaCard {
  final String id;
  final String usuarioId;
  final String nombre;
  final double tarifaHora;
  final double ratingPromedio;
  final List<String> habilidades;
  final String? fotoUrl;
  final String? descripcion;

  CompaCard({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tarifaHora,
    required this.ratingPromedio,
    required this.habilidades,
    this.fotoUrl,
    this.descripcion,
  });

  factory CompaCard.fromJson(Map<String, dynamic> j) => CompaCard(
        id: j['id'] as String,
        usuarioId: (j['usuario_id'] ?? j['usuarioId']) as String,
        nombre: (j['nombre'] as String?) ?? '',
        tarifaHora: _asDouble(j['tarifa_hora'] ?? j['tarifaHora']),
        ratingPromedio: _asDouble(j['rating_promedio'] ?? j['ratingPromedio']),
        habilidades: _asStringList(j['habilidades']),
        fotoUrl: j['foto_url'] as String?,
        descripcion: j['descripcion'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'nombre': nombre,
        'tarifa_hora': tarifaHora,
        'rating_promedio': ratingPromedio,
        'habilidades': habilidades,
        'foto_url': fotoUrl,
        'descripcion': descripcion,
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

  CompaApi(
    this.base, {
    http.Client? client,
    Map<String, String>? headers,
  })  : _client = client ?? http.Client(),
        defaultHeaders = {
          'Accept': 'application/json',
          ...?headers,
        };

  Uri _u(String path, [Map<String, String>? query]) {
    final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(queryParameters: query);
  }

  Future<List<CompaCard>> list({
    String? skill,
    int limit = 20,
    int offset = 0,
    Map<String, String>? headers,
  }) async {
    final uri = _u('/api/user/compas', {
      'limit': '$limit',
      'offset': '$offset',
      if (skill != null && skill.isNotEmpty) 'skill': skill,
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
    throw const FormatException('Respuesta inesperada: se esperaba una lista JSON.');
  }

  Future<CompaCard> getById(
    String id, {
    Map<String, String>? headers,
  }) async {
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
    throw const FormatException('Respuesta inesperada: se esperaba un objeto JSON.');
  }

  Future<List<String>> listSkills({
    String q = '',
    int limit = 20,
    Map<String, String>? headers,
  }) async {
    final uri = _u('/api/user/skills', {
      if (q.isNotEmpty) 'q': q,
      'limit': '$limit',
    });

    final res = await _client
        .get(uri, headers: {...defaultHeaders, ...?headers})
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 204 || res.body.trim().isEmpty) {
      return <String>[];
    }
    if (res.statusCode != 200) {
      throw Exception('GET ${uri.path} → HTTP ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return <String>[];
  }
}
