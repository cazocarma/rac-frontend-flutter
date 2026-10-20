import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:rentacompa/shared/services/session.dart';

class ProfilePhotoException implements Exception {
  const ProfilePhotoException(this.message);
  final String message;
}

/// API para operaciones del servicio de usuarios.
///
/// Maneja creación o actualización de perfiles (`upsertProfile`).
class UserApi {
  UserApi(this.base, {http.Client? client}) : client = client ?? http.Client();
  final http.Client client;

  /// Base URL del servicio de usuarios — ej: `http://localhost`.
  final String base;

  Future<Map<String, dynamic>?> bookingReview(String id) async {
    final token = await Session.accessToken();
    final response = await client
        .get(
          Uri.parse('$base/api/user/bookings/$id/review'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw StateError('No pudimos cargar la reseña.');
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['resena']
        as Map<String, dynamic>?;
  }

  Future<void> saveReview(String id, int score, String comment) async {
    final token = await Session.accessToken();
    final response = await client
        .post(
          Uri.parse('$base/api/user/bookings/$id/review'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'puntuacion': score, 'comentario': comment}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError(
        response.statusCode == 409
            ? 'Esta reserva todavía no permite reseñas o ya tiene una. Actualiza para comprobar su estado.'
            : 'No pudimos confirmar el envío. Puedes reintentar sin duplicar tu reseña.',
      );
    }
  }

  Future<Uint8List?> ownPhoto() async {
    final token = await Session.accessToken();
    final response = await client
        .get(
          Uri.parse('$base/api/user/me/photo'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw const ProfilePhotoException('No pudimos cargar tu foto.');
    }
    return response.bodyBytes;
  }

  Future<void> savePhoto(Uint8List bytes, String mediaType) async {
    final token = await Session.accessToken();
    final response = await client
        .put(
          Uri.parse('$base/api/user/me/photo'),
          headers: {
            'Content-Type': mediaType,
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: bytes,
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw ProfilePhotoException(switch (response.statusCode) {
        413 => 'La imagen debe pesar como máximo 5 MB.',
        400 || 415 =>
          'Elige una imagen JPG o PNG válida, entre 32 y 4096 píxeles por lado y hasta 12 megapíxeles.',
        429 => 'Estamos procesando otras fotos. Inténtalo en unos segundos.',
        _ =>
          'No pudimos confirmar el guardado de tu foto. Inténtalo nuevamente.',
      });
    }
  }

  Future<void> deletePhoto() async {
    final token = await Session.accessToken();
    final response = await client
        .delete(
          Uri.parse('$base/api/user/me/photo'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw const ProfilePhotoException(
        'No pudimos quitar tu foto. Inténtalo nuevamente.',
      );
    }
  }

  Future<Map<String, dynamic>?> ownCompa() async {
    final token = await Session.accessToken();
    final response = await client.get(
      Uri.parse('$base/api/user/me/compa'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw StateError('No se pudo cargar tu perfil compa');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> saveCompa(Map<String, dynamic> payload) async {
    final token = await Session.accessToken();
    final response = await client.put(
      Uri.parse('$base/api/user/me/compa'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw StateError(
        'No pudimos guardar tu perfil. Tus cambios anteriores se conservan; inténtalo nuevamente.',
      );
    }
  }

  Future<Map<String, dynamic>> me() async {
    final token = await Session.accessToken();
    final res = await client.get(
      Uri.parse('$base/api/user/me'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw StateError('No se pudo cargar tu perfil');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> savePersonalProfile(Map<String, dynamic> payload) async {
    final token = await Session.accessToken();
    final response = await client.put(
      Uri.parse('$base/api/user/me'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw StateError(
        response.statusCode == 400
            ? 'Revisa los datos del formulario.'
            : 'No pudimos guardar tus cambios. Inténtalo nuevamente.',
      );
    }
  }

  /// Crea o actualiza el perfil del usuario autenticado.
  ///
  /// El cuerpo (`payload`) debe incluir los campos del perfil a actualizar.
  /// Lanza una excepción si la respuesta HTTP no es exitosa (código != 200).
  Future<void> upsertProfile(Map<String, dynamic> payload) async {
    final at = await Session.accessToken();

    final res = await client.post(
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

  Future<Map<String, dynamic>> notifications({int offset = 0}) async {
    final token = await Session.accessToken();
    final response = await client.get(
      Uri.parse('$base/api/user/notifications?limit=20&offset=$offset'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw StateError('Notificaciones no disponibles');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> readNotification(String id) async {
    final token = await Session.accessToken();
    final response = await client.put(
      Uri.parse('$base/api/user/notifications/$id/read'),
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw StateError('No se pudo marcar como leída');
    }
  }
}
