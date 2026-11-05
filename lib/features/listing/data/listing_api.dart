import '../../../shared/services/json_api.dart';
import '../../../shared/services/request_id.dart';

/// Review state of the owner's listing. Signals, risk and reviewer identity
/// are never part of it; a decision carries only a reason code.
class OwnListing {
  const OwnListing({
    required this.state,
    required this.version,
    required this.pending,
    required this.published,
    this.decision,
    this.photoVersion,
  });
  final String state, version;
  final bool pending, published;
  final String? decision;
  final String? photoVersion;

  factory OwnListing.fromJson(Map<String, dynamic> j) {
    final revision = j['pending'] ?? j['published'];
    final payload = revision is Map ? revision['listing'] : null;
    final photo = payload is Map ? payload['photo_version'] : null;
    if (photo != null &&
        photo != '' &&
        (photo is! String || !isRequestId(photo))) {
      throw const FormatException('invalid_listing_photo');
    }
    return OwnListing(
      state: j['state'] as String,
      version: j['version'] as String,
      pending: j['pending'] != null,
      published: j['published'] != null,
      decision: (j['last_decision'] as Map?)?['decision'] as String?,
      photoVersion: photo is String && photo.isNotEmpty ? photo : null,
    );
  }
}

class ListingApi extends JsonApi {
  ListingApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/user');

  Future<OwnListing?> state() async {
    final listing = (await request('/me/listing'))['listing'];
    return listing == null
        ? null
        : OwnListing.fromJson(Map<String, dynamic>.from(listing as Map));
  }

  /// Sends a snapshot for human review. It never publishes by itself.
  Future<void> submit(String expectedVersion, Map<String, dynamic> listing) =>
      request(
        '/me/listing/submissions',
        body: {'expected_version': expectedVersion, 'listing': listing},
      );
}

/// Builds the review snapshot from the saved personal and compa profile, so
/// the person reviews exactly what they already edited elsewhere.
Map<String, dynamic> listingDraft(
  Map<String, dynamic> me,
  Map<String, dynamic> compa,
) {
  final profile = Map<String, dynamic>.from(compa['profile'] as Map);
  return {
    'display_name': (me['nombre'] as String? ?? '').trim(),
    'biography': (me['biografia'] as String? ?? '').trim(),
    'interests': [
      for (final item in me['intereses'] as List? ?? const []) '$item',
    ],
    'description': (profile['descripcion'] as String? ?? '').trim(),
    'activities': [
      for (final raw in profile['actividades'] as List? ?? const [])
        {'slug': (raw as Map)['slug'], 'note': raw['nota'] ?? ''},
    ],
    'price_clp_per_hour': (profile['tarifa_hora'] as num? ?? 0).round(),
    'photo_version': '',
    'area_code': '',
  };
}
