import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../shared/services/auth_session.dart';

/// Keep the exact command in memory until an uncertain result is resolved.
/// Neither credentials nor unpublished legal text belong in preferences/logs.
class EditorialCommand {
  factory EditorialCommand.restore(String operation, String encodedBody) {
    final decoded = jsonDecode(encodedBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved command');
    }
    final command = EditorialCommand(operation, decoded);
    if (command.encodedBody != encodedBody) {
      throw const FormatException('Saved command is not canonical');
    }
    return command;
  }
  EditorialCommand(String operation, Map<String, dynamic> body)
    : path = _path(operation),
      encodedBody = jsonEncode(body) {
    if (body['event_id'] is! String || (body['event_id'] as String).isEmpty) {
      throw ArgumentError('A stable event_id is required');
    }
    if (isListing) {
      final version = body['expected_version'];
      if (body.length != 3 ||
          !_reference.hasMatch(body['event_id'] as String) ||
          body['event_id'] == '00000000-0000-0000-0000-000000000000' ||
          version is! String ||
          !RegExp(r'^(0|[1-9][0-9]{0,18})$').hasMatch(version) ||
          BigInt.parse(version) > BigInt.parse('9223372036854775806') ||
          body['sha256'] is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(body['sha256'] as String)) {
        throw ArgumentError('Exact listing command required');
      }
    }
  }

  final String path;
  final String encodedBody;
  static final _reference = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );
  static final _listing = RegExp(
    r'^listings/revisions/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/(photo-approval|approval)$',
  );
  bool get isListing => path.startsWith('/api/admin/staff/listings/');
  String? get listingRevision =>
      _listing.firstMatch(path.substring('/api/admin/staff/'.length))?.group(1);

  static String _path(String operation) {
    const operations = {
      'documents/drafts',
      'documents/reviews',
      'documents/publications',
      'documents/activations',
      'assessments/drafts',
      'assessments/reviews',
      'assessments/publications',
    };
    final listing = _listing.firstMatch(operation);
    if (!operations.contains(operation) &&
        (listing == null ||
            listing.group(1) == '00000000-0000-0000-0000-000000000000')) {
      throw ArgumentError('Unknown editorial operation');
    }
    return '/api/admin/staff/$operation';
  }
}

/// Owner outcomes the console can explain; any other body is discarded.
const listingFailureCodes = {
  'listing_self_review',
  'listing_revision_not_found',
  'listing_review_conflict',
  'listing_owner_prerequisites_required',
  'listing_not_publishable',
  'listing_policy_changed',
  'listing_owner_restricted',
  'listing_activity_unavailable',
  'listing_photo_unapproved',
  'listing_photo_not_found',
};

class EditorialFailure implements Exception {
  const EditorialFailure(this.status, {required this.uncertain, this.code});
  final int? status;
  final bool uncertain;
  final String? code;
  bool get authenticationRequired =>
      status == 401 || (status == 403 && code == 'staff_step_up_required');
  @override
  String toString() => 'Editorial request failed';
}

/// Uses only the injected staff session. Never provisions an ordinary profile,
/// infers permissions from realm roles, refreshes MFA, or retries a write.
class EditorialApi {
  EditorialApi({
    required this.session,
    required this.client,
    required Uri origin,
  }) : origin = _origin(origin);

  final AuthSession session;
  final http.Client client;
  final Uri origin;

