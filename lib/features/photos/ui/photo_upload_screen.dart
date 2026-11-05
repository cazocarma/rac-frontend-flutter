import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/services/request_id.dart';
import '../../../shared/services/session.dart';
import '../../../shared/widgets/design.dart';
import '../data/photo_upload_api.dart';
import '../data/photo_upload_pointer.dart';

class SelectedReviewPhoto {
  SelectedReviewPhoto(Uint8List bytes, this.mediaType)
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();
  final Uint8List bytes;
  final String mediaType;
}

/// The private photo flow is distinct from publication. No success message or
/// callback claims that the profile/photo has become publicly available.
class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({
    super.key,
    this.api,
    this.pointer,
    this.choosePhoto,
    this.selectForListing = false,
  });
  final PhotoUploadApi? api;
  final PhotoUploadPointer? pointer;
  final Future<SelectedReviewPhoto?> Function()? choosePhoto;
  final bool selectForListing;
  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen>
    with WidgetsBindingObserver {
  late final api =
      widget.api ??
      PhotoUploadApi(
        Env.apiBase,
        owner: Session.auth.claims['sub'] as String? ?? '',
      );
  late final pointer =
      widget.pointer ??
      PreferencesPhotoUploadPointer(Env.issuer, Env.apiBase, api.owner);
  PhotoUploadConfig? config;
  PhotoSourceStatus? status;
  SelectedReviewPhoto? selected;
  String? requestId, error;
  bool busy = true, notReceived = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) checkOwner();
  }

  bool checkOwner() {
    if (!mounted) return false;
    if (api.isCurrentOwner) return true;
    setState(() {
      selected = null;
      status = null;
      error = 'photo_session_changed';
      busy = false;
    });
    return false;
  }

  Future<void> load() async {
    if (!checkOwner()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final settings = await api.config();
      final saved = requestId ?? await pointer.load();
      if (!checkOwner()) return;
      setState(() {
        config = settings;
        requestId = saved;
      });
      if (settings.enabled && saved != null) await recover();
    } catch (e) {
      if (checkOwner()) {
        setState(
          () => error = e is ApiException ? e.code : 'photo_load_failed',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> recover({bool keepError = false}) async {
    final id = requestId;
    if (id == null) return;
    try {
      final result = await api.byRequest(id);
      if (!checkOwner()) return;
      setState(() {
        status = result;
        notReceived = false;
        if (!keepError || result.state != PhotoSourceState.awaitingUpload) {
          error = null;
        }
      });
    } on ApiException catch (e) {
      if (!checkOwner()) return;
      if (e.status == 404) {
        setState(() => notReceived = true);
      } else {
        rethrow;
      }
    }
  }

  Future<SelectedReviewPhoto?> pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    final maximum = config?.maxBytes ?? 5 * 1024 * 1024;
    if (await file.length() > maximum) {
      throw const ApiException(413, 'photo_size');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.length > maximum) {
      throw const ApiException(413, 'photo_size');
    }
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    if (!png && !jpeg) throw const ApiException(415, 'photo_format');
    return SelectedReviewPhoto(bytes, png ? 'image/png' : 'image/jpeg');
  }

  Future<void> choose() async {
    if (!checkOwner()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final photo = await (widget.choosePhoto ?? pick)();
      if (photo == null || !checkOwner()) return;
      if (photo.bytes.isEmpty ||
          photo.bytes.length > (config?.maxBytes ?? 5 * 1024 * 1024)) {
        throw const ApiException(413, 'photo_size');
      }
      if (!{'image/jpeg', 'image/png'}.contains(photo.mediaType)) {
        throw const ApiException(415, 'photo_format');
      }
      final id = newRequestId();
      // Save the retry pointer BEFORE starting any upload. No image is persisted.
      await pointer.save(id);
      if (!checkOwner()) return;
      setState(() {
        requestId = id;
        selected = photo;
        status = null;
        notReceived = false;
      });
    } catch (e) {
      if (checkOwner()) {
        setState(
          () => error = e is ApiException ? e.code : 'photo_picker_failed',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> send({bool confirm = false}) async {
    if (!checkOwner()) return;
    final id = requestId, photo = selected, current = status;
    if (id == null ||
        (!confirm && photo == null) ||
        (confirm && current == null)) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = confirm
          ? await api.confirm(current!.assetId)
          : await api.upload(id, photo!.bytes, photo.mediaType);
      if (!checkOwner()) return;
      setState(() {
        status = result;
        notReceived = false;
      });
    } catch (e) {
      if (!checkOwner()) return;
      setState(() => error = e is ApiException ? e.code : 'photo_save_failed');
      try {
        await recover(keepError: true);
      } catch (_) {
        /* Retain the original failure and retry pointer. */
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String failureText(AppLocalizations t) => switch (error) {
    'photo_format' || 'invalid_photo_upload' => t.photoUploadInvalid,
    'photo_size' => t.photoUploadTooLarge,
    'photo_upload_quota_exceeded' => t.photoUploadQuota,
    'account_operation_restricted' => t.photoUploadRestricted,
    'DOCUMENT_ACCEPTANCE_REQUIRED' ||
    'COMPA_ATTESTATION_REQUIRED' ||
    'owner_prerequisites_required' => t.photoUploadDocuments,
    'photo_session_changed' ||
    'invalid_token' ||
    'authentication_required' => t.photoUploadSessionChanged,
    'photo_upload_integrity_mismatch' ||
    'photo_upload_request_conflict' => t.photoUploadIntegrity,
    'photo_picker_failed' => t.photoUploadPickerFailed,
    'photo_load_failed' => t.photoUploadLoadFailed,
    _ => t.photoUploadSaveFailed,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final current = status;
    final active = config?.enabled == true && api.isCurrentOwner;
    final stateText = switch (current?.state) {
      PhotoSourceState.awaitingUpload => t.photoUploadPendingFile,
      PhotoSourceState.queued => t.photoUploadQueued,
      PhotoSourceState.processing => t.photoUploadProcessing,
      PhotoSourceState.processingUnavailable =>
        t.photoUploadProcessingUnavailable,
      PhotoSourceState.correctionRequired => t.photoUploadCorrection,
      PhotoSourceState.awaitingReview => t.photoUploadReview,
      null => notReceived ? t.photoUploadNotReceived : t.photoUploadResume,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(t.photoUploadTitle),
        actions: [
          IconButton(
            tooltip: t.photoUploadRefresh,
            onPressed: busy ? null : load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: PageContent(
          width: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 44,
                color: colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                t.photoUploadIntro,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(t.photoUploadRules),
              const SizedBox(height: 24),
              if (busy) ...[
                LinearProgressIndicator(semanticsLabel: t.photoUploadWorking),
                const SizedBox(height: 16),
              ],
              if (config?.enabled == false) ...[
                Text(
                  t.photoUploadConstructionTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(t.photoUploadConstruction),
              ] else if (active) ...[
                if (selected != null) ...[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Image.memory(
                        selected!.bytes,
                        fit: BoxFit.contain,
                        cacheWidth: 1024,
                        semanticLabel: t.photoUploadLocalPreview,
                        errorBuilder: (_, _, _) =>
                            Center(child: Text(t.photoUploadInvalid)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (requestId != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      stateText,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (current?.state == PhotoSourceState.awaitingReview) ...[
                  const SizedBox(height: 12),
                  Text(t.photoUploadReviewConstruction),
                ],
              ],
              if (error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    failureText(t),
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (active &&
                      widget.selectForListing &&
                      current?.state == PhotoSourceState.awaitingReview)
                    FilledButton.icon(
                      onPressed: busy || !Navigator.of(context).canPop()
                          ? null
                          : () {
                              if (checkOwner()) {
                                Navigator.of(context).pop(current!.assetId);
                              }
                            },
                      icon: const Icon(Icons.check),
                      label: Text(t.photoUploadUsePhoto),
                    ),
                  if (active)
                    OutlinedButton.icon(
                      onPressed: busy ? null : choose,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(t.photoUploadChoose),
                    ),
                  if (active &&
                      selected != null &&
                      (current == null ||
                          current.state == PhotoSourceState.awaitingUpload))
                    FilledButton.icon(
                      onPressed: busy ? null : send,
                      icon: const Icon(Icons.upload_outlined),
                      label: Text(
                        current == null
                            ? t.photoUploadSend
                            : t.photoUploadRetry,
                      ),
                    ),
                  if (active &&
                      current?.state == PhotoSourceState.awaitingUpload)
                    OutlinedButton(
                      onPressed: busy ? null : () => send(confirm: true),
                      child: Text(t.photoUploadConfirmRetry),
                    ),
                  OutlinedButton(
                    onPressed: busy ? null : load,
                    child: Text(t.photoUploadRefresh),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
