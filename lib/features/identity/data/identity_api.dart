import '../../../shared/services/json_api.dart';

/// Identity verification is owned by user; the app only learns the state and
/// the provider URL to continue. Email verification never stands in for it.
class IdentityApi extends JsonApi {
  IdentityApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/user');

  Future<String> status() async =>
      (await request('/me/identity'))['status'] as String;

  /// Returns the state and, when a session was opened, the provider URL.
  Future<({String status, String? url})> start(String purpose) async {
    final result = await request(
      '/me/identity/sessions',
      body: {'purpose': purpose},
    );
    return (status: result['status'] as String, url: result['url'] as String?);
  }
}
