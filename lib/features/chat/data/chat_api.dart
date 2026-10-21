import 'dart:math';
import '../../../shared/services/json_api.dart';

class ChatException extends ApiException {
  const ChatException(super.status, super.code);
  String get message => switch (status) {
    400 => 'Revisa el motivo y la descripción antes de continuar.',
    403 => 'Tu cuenta no tiene permiso para esta acción.',
    401 => 'Tu sesión venció. Vuelve a ingresar para continuar.',
    404 => 'Esta conversación ya no está disponible para tu cuenta.',
    409 => 'La reserva cambió de estado. Actualiza la conversación.',
    429 => 'Hay demasiadas conexiones. Reintentaremos en unos momentos.',
    _ => 'No pudimos conectar. Conservamos tu mensaje para reintentar aquí.',
  };
}

class ChatApi extends JsonApi {
  ChatApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/chat', exception: ChatException.new);

  static String newRequestId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<Map<String, dynamic>> conversations({int offset = 0}) =>
      request('/conversations?offset=$offset');
  Future<Map<String, dynamic>> safety(String id) =>
      request('/bookings/$id/safety');
  Future<Map<String, dynamic>> block(String id, bool blocked) =>
      request('/bookings/$id/block', body: {'bloqueado': blocked});
  Future<Map<String, dynamic>> report(
    String id,
    String reason,
    String detail,
  ) => request(
    '/bookings/$id/reports',
    body: {'motivo': reason, 'detalle': detail},
  );
  Future<Map<String, dynamic>> history(String id, {String? before}) => request(
    '/bookings/$id/messages${before == null ? '' : '?before=$before'}',
  );
  Future<Map<String, dynamic>> events(String id, String cursor) =>
      request('/bookings/$id/events?after=$cursor&wait=25', poll: true);
  Future<Map<String, dynamic>> send(String id, String key, String text) =>
      request(
        '/bookings/$id/messages',
        body: {'envio_id': key, 'contenido': text},
      );
}
