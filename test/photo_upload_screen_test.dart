import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/photos/data/photo_upload_api.dart';
import 'package:rentacompa/features/photos/data/photo_upload_pointer.dart';
import 'package:rentacompa/features/photos/ui/photo_upload_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';
import 'package:rentacompa/shared/services/request_id.dart';
import 'package:rentacompa/shared/widgets/design.dart';

const photoId = '22222222-2222-4222-8222-222222222222';
const savedRequest = '11111111-1111-4111-8111-111111111111';

class PhotoScope {
  String current = 'owner';
}

class MemoryPhotoPointer implements PhotoUploadPointer {
  String? id;
  @override
  Future<String?> load() async => id;
  @override
  Future<void> save(String requestId) async {
    id = requestId;
  }
}

class FakePhotoUploadApi extends PhotoUploadApi {
  FakePhotoUploadApi(PhotoScope scope, this.pointer)
    : super(
        'http://fixture.invalid',
        owner: 'owner',
        subject: () => scope.current,
      );
  final MemoryPhotoPointer pointer;
  bool enabled = true, lostAck = false;
  PhotoSourceStatus? current;
  Completer<PhotoSourceStatus>? pending;
  int uploads = 0, confirms = 0;
  @override
  Future<PhotoUploadConfig> config() async =>
      PhotoUploadConfig(enabled: enabled, maxBytes: 5 * 1024 * 1024);
  @override
  Future<PhotoSourceStatus> byRequest(String id) async {
    if (pending != null) return pending!.future;
    if (current == null)
      throw const ApiException(404, 'photo_source_not_found');
    return current!;
  }

  @override
  Future<PhotoSourceStatus> upload(
    String id,
    Uint8List bytes,
    String mediaType,
  ) async {
    expect(await pointer.load(), id);
    expect(isRequestId(id), isTrue);
    expect(mediaType, 'image/png');
    expect(bytes, isNotEmpty);
    uploads++;
    current = const PhotoSourceStatus(photoId, PhotoSourceState.queued);
    if (lostAck) throw const ApiException(503, 'photo_upload_unavailable');
    return current!;
  }

  @override
  Future<PhotoSourceStatus> confirm(String id) async {
    confirms++;
    return current = const PhotoSourceStatus(photoId, PhotoSourceState.queued);
  }
}

void main() {
  final bytes = File('test/fixtures/review_photo.png').readAsBytesSync();
  Future<AppLocalizations> show(
    WidgetTester tester,
    FakePhotoUploadApi api,
    MemoryPhotoPointer pointer, {
    String locale = 'es',
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: racTheme(Brightness.light),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PhotoUploadScreen(
          api: api,
          pointer: pointer,
          choosePhoto: () async => SelectedReviewPhoto(bytes, 'image/png'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(PhotoUploadScreen)))!;
  }

  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'private photo $locale $width selects explicitly, uploads once and recovers lost ACK',
        (tester) async {
          final pointer = MemoryPhotoPointer();
          final api = FakePhotoUploadApi(PhotoScope(), pointer)..lostAck = true;
          final t = await show(
            tester,
            api,
            pointer,
            locale: locale,
            width: width,
          );
          expect(api.uploads, 0);
          await tester.tap(find.text(t.photoUploadChoose));
          await tester.pumpAndSettle();
          expect(api.uploads, 0);
          expect(pointer.id, isNotNull);
          expect(
            (tester.widget(find.byType(Image)) as Image).fit,
            BoxFit.contain,
          );
          await tester.ensureVisible(find.text(t.photoUploadSend));
          await tester.tap(find.text(t.photoUploadSend));
          await tester.pumpAndSettle();
          expect(api.uploads, 1);
          expect(find.text(t.photoUploadQueued), findsOneWidget);
          expect(find.text(t.photoUploadSaveFailed), findsNothing);
          expect(api.confirms, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('disabled preparation shows construction with no upload action', (
    tester,
  ) async {
    final pointer = MemoryPhotoPointer();
    final api = FakePhotoUploadApi(PhotoScope(), pointer)..enabled = false;
    final t = await show(tester, api, pointer);
    expect(find.text(t.photoUploadConstructionTitle), findsOneWidget);
    expect(find.text(t.photoUploadChoose), findsNothing);
    expect(find.text(t.photoUploadSend), findsNothing);
    expect(api.uploads, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'reload uses only the saved request ID and offers confirmation, not publication',
    (tester) async {
      final pointer = MemoryPhotoPointer()..id = savedRequest;
      final api = FakePhotoUploadApi(PhotoScope(), pointer)
        ..current = const PhotoSourceStatus(
          photoId,
          PhotoSourceState.awaitingUpload,
        );
      final t = await show(tester, api, pointer);
      expect(find.byType(Image), findsNothing);
      expect(find.text(t.photoUploadPendingFile), findsOneWidget);
      await tester.tap(find.text(t.photoUploadConfirmRetry));
      await tester.pumpAndSettle();
      expect(api.confirms, 1);
      expect(api.uploads, 0);
      expect(find.text(t.photoUploadQueued), findsOneWidget);
    },
  );
  testWidgets(
    'ready for human review remains private and shows unfinished review capability',
    (tester) async {
      final pointer = MemoryPhotoPointer()..id = savedRequest;
      final api = FakePhotoUploadApi(PhotoScope(), pointer)
        ..current = const PhotoSourceStatus(
          photoId,
          PhotoSourceState.awaitingReview,
        );
      final t = await show(tester, api, pointer);
      expect(find.text(t.photoUploadReviewConstruction), findsOneWidget);
      expect(find.text(t.photoUploadSend), findsNothing);
      expect(api.uploads, 0);
    },
  );
  testWidgets('account switch in flight hides old account state', (
    tester,
  ) async {
    final pointer = MemoryPhotoPointer()..id = savedRequest;
    final scope = PhotoScope();
    final api = FakePhotoUploadApi(scope, pointer)
      ..pending = Completer<PhotoSourceStatus>();
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PhotoUploadScreen(api: api, pointer: pointer),
      ),
    );
    await tester.pump();
    scope.current = 'other';
    api.pending!.complete(
      const PhotoSourceStatus(photoId, PhotoSourceState.awaitingReview),
    );
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(
      tester.element(find.byType(PhotoUploadScreen)),
    )!;
    expect(find.text(t.photoUploadSessionChanged), findsOneWidget);
    expect(find.text(t.photoUploadReview), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.text(t.photoUploadChoose), findsNothing);
  });
}
