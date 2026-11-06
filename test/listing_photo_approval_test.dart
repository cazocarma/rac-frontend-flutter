import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';
import 'package:rentacompa/features/staff/listing_review_console.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

import 'editorial_api_test.dart' show StaffFixture;

const revision = '11111111-1111-4111-8111-111111111111';
const photo = '33333333-3333-4333-8333-333333333333';

void main() {
  final jpeg = File('test/fixtures/staff_preview.jpg').readAsBytesSync();
  final digest = sha256.convert(jpeg).toString();

  Future<List<http.Request>> run(
    WidgetTester tester, {
    required String summaryDigest,
    bool enabled = true,
  }) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final writes = <http.Request>[];
    final api = EditorialApi(
      session: StaffFixture(),
      origin: Uri.parse('https://rac.test'),
      client: MockClient((request) async {
        final path = request.url.path;
        if (request.method == 'POST') {
          writes.add(request);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'event_id': body['event_id'],
              'revision_id': revision,
              'decision': 'approved',
              'listing_version': '8',
            }),
            200,
          );
        }
        if (path.endsWith('/capabilities')) {
          return http.Response(
            jsonEncode({'photo_approval_enabled': enabled}),
            200,
          );
        }
        if (path.endsWith('/queue')) {
          return http.Response(
            jsonEncode({
              'items': [
                if (writes.isEmpty)
                  {
                    'id': revision,
                    'risk_score': 40,
                    'submitted_at': '2026-11-05T10:00:00.000000Z',
                  },
              ],
              'next_cursor': '',
            }),
            200,
          );
        }
        if (path.endsWith('/photo')) {
          return http.Response.bytes(
            jpeg,
            200,
            headers: {'content-type': 'image/jpeg'},
          );
        }
        return http.Response(
          jsonEncode({
            'id': revision,
            'listing_version': '7',
            'sha256': 'a' * 64,
            'is_pending': true,
            'is_self': false,
            'payload': {
              'display_name': 'Photo fixture',
              'description': 'Synthetic',
              'activities': [],
              'price_clp_per_hour': 12000,
              'photo_version': photo,
            },
            'assessment': {'fields': []},
            'photo_review': {
              'sha256': summaryDigest,
              'risk_score': 40,
              'disposition': 'needs_review',
              'pending_checks': ['banned_image_similarity', 'human_review'],
              'unevaluated': [],
              'signals': [
                {'category': 'contact', 'rule_id': 'contact.phone'},
              ],
              'similarity': {'state': 'not_configured', 'match_count': 1},
            },
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ListingReviewConsole(
              journal: EditorialJournal(store: OidcMemoryStore()),
              api: api,
              permissions: const {'listings.read', 'listings.review'},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final t = AppLocalizations.of(
      tester.element(find.byType(ListingReviewConsole)),
    )!;
    await tester.tap(find.text(t.staffListingRisk(40)));
    await tester.pumpAndSettle();
    expect(find.text(t.staffListingPhotoSignals('contact')), findsOneWidget);
    expect(find.text(t.staffListingPhotoMatches(1)), findsOneWidget);
    expect(
      find.text(
        t.staffListingPhotoCoverageIncomplete(
          t.staffListingPhotoSimilarityPending,
        ),
      ),
      findsOneWidget,
    );
    if (!enabled) {
      expect(find.text(t.staffListingPhotoDisabled), findsOneWidget);
      expect(find.text(t.staffListingPhotoApprove), findsNothing);
      return writes;
    }
    // Neither the confirmation nor the command is available before the
    // exact preview is on screen.
    expect(find.text(t.staffListingPhotoOpenFirst), findsOneWidget);
    await tester.tap(find.text(t.staffListingPhotoApprove));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(writes, isEmpty);
    await tester.tap(find.text(t.staffListingPhotoPreviewOpen));
    for (
      var attempt = 0;
      attempt < 100 &&
          find.byType(RawImage).evaluate().isEmpty &&
          find.text(t.staffListingPhotoPreviewFailed).evaluate().isEmpty;
      attempt++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text(t.staffListingPhotoApprove));
    await tester.pumpAndSettle();
    if (writes.isNotEmpty) {
      expect(find.text(t.staffListingApproved), findsOneWidget);
    }
    return writes;
  }

  testWidgets(
    'photo approval requires the exact verified preview and consent',
    (tester) async {
      final writes = await run(tester, summaryDigest: digest);
      expect(writes, hasLength(1));
      expect(
        writes.single.url.path,
        '/api/admin/staff/listings/revisions/$revision/photo-approval',
      );
      final sent = jsonDecode(writes.single.body) as Map<String, dynamic>;
      expect(sent.keys.toSet(), {'event_id', 'expected_version', 'sha256'});
      expect(sent['expected_version'], '7');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a preview that differs from the reviewed digest blocks approval',
    (tester) async {
      final writes = await run(tester, summaryDigest: 'b' * 64);
      expect(writes, isEmpty);
      final t = AppLocalizations.of(
        tester.element(find.byType(ListingReviewConsole)),
      )!;
      expect(find.text(t.staffListingPhotoPreviewFailed), findsOneWidget);
      expect(find.byType(RawImage), findsNothing);
    },
  );

  testWidgets('photo approval stays closed without the owner capability', (
    tester,
  ) async {
    final writes = await run(tester, summaryDigest: digest, enabled: false);
    expect(writes, isEmpty);
  });
}
