import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/listing_photo_preview.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

import 'editorial_api_test.dart' show StaffFixture;

const revision = '11111111-1111-4111-8111-111111111111';

void main() {
  final jpeg = File('test/fixtures/staff_preview.jpg').readAsBytesSync();

  test(
    'private JPEG uses exact revision, injected staff bearer and one attempt',
    () async {
      var calls = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'GET');
          expect(
            request.url.toString(),
            'https://rac.test/api/admin/staff/listings/revisions/$revision/photo',
          );
          expect(request.followRedirects, isFalse);
          expect(request.headers['Authorization'], 'Bearer staff-token');
          expect(request.bodyBytes, isEmpty);
          return http.Response.bytes(
            jpeg,
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }),
      );
      expect(await api.listingPhoto(revision), jpeg);
      expect(calls, 1);
      await expectLater(
        api.listingPhoto('../private.raw'),
        throwsArgumentError,
      );
      expect(calls, 1);
    },
  );

  test(
    'private JPEG refuses changed account or bearer after I/O without replay',
    () async {
      for (final changeAccount in [true, false]) {
        final session = StaffFixture();
        var calls = 0;
        final api = EditorialApi(
          session: session,
          origin: Uri.parse('https://rac.test'),
          client: MockClient((request) async {
            calls++;
            if (changeAccount) {
              session.subject = revision;
            } else {
              session.token = 'other-token';
            }
            return http.Response.bytes(
              jpeg,
              200,
              headers: {'content-type': 'image/jpeg'},
            );
          }),
        );
        await expectLater(
          api.listingPhoto(revision),
          throwsA(
            isA<EditorialFailure>().having(
              (e) => e.status,
              'changed session',
              401,
            ),
          ),
        );
        expect(calls, 1);
      }
    },
  );

  test(
    'private JPEG rejects oversize, wrong media, redirects and arbitrary diagnostics',
    () async {
      for (final response in [
        http.Response.bytes(jpeg, 200, headers: {'content-type': 'text/html'}),
        http.Response(
          'private diagnostic',
          200,
          headers: {'content-type': 'image/jpeg'},
        ),
        http.Response.bytes(
          List.filled(5 * 1024 * 1024 + 1, 0),
          200,
          headers: {'content-type': 'image/jpeg'},
        ),
        http.Response('', 302, headers: {'location': 'https://outside.test'}),
        http.Response('{"error":"private diagnostic"}', 503),
      ]) {
        var calls = 0;
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((_) async {
            calls++;
            return response;
          }),
        );
        await expectLater(
          api.listingPhoto(revision),
          throwsA(
            isA<EditorialFailure>()
                .having((e) => e.uncertain, 'read never a write', false)
                .having(
                  (e) => e.toString().contains('private'),
                  'no diagnostics',
                  false,
                ),
          ),
        );
        expect(calls, 1);
      }
    },
  );

  test(
    'photo not-found and MFA responses retain only exact owner error',
    () async {
      for (final code in [
        'listing_photo_not_found',
        'staff_step_up_required',
      ]) {
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient(
            (_) async => http.Response(
              '{"error":"$code"}',
              code == 'staff_step_up_required' ? 403 : 404,
            ),
          ),
        );
        await expectLater(
          api.listingPhoto(revision),
          throwsA(
            isA<EditorialFailure>().having((e) => e.code, 'safe code', code),
          ),
        );
      }
    },
  );

  Future<void> mount(WidgetTester tester, EditorialApi api) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListingPhotoPreview(api: api, revision: revision),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'private preview is explicit, full-frame and outside ImageCache; hides on lifecycle change',
    (tester) async {
      var calls = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((_) async {
          calls++;
          return http.Response.bytes(
            jpeg,
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }),
      );
      await mount(tester, api);
      expect(calls, 0);
      final before = PaintingBinding.instance.imageCache.currentSize;
      await tester.tap(find.byType(OutlinedButton));
      // Native codec completion uses real asynchronous work, not fake-clock timers.
      for (
        var attempt = 0;
        attempt < 100 && find.byType(RawImage).evaluate().isEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      expect(calls, 1);
      expect(find.byType(RawImage), findsOneWidget);
      expect(
        tester.widget<RawImage>(find.byType(RawImage)).fit,
        BoxFit.contain,
      );
      expect(PaintingBinding.instance.imageCache.currentSize, before);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(calls, 1);
      expect(find.byType(RawImage), findsNothing);
    },
  );

  testWidgets('leaving a private preview discards a late response', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    final api = EditorialApi(
      session: StaffFixture(),
      origin: Uri.parse('https://rac.test'),
      client: MockClient((_) => response.future),
    );
    await mount(tester, api);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    response.complete(
      http.Response.bytes(jpeg, 200, headers: {'content-type': 'image/jpeg'}),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
