import 'dart:convert';
import 'package:oidc/oidc.dart';
import 'package:rentacompa/features/staff/editorial_journal.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/staff/editorial_api.dart';
import 'package:rentacompa/features/staff/listing_review_console.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

import 'editorial_api_test.dart' show StaffFixture;

const revision = '11111111-1111-4111-8111-111111111111';

void main() {
  testWidgets(
    'reload recovers an approval absent from the queue without automatic dispatch',
    (tester) async {
      final session = StaffFixture();
      final store = OidcMemoryStore();
      final journal = EditorialJournal(
        store: store,
        managerId: 'listing-reload',
      );
      final command =
          EditorialCommand('listings/revisions/$revision/approval', {
            'event_id': '22222222-2222-4222-8222-222222222222',
            'expected_version': '3',
            'sha256': 'a' * 64,
          });
      await journal.save(
        command: command,
        subject: session.subject,
        issuer: session.claims['iss'] as String,
        origin: 'https://rac.test',
      );
      var writes = 0;
      final api = EditorialApi(
        session: session,
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          if (request.method == 'GET')
            return http.Response('{"items":[],"next_cursor":""}', 200);
          writes++;
          expect(request.url.path, command.path);
          expect(request.body, command.encodedBody);
          return http.Response(
            jsonEncode({
              'event_id': jsonDecode(command.encodedBody)['event_id'],
              'revision_id': revision,
              'decision': 'approved',
              'listing_version': '4',
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
            body: ListingReviewConsole(
              api: api,
              journal: EditorialJournal(
                store: store,
                managerId: 'listing-reload',
              ),
              permissions: const {'listings.read', 'listings.review'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(writes, 0);
      final t = AppLocalizations.of(
        tester.element(find.byType(ListingReviewConsole)),
      )!;
      await tester.tap(find.text(t.staffListingRetry));
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.text(t.staffListingApproved), findsOneWidget);
      expect(
        await journal.pending(
          subject: session.subject,
          issuer: session.claims['iss'] as String,
          origin: 'https://rac.test',
        ),
        isEmpty,
      );
    },
  );

  testWidgets(
    'a photo-bound revision cannot be approved before media review is available',
    (tester) async {
      var commands = 0;
      final api = EditorialApi(
        session: StaffFixture(),
        origin: Uri.parse('https://rac.test'),
        client: MockClient((request) async {
          if (request.url.path.endsWith('/queue')) {
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'id': revision,
                    'risk_score': 0,
                    'submitted_at': '2026-11-05T10:00:00Z',
                  },
                ],
                'next_cursor': '',
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/approval')) {
            commands++;
            return http.Response('{}', 200);
          }
          return http.Response(
            jsonEncode({
              'id': revision,
              'listing_version': '1',
              'sha256': 'a' * 64,
              'is_pending': true,
              'is_self': false,
              'payload': {
                'display_name': 'Photo fixture',
                'description': 'Synthetic',
                'price_clp_per_hour': 12000,
                'photo_version': '22222222-2222-4222-8222-222222222222',
              },
              'assessment': {'fields': []},
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
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(ListingReviewConsole)),
      )!;
      expect(find.text(t.staffListingPhoto), findsOneWidget);
      expect(find.text(t.staffListingApprove), findsNothing);
      expect(commands, 0);
    },
  );
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('listing console $locale $width reviews and approves', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final approvals = <String>[];
        var approvalReply = <http.Response Function()>[
          () => http.Response('{"error":"listing_photo_unapproved"}', 409),
          () => throw http.ClientException('connection reset'),
          () => http.Response(
            jsonEncode({
              'event_id': jsonDecode(approvals.last)['event_id'],
              'revision_id': revision,
              'decision': 'approved',
              'listing_version': '4',
            }),
            200,
          ),
        ];
        var pending = true;
        final api = EditorialApi(
          session: StaffFixture(),
          origin: Uri.parse('https://rac.test'),
          client: MockClient((request) async {
            final path = request.url.path;
            if (path == '/api/admin/staff/listings/queue') {
              expect(request.url.query, 'limit=20');
              return http.Response(
                jsonEncode({
                  'items': [
                    if (pending)
                      {
                        'id': revision,
                        'risk_score': 30,
                        'submitted_at': '2026-11-05T10:00:00.000000Z',
                      },
                  ],
                  'next_cursor': '',
                }),
                200,
              );
            }
            if (path == '/api/admin/staff/listings/revisions/$revision') {
              return http.Response(
                jsonEncode({
                  'id': revision,
                  'listing_version': '3',
                  'sha256': 'a' * 64,
                  'is_pending': true,
                  'is_self': false,
                  'payload': {
                    'display_name': 'Cris A',
                    'description': 'Synthetic listing for review',
                    'biography': '',
                    'activities': [
                      {'slug': 'cine', 'note': ''},
                    ],
                    'price_clp_per_hour': 12000,
                  },
                  'assessment': {
                    'fields': [
                      {
                        'result': {
                          'signals': [
                            {'category': 'drugs'},
                          ],
                        },
                      },
                    ],
                  },
                }),
                200,
              );
            }
            if (path ==
                '/api/admin/staff/listings/revisions/$revision/approval') {
              approvals.add(request.body);
              final reply = approvalReply.removeAt(0)();
              if (reply.statusCode == 200) pending = false;
              return reply;
            }
            return http.Response('{"error":"not_found"}', 404);
          }),
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
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
        expect(find.text(t.staffListingSignalsNote), findsOneWidget);
        await tester.tap(find.text(t.staffListingRisk(30)));
        await tester.pumpAndSettle();
        expect(find.text('Cris A'), findsOneWidget);
        expect(find.text(t.staffListingSignals(1)), findsOneWidget);
        expect(find.text(t.staffListingNegativePending), findsOneWidget);

        // A known owner refusal is explained and the next attempt is new.
        await tester.tap(find.text(t.staffListingApprove));
        await tester.pumpAndSettle();
        expect(find.text(t.staffListingPhoto), findsOneWidget);
        // An uncertain result keeps the exact command for a manual retry.
        await tester.tap(find.text(t.staffListingApprove));
        await tester.pumpAndSettle();
        expect(find.text(t.staffListingUncertain), findsOneWidget);
        await tester.tap(find.text(t.staffListingRetry));
        await tester.pumpAndSettle();
        expect(approvals, hasLength(3));
        expect(approvals[0], isNot(approvals[1]));
        expect(approvals[2], approvals[1]);
        final sent = jsonDecode(approvals[2]) as Map<String, dynamic>;
        expect(sent.keys.toSet(), {'event_id', 'expected_version', 'sha256'});
        expect(sent['expected_version'], '3');
        expect(find.text(t.staffListingApproved), findsOneWidget);
        expect(find.text(t.staffListingEmpty), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('read-only staff sees no approval and self review is refused', (
    tester,
  ) async {
    final api = EditorialApi(
      session: StaffFixture(),
      origin: Uri.parse('https://rac.test'),
      client: MockClient((request) async {
        if (request.url.path.endsWith('/queue')) {
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': revision,
                  'risk_score': 0,
                  'submitted_at': '2026-11-05T10:00:00.000000Z',
                },
              ],
              'next_cursor': '',
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'id': revision,
            'listing_version': '1',
            'sha256': 'b' * 64,
            'is_pending': true,
            'is_self': true,
            'payload': {'display_name': 'Own', 'activities': []},
            'assessment': {'fields': []},
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
    await tester.tap(find.text(t.staffListingRisk(0)));
    await tester.pumpAndSettle();
    expect(find.text(t.staffListingSelf), findsOneWidget);
    expect(find.text(t.staffListingApprove), findsNothing);
    expect(find.text(t.staffListingNoSignals), findsOneWidget);
  });
}
