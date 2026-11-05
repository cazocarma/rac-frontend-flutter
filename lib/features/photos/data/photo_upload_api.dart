import 'dart:typed_data';
import '../../../shared/services/json_api.dart';
import '../../../shared/services/request_id.dart';
import '../../../shared/services/session.dart';

enum PhotoSourceState {
  awaitingUpload('awaiting_upload'),
  queued('queued'),
  processing('processing'),
  processingUnavailable('processing_unavailable'),
  correctionRequired('correction_required'),
  awaitingReview('awaiting_review');

  const PhotoSourceState(this.wire);
  final String wire;
}

class PhotoSourceStatus {
  const PhotoSourceStatus(this.assetId, this.state);
  final String assetId;
  final PhotoSourceState state;
  factory PhotoSourceStatus.fromJson(Map<String, dynamic> value) {
    final id = value['asset_id'];
    if (id is! String || !isRequestId(id)) {
      throw const FormatException('invalid_photo_status');
    }
    return PhotoSourceStatus(
      id,
      PhotoSourceState.values.firstWhere(
        (s) => s.wire == value['status'],
        orElse: () => throw const FormatException('invalid_photo_status'),
      ),
    );
  }
}

class PhotoUploadConfig {
  const PhotoUploadConfig({required this.enabled, required this.maxBytes});
  final bool enabled;
  final int maxBytes;
  factory PhotoUploadConfig.fromJson(Map<String, dynamic> value) {
    final enabled = value['enabled'], maximum = value['max_bytes'];
    if (enabled is! bool ||
        maximum is! int ||
        maximum < 1 ||
        maximum > 5 * 1024 * 1024) {
      throw const FormatException('invalid_photo_config');
    }
    return PhotoUploadConfig(enabled: enabled, maxBytes: maximum);
  }
}

String? _currentSubject() => Session.auth.claims['sub'] as String?;

Future<String?> Function() _photoToken(
  String owner,
  Future<String?> Function() token,
  String? Function() subject,
) => () async {
  if (owner.isEmpty || subject() != owner) {
    throw const ApiException(401, 'photo_session_changed');
  }
  final result = await token();
  if (subject() != owner) {
    throw const ApiException(401, 'photo_session_changed');
  }
  return result;
};

/// Account-bound owner transport. Server still verifies JWT/ownership; local
/// checks prevent a token refresh/account switch replaying private image bytes
/// for another account or returning an old account's response to its successor.
class PhotoUploadApi extends JsonApi {
  PhotoUploadApi(
    super.base, {
    required this.owner,
    super.client,
    Future<String?> Function()? token,
    super.refresh,
    String? Function()? subject,
  }) : subject = subject ?? _currentSubject,
       super(
         apiPath: '/api/user',
         token: _photoToken(
           owner,
           token ?? Session.accessToken,
           subject ?? _currentSubject,
         ),
       );
  final String owner;
  final String? Function() subject;
  bool get isCurrentOwner => owner.isNotEmpty && subject() == owner;
  Future<T> _scoped<T>(Future<T> Function() work) async {
    if (!isCurrentOwner) throw const ApiException(401, 'photo_session_changed');
    final value = await work();
    if (!isCurrentOwner) throw const ApiException(401, 'photo_session_changed');
    return value;
  }

  void _id(String value) {
    if (!isRequestId(value)) throw ArgumentError('invalid_photo_id');
  }

  Future<PhotoUploadConfig> config() => _scoped(
    () async =>
        PhotoUploadConfig.fromJson(await request('/me/photo-upload-config')),
  );
  Future<PhotoSourceStatus> byRequest(String id) {
    _id(id);
    return _scoped(
      () async => PhotoSourceStatus.fromJson(
        await request('/me/photo-upload-requests/$id'),
      ),
    );
  }

  Future<PhotoSourceStatus> state(String id) {
    _id(id);
    return _scoped(
      () async =>
          PhotoSourceStatus.fromJson(await request('/me/photo-sources/$id')),
    );
  }

  Future<PhotoSourceStatus> confirm(String id) {
    _id(id);
    return _scoped(
      () async => PhotoSourceStatus.fromJson(
        await request('/me/photo-sources/$id/confirm', method: 'POST'),
      ),
    );
  }

  Future<PhotoSourceStatus> upload(
    String id,
    Uint8List bytes,
    String mediaType,
  ) {
    _id(id);
    if (bytes.isEmpty ||
        bytes.length > 5 * 1024 * 1024 ||
        !{'image/jpeg', 'image/png'}.contains(mediaType)) {
      throw ArgumentError('invalid_photo');
    }
    return _scoped(
      () async => PhotoSourceStatus.fromJson(
        await requestBytes(
          '/me/photo-sources',
          bytes: bytes,
          mediaType: mediaType,
          idempotencyKey: id,
        ),
      ),
    );
  }
}
