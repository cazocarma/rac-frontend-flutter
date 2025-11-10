import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentacompa/shared/services/session.dart';

/// API para operaciones del servicio de usuarios.
///
/// Maneja creación o actualización de perfiles (`upsertProfile`).
class UserApi {
  UserApi(this.base);

  /// Base URL del servicio de usuarios — ej: `http://localhost`.
  final String base;

  /// Crea o actualiza el perfil del usuario autenticado.
  ///
  /// El cuerpo (`payload`) debe incluir los campos del perfil a actualizar.
  /// Lanza una excepción si la respuesta HTTP no es exitosa (código != 200).
  Future<void> upsertProfile(Map<String, dynamic> payload) async {
    final at = await Session.accessToken();

    final res = await http.post(
      Uri.parse('$base/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        if (at != null) 'Authorization': 'Bearer $at',
      },
      body: json.encode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}
