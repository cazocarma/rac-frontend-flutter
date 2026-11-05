import 'dart:ui' as ui;

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
  });
  final EditorialApi api;
  final String revision;
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
    if (oldWidget.api != widget.api || oldWidget.revision != widget.revision) {
      discard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && mounted) setState(discard);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    discard();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      discard();
      busy = true;
      scope = widget.api.photoAccountScope;
    });
    final attempt = generation;
    try {
      final bytes = await widget.api.listingPhoto(widget.revision);
      if (!currentAttempt(attempt)) return;
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
    } catch (_) {
      if (mounted && generation == attempt) {
        setState(() {
          busy = false;
          failed = true;
        });
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
            onPressed: () => setState(discard),
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
