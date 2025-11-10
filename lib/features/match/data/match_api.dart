import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentacompa/shared/services/session.dart';

class MatchApi {
  final String base; // Ejemplo: http://localhost

  MatchApi(this.base);

  /// Obtiene la disponibilidad de un compa específico.
  Future<Map<String, dynamic>> availability(String compaId) async {
    final res = await http.get(
      Uri.parse('$base/api/match/availability/$compaId'),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Establece la disponibilidad de un compa.
  Future<void> setAvailability(
    String compaId,
    Map<String, dynamic> availability,
  ) async {
    final at = await Session.accessToken();

    final res = await http.post(
      Uri.parse('$base/api/match/availability/$compaId'),
      headers: {
        'Content-Type': 'application/json',
        if (at != null) 'Authorization': 'Bearer $at',
      },
      body: json.encode({'availability': availability}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

  /// Crea una nueva sesión (reserva).
  Future<Map<String, dynamic>> createSession({
    required String compaId,
    required DateTime inicio,
    required DateTime fin,
  }) async {
    final at = await Session.accessToken();

    final res = await http.post(
      Uri.parse('$base/api/match/session'),
      headers: {
        'Content-Type': 'application/json',
        if (at != null) 'Authorization': 'Bearer $at',
      },
      body: json.encode({
        'compa_id': compaId,
        'fecha_inicio': inicio.toUtc().toIso8601String(),
        'fecha_fin': fin.toUtc().toIso8601String(),
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Obtiene una sesión específica por ID.
  Future<Map<String, dynamic>> getSession(String id) async {
    final at = await Session.accessToken();

    final res = await http.get(
      Uri.parse('$base/api/match/session/$id'),
      headers: {
        if (at != null) 'Authorization': 'Bearer $at',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Actualiza el estado de una sesión (ej: activa, finalizada, cancelada).
  Future<Map<String, dynamic>> updateState(String id, String estado) async {
    final at = await Session.accessToken();

    final res = await http.put(
      Uri.parse('$base/api/match/session/$id/state'),
      headers: {
        'Content-Type': 'application/json',
        if (at != null) 'Authorization': 'Bearer $at',
      },
      body: json.encode({'estado': estado}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Extiende una sesión existente (por nuevo fin o minutos adicionales).
  Future<Map<String, dynamic>> extend(
    String id, {
    DateTime? nuevoFin,
    int? minutos,
  }) async {
    final at = await Session.accessToken();

    final body = <String, dynamic>{};
    if (nuevoFin != null) {
      body['nuevo_fin'] = nuevoFin.toUtc().toIso8601String();
    }
    if (minutos != null) {
      body['minutos'] = minutos;
    }

    final res = await http.post(
      Uri.parse('$base/api/match/session/$id/extend'),
      headers: {
        'Content-Type': 'application/json',
        if (at != null) 'Authorization': 'Bearer $at',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Lista las sesiones asociadas a un cliente.
  Future<Map<String, dynamic>> listClient(
    String id, {
    int limit = 20,
    int offset = 0,
  }) async {
    final at = await Session.accessToken();

    final uri = Uri.parse('$base/api/match/client/$id/sessions').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final res = await http.get(
      uri,
      headers: {
        if (at != null) 'Authorization': 'Bearer $at',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Lista las sesiones asociadas a un compa.
  Future<Map<String, dynamic>> listCompa(
    String id, {
    int limit = 20,
    int offset = 0,
  }) async {
    final at = await Session.accessToken();

    final uri = Uri.parse('$base/api/match/compa/$id/sessions').replace(
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final res = await http.get(
      uri,
      headers: {
        if (at != null) 'Authorization': 'Bearer $at',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }
}
