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
        usuarioId: j['usuario_id'] as String,
        nombre: j['nombre'] as String? ?? '',
        tarifaHora: (j['tarifa_hora'] ?? 0).toDouble(),
        ratingPromedio: (j['rating_promedio'] ?? 0).toDouble(),
        habilidades: (j['habilidades'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        fotoUrl: j['foto_url'] as String?,
        descripcion: j['descripcion'] as String?,
      );
}

class CompaApi {
  final String base; // ej: http://localhost
  CompaApi(this.base);

  Future<List<CompaCard>> list({String? skill, int limit = 20}) async {
    final uri = Uri.parse('$base/api/user/compas').replace(
      queryParameters: {
        'limit': '$limit',
        if (skill != null && skill.isNotEmpty) 'skill': skill,
      },
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = json.decode(res.body) as List<dynamic>;
    return data.map((e) => CompaCard.fromJson(e as Map<String, dynamic>)).toList();
  }
}
