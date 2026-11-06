import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';

/// Explicit, memory-only access to the owner's exact pending JPEG. RawImage
/// avoids putting private bytes in Flutter's global ImageCache.
class ListingPhotoPreview extends StatefulWidget {
  const ListingPhotoPreview({
    super.key,
    required this.api,
    required this.revision,
    this.expectedSha256,
    this.onVerified,
  });
  final EditorialApi api;
  final String revision;

  /// When set, only bytes whose SHA-256 equals the reviewed summary are shown
  /// and [onVerified] reports whether that exact image is on screen.
  final String? expectedSha256;
  final ValueChanged<bool>? onVerified;
  @override
  State<ListingPhotoPreview> createState() => _ListingPhotoPreviewState();
}

class _ListingPhotoPreviewState extends State<ListingPhotoPreview>
    with WidgetsBindingObserver {
  ui.Image? image;
  bool busy = false, failed = false;
  int generation = 0;
  String? scope;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void discard() {
    generation++;
    image?.dispose();
    image = null;
    busy = false;
    failed = false;
    scope = null;
  }

  @override
  void didUpdateWidget(covariant ListingPhotoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.api != widget.api ||
        oldWidget.revision != widget.revision ||
        oldWidget.expectedSha256 != widget.expectedSha256) {
      discard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && mounted) close();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    discard();
    super.dispose();
  }

  void close() {
    setState(discard);
    widget.onVerified?.call(false);
  }

  Future<void> load() async {
    widget.onVerified?.call(false);
    setState(() {
      discard();
      busy = true;
      scope = widget.api.photoAccountScope;
    });
    final attempt = generation;
    try {
      final bytes = await widget.api.listingPhoto(widget.revision);
      if (!currentAttempt(attempt)) return;
      final expected = widget.expectedSha256;
      if (expected != null && sha256.convert(bytes).toString() != expected) {
        throw const FormatException('Preview differs from reviewed photo');
      }
      final codec = await ui.instantiateImageCodec(bytes);
      ui.FrameInfo frame;
      try {
        frame = await codec.getNextFrame();
      } finally {
        codec.dispose();
      }
      if (!currentAttempt(attempt)) {
        frame.image.dispose();
        return;
      }
      setState(() {
        image = frame.image;
        busy = false;
      });
      widget.onVerified?.call(widget.expectedSha256 != null);
    } catch (_) {
      if (mounted && generation == attempt) {
        setState(() {
          busy = false;
          failed = true;
        });
        widget.onVerified?.call(false);
      }
    }
  }

  bool currentAttempt(int attempt) {
    if (!mounted || generation != attempt) return false;
    if (scope != widget.api.photoAccountScope) {
      setState(() {
        discard();
        failed = true;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (image != null && scope == widget.api.photoAccountScope) ...[
          Semantics(
            label: t.staffListingPhotoPreviewLabel,
            image: true,
            child: SizedBox(
              height: 320,
              width: double.infinity,
              child: RawImage(image: image, fit: BoxFit.contain),
            ),
          ),
          TextButton.icon(
            onPressed: close,
            icon: const Icon(Icons.visibility_off_outlined),
            label: Text(t.staffListingPhotoPreviewClose),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: busy ? null : load,
            icon: const Icon(Icons.image_outlined),
            label: Text(t.staffListingPhotoPreviewOpen),
          ),
          if (busy) const LinearProgressIndicator(),
          if (failed)
            Text(
              t.staffListingPhotoPreviewFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ],
    );
  }
}
