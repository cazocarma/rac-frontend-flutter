import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/listing/data/listing_api.dart';
import 'package:rentacompa/features/listing/ui/listing_review_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';

class FakeListingApi extends ListingApi {
  FakeListingApi() : super('http://fixture.invalid');
  OwnListing? current;
  String? failure;
  int status = 400;
  final sent = <(String, Map<String, dynamic>)>[];
  @override
  Future<OwnListing?> state() async => current;

  @override
  Future<void> submit(
    String expectedVersion,
    Map<String, dynamic> listing,
  ) async {
    sent.add((expectedVersion, listing));
    if (failure != null) throw ApiException(status, failure!);
    current = OwnListing(
      state: 'unpublished',
      version: '${int.parse(expectedVersion) + 1}',
      pending: true,
      published: current?.published ?? false,
    );
  }
}

const draft = {'display_name': 'Cris A', 'description': 'Synthetic fixture'};

void main() {
  test('existing review photo is retained without using a mutable avatar', () {
    const photo = '22222222-2222-4222-8222-222222222222';
    final listing = OwnListing.fromJson({
      'state': 'published',
      'version': '3',
      'pending': null,
      'published': {
        'listing': {'photo_version': photo},
      },
    });
    expect(listing.photoVersion, photo);
    expect(
      () => OwnListing.fromJson({
        'state': 'unpublished',
        'version': '1',
        'pending': {
          'listing': {'photo_version': 'https://external.invalid/photo'},
        },
      }),
      throwsFormatException,
    );
  });
  testWidgets(
    'photo selection is explicit and submission keeps its exact reference',
    (tester) async {
      const photo = '22222222-2222-4222-8222-222222222222';
      final api = FakeListingApi();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ListingReviewScreen(
            api: api,
            draft: () async => draft,
            selectPhoto: () async => photo,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(ListingReviewScreen)),
      )!;
      expect(api.sent, isEmpty);
      await tester.tap(find.text(t.photoUploadOpen));
      await tester.pumpAndSettle();
      expect(find.text(t.listingReviewPhotoSelected), findsOneWidget);
      expect(api.sent, isEmpty);
      await tester.ensureVisible(find.text(t.listingReviewSubmit));
      await tester.tap(find.text(t.listingReviewSubmit));
      await tester.pumpAndSettle();
      expect(api.sent.single.$2['photo_version'], photo);
      await tester.tap(find.text(t.listingReviewPhotoRemove));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.listingReviewResubmit));
      await tester.pumpAndSettle();
      expect(api.sent.last.$2['photo_version'], '');
    },
  );
  test('draft maps the saved profile without photo or area', () {
    final result = listingDraft(
      {
        'nombre': ' Cris ',
        'biografia': null,
        'intereses': ['cine'],
      },
      {
        'profile': {
          'descripcion': 'Compartamos una tarde de cine',
          'tarifa_hora': 12000.0,
          'actividades': [
            {'slug': 'cine', 'nota': 'Estrenos'},
            {'slug': 'teatro'},
          ],
        },
      },
    );
    expect(result['display_name'], 'Cris');
    expect(result['biography'], '');
    expect(result['price_clp_per_hour'], 12000);
    expect(result['activities'], [
      {'slug': 'cine', 'note': 'Estrenos'},
      {'slug': 'teatro', 'note': ''},
    ]);
    expect(result['photo_version'], '');
    expect(result['area_code'], '');
  });

  test('a 202 review acknowledgement is not an error', () async {
    final api = ListingApi(
      'http://fixture.invalid',
      token: () async => 'token',
      client: MockClient((request) async {
        expect(request.url.path, '/api/user/me/listing/submissions');
        expect(jsonDecode(request.body)['expected_version'], '3');
        return http.Response('{"status":"submitted"}', 202);
      }),
    );
    await api.submit('3', draft);
  });

  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('listing review $locale $width sends and shows states', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = FakeListingApi();
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ListingReviewScreen(api: api, draft: () async => draft),
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(ListingReviewScreen)),
        )!;
        expect(find.text(t.listingReviewNone), findsOneWidget);
        expect(find.text(t.listingReviewNoDeadline), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(t.listingReviewSubmit));
        await tester.pumpAndSettle();
        expect(api.sent.single.$1, '0');
        expect(api.sent.single.$2, draft);
        expect(find.text(t.listingReviewSent), findsOneWidget);
        expect(find.text(t.listingReviewResubmit), findsOneWidget);

        for (final (code, status, message) in [
          ('public_contact_not_allowed', 400, t.listingReviewContact),
          ('invalid_listing', 400, t.listingReviewInvalid),
          ('compa_profile_required', 404, t.listingReviewNeedsProfile),
          ('IDENTITY_VERIFICATION_REQUIRED', 428, t.listingReviewIdentity),
          ('listing_version_conflict', 409, t.listingReviewConflict),
          ('private_detail', 500, t.listingReviewSubmitFailed),
        ]) {
          api
            ..failure = code
            ..status = status;
          await tester.tap(find.text(t.listingReviewResubmit));
          await tester.pumpAndSettle();
          expect(find.text(message), findsOneWidget, reason: code);
          expect(find.textContaining('private_detail'), findsNothing);
        }
        expect(api.sent.last.$1, '1');

        api
          ..failure = 'listing_submission_unavailable'
          ..status = 503;
        await tester.tap(find.text(t.listingReviewResubmit));
        await tester.pumpAndSettle();
        expect(find.text(t.listingReviewUnavailable), findsOneWidget);
        expect(find.text(t.listingReviewResubmit), findsNothing);

        api.current = const OwnListing(
          state: 'published',
          version: '4',
          pending: false,
          published: true,
          decision: 'changes_requested',
        );
        await tester.tap(find.byTooltip(t.listingReviewRefresh));
        await tester.pumpAndSettle();
        expect(find.text(t.listingReviewChanges), findsOneWidget);
        expect(find.text(t.listingReviewHasApproved), findsOneWidget);
        expect(find.text(t.listingReviewSubmit), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
