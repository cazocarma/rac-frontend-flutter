import '../../../shared/services/json_api.dart';

class AlertApi extends JsonApi {
  AlertApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/alert');

  /// Titles with catalog provenance come back in [locale] (es or en).
  Future<Map<String, dynamic>> notifications({
    int offset = 0,
    String locale = 'es',
  }) => request('/notifications?limit=20&offset=$offset&locale=$locale');
  Future<void> readNotification(String id) async {
    await request('/notifications/$id/read', method: 'PUT');
  }

  Future<void> readAll() async {
    await request('/notifications/read-all', method: 'PUT');
  }
}
