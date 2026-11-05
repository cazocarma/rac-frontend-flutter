import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/request_id.dart';

abstract class PhotoUploadPointer {
  Future<String?> load();
  Future<void> save(String requestId);
}

/// One opaque retry ID per issuer/API/account. No image bytes, bearer tokens,
/// object URLs, moderation state or signal details are persisted on the device.
class PreferencesPhotoUploadPointer implements PhotoUploadPointer {
  PreferencesPhotoUploadPointer(String issuer, String apiBase, String owner)
    : key =
          'photo_upload_${sha256.convert(utf8.encode(jsonEncode([issuer, apiBase, owner])))}';
  final String key;
  @override
  Future<String?> load() async {
    final value = (await SharedPreferences.getInstance()).get(key);
    return value is String && isRequestId(value) ? value : null;
  }

  @override
  Future<void> save(String requestId) async {
    if (!isRequestId(requestId)) throw ArgumentError('invalid_upload_request');
    if (!await (await SharedPreferences.getInstance()).setString(
      key,
      requestId,
    )) {
      throw StateError('upload_pointer_unavailable');
    }
  }
}