  static Uri _origin(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('Explicit API origin required');
    }
    return uri;
  }

  Future<Map<String, String>> _headers() async {
    final token = await session.accessToken();
    if (token == null || token.isEmpty) {
      throw const EditorialFailure(401, uncertain: false);
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> sessionInfo() =>
      _get('/api/admin/staff/session');

  Future<int> registryHead(String locale) async {
    if (!{'es', 'en'}.contains(locale)) {
      throw ArgumentError('Known locale required');
    }
    final result = await _get('/api/admin/staff/documents/registry/$locale');
    final version = result['registry_version'];
    // Both expected and expected+1 must be represented exactly in JavaScript.
    if (result.length != 1 ||
        version is! int ||
        version < 0 ||
        version > 9007199254740990) {
      throw const EditorialFailure(200, uncertain: false);
    }
    return version;
  }

  Future<Map<String, dynamic>> read(String resource, String id) {
    if (!{'documents', 'assessments'}.contains(resource) ||
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(id)) {
      throw ArgumentError('Exact resource reference required');
    }
    return _get('/api/admin/staff/$resource/$id');
  }

  /// Listing review owner routes (P08) share this transport and its limits.
  Future<Map<String, dynamic>> listingRead(String path) {
    if (!path.startsWith('/api/admin/staff/listings/')) {
      throw ArgumentError('Listing review route required');
    }
    return _get(path);
  }

  /// Used only to discard private images when the injected staff account changes.
  /// These claims never authorize a request; both server hops verify the bearer.
  String? get photoAccountScope {
    final issuer = session.claims['iss'];
    final subject = session.claims['sub'];
    if (issuer is! String ||
        issuer.isEmpty ||
        subject is! String ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ).hasMatch(subject)) {
      return null;
    }
    return jsonEncode([issuer, subject]);
  }

  Future<Uint8List> listingPhoto(String revision) async {
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    ).hasMatch(revision)) {
      throw ArgumentError('Exact listing revision required');
    }
    final scope = photoAccountScope;
    if (scope == null) throw const EditorialFailure(401, uncertain: false);
    final headers = await _headers();
    if (scope != photoAccountScope) {
      throw const EditorialFailure(401, uncertain: false);
    }
    try {
      final response = await _send(
        'GET',
        '/api/admin/staff/listings/revisions/$revision/photo',
        headers,
        null,
        5 * 1024 * 1024,
        const Duration(seconds: 18),
      );
      if (scope != photoAccountScope ||
          headers['Authorization'] != 'Bearer ${await session.accessToken()}' ||
          scope != photoAccountScope) {
        throw const EditorialFailure(401, uncertain: false);
      }
      if (response.statusCode != 200) {
        _decode(response, write: false);
        throw const EditorialFailure(null, uncertain: false);
      }
      final bytes = response.bodyBytes;
      if (response.headers['content-type']?.split(';').first.trim() !=
              'image/jpeg' ||
          bytes.length < 3 ||
          bytes[0] != 0xff ||
          bytes[1] != 0xd8 ||
          bytes[2] != 0xff) {
        throw const EditorialFailure(200, uncertain: false);
      }
      return Uint8List.fromList(bytes);
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: false);
    }
  }

  Future<Map<String, dynamic>> listingWrite(
    String path,
    String encodedBody, {
    String? expectedAccountScope,
  }) async {
    if (!path.startsWith('/api/admin/staff/listings/revisions/')) {
      throw ArgumentError('Listing review route required');
    }
    final scope = expectedAccountScope ?? photoAccountScope;
    if (scope == null || scope != photoAccountScope)
      throw const EditorialFailure(401, uncertain: false);
    final headers = await _headers();
    if (scope != photoAccountScope)
      throw const EditorialFailure(401, uncertain: false);
    try {
      // Exactly one attempt; a manual retry resends the same frozen command.
      final response = await _send(
        'POST',
        path,
        headers,
        encodedBody,
        1048576,
        path.endsWith('/photo-approval')
            ? const Duration(seconds: 40)
            : const Duration(seconds: 8),
      );
      if (scope != photoAccountScope ||
          headers['Authorization'] != 'Bearer ${await session.accessToken()}' ||
          scope != photoAccountScope) {
        throw const EditorialFailure(401, uncertain: true);
      }
      return _decode(response, write: true);
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: true);
    }
  }

  Future<bool> photoApprovalEnabled() async {
    final scope = photoAccountScope;
    if (scope == null) throw const EditorialFailure(401, uncertain: false);
    final result = await _get('/api/admin/staff/listings/capabilities');
    if (scope != photoAccountScope)
      throw const EditorialFailure(401, uncertain: false);
    if (result.length != 1 || result['photo_approval_enabled'] is! bool)
      throw const EditorialFailure(200, uncertain: false);
    return result['photo_approval_enabled'] as bool;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _headers();
    try {
      return _decode(await _send('GET', path, headers), write: false);
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: false);
    }
  }

  Future<Map<String, dynamic>> submit(EditorialCommand command) async {
    final headers = await _headers();
    try {
      // Exactly one attempt. A manual retry receives the same frozen command.
      return _decode(
        await _send('POST', command.path, headers, command.encodedBody),
        write: true,
      );
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: true);
    }
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, String> headers, [
    String? body,
    int maxBytes = 1048576,
    Duration timeout = const Duration(seconds: 8),
  ]) async {
    final request = http.Request(method, origin.resolve(path))
      ..followRedirects = false
      ..headers.addAll(headers);
    if (body != null) request.body = body;
    return (() async {
      final response = await client.send(request);
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        if (bytes.length + chunk.length > maxBytes) {
          throw const FormatException('Editorial response too large');
        }
        bytes.addAll(chunk);
      }
      return http.Response.bytes(
        bytes,
        response.statusCode,
        headers: response.headers,
      );
    })().timeout(timeout);
  }

  Map<String, dynamic> _decode(http.Response response, {required bool write}) {
    if (response.statusCode != 200) {
      String? code;
      try {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        if (error is Map<String, dynamic> &&
            error.length == 1 &&
            (error['error'] == 'staff_step_up_required' ||
                listingFailureCodes.contains(error['error']))) {
          code = error['error'] as String;
        }
      } catch (_) {
        // Never retain arbitrary upstream bodies or diagnostics.
      }
      throw EditorialFailure(
        response.statusCode,
        code: code,
        uncertain:
            write &&
            (code == 'staff_step_up_required' ||
                !{400, 401, 403, 404, 409}.contains(response.statusCode)),
      );
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (_) {
      throw EditorialFailure(response.statusCode, uncertain: write);
    }
  }
}
