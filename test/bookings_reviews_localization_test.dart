import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/compas/data/compa_api.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/features/match/ui/match_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/auth_session.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/widgets/reviews.dart';
import 'auth_test.dart' show FakeSession;

Map<String, dynamic> booking(String id, String state, Duration offset) {
  final start = DateTime.now().add(offset).toUtc();
  return {
    'id': id,
    'estado': state,
    'fecha_inicio': start.toIso8601String(),
    'fecha_fin': start.add(const Duration(hours: 1)).toIso8601String(),
  };
}

/// Serves one provider account: a finished and an active booking it made,
/// plus a pending request it received.
class BookingsFixture {
  bool failMe = false;
  bool empty = false;
  http.Response transition = http.Response('{}', 200);
  http.Response save = http.Response('{}', 201);
  Map<String, dynamic>? review;
  final transitions = <String>[];
  late final users = UserApi(
    'https://api.example',
    client: MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/user/me') {
        return failMe
            ? http.Response('{"error":"private upstream"}', 503)
            : http.Response('{"id":"me"}', 200);
      }
      if (request.method == 'POST') {
        if (save.statusCode == 201) {
          review = {'puntuacion': 5, 'comentario': 'Muy bien'};
        }
        return save;
      }
      return http.Response(jsonEncode({'resena': review}), 200);
    }),
  );
  late final match = MatchApi(
    'https://api.example',
    client: MockClient((request) async {
      final path = request.url.path;
      if (request.method == 'PUT') {
        transitions.add(path);
        return transition;
      }
      if (path.endsWith('/allowance')) {
        return http.Response(
          jsonEncode({
            'disponibles': 0,
            'limite_gratuito': 3,
            'usados': 3,
            'semana_inicio': '2026-10-26',
            'suscripcion_activa': false,
          }),
          200,
        );
      }
      final items = empty
          ? []
          : path.startsWith('/api/match/client/')
          ? [
              booking('finished-1', 'finalizada', const Duration(days: -3)),
              booking('active-22', 'activa', const Duration(days: 2)),
            ]
          : [booking('pending-3', 'pendiente', const Duration(days: 3))];
      return http.Response(jsonEncode({'items': items}), 200);
    }),
  );
}

Widget app(String locale, Widget home) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late AuthSession previous;
  setUp(() {
    previous = Session.auth;
    Session.auth = FakeSession()..signedIn = true;
  });
  tearDown(() => Session.auth = previous);

  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'bookings $locale $width localizes states, quota, cancellation and reviews',
        (tester) async {
          setWidth(tester, width);
          final fixture = BookingsFixture();
          await tester.pumpWidget(
            app(locale, MatchScreen(api: fixture.match, users: fixture.users)),
          );
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(MatchScreen)),
          )!;
          Future<void> tapVisible(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.pumpAndSettle();
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }

          expect(find.text(t.bookingsTitle), findsOneWidget);
          expect(find.text(t.bookingsTabHired), findsOneWidget);
          expect(find.text(t.bookingsTabReceived), findsOneWidget);
          expect(find.text(t.bookingsStatusFinished), findsOneWidget);
          expect(find.text(t.bookingsStatusActive), findsOneWidget);
          expect(
            find.text(t.bookingsReference('finished', t.bookingsRoleHired)),
            findsOneWidget,
          );
          expect(find.text(t.bookingsNoCharge), findsWidgets);
          expect(
            find.text('Confirmada'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );

          await tapVisible(find.text(t.bookingsCancel));
          expect(find.text(t.bookingsCancelTitle), findsOneWidget);
          expect(find.byTooltip(t.bookingsTimeOff), findsOneWidget);
          await tapVisible(find.text(t.bookingsKeep));
          expect(fixture.transitions, isEmpty);

          await tapVisible(find.text(t.reviewWrite));
          expect(find.text(t.reviewDialogTitle), findsOneWidget);
          expect(find.byTooltip(t.reviewStars(5)), findsOneWidget);
          await tapVisible(find.text('5 ★'));
          fixture.save = http.Response('{"error":"conflict"}', 409);
          await tapVisible(find.text(t.reviewPublish));
          expect(find.text(t.reviewConflict), findsOneWidget);
          fixture.save = http.Response('{"error":"private upstream"}', 500);
          await tapVisible(find.text(t.reviewPublish));
          expect(find.text(t.reviewSendFailed), findsOneWidget);
          expect(find.text(t.reviewConflict), findsNothing);
          expect(find.textContaining('private upstream'), findsNothing);
          fixture.save = http.Response('{}', 201);
          await tapVisible(find.text(t.reviewPublish));
          expect(find.text(t.reviewDialogTitle), findsNothing);
          expect(find.text(t.reviewVerified('5')), findsOneWidget);
          expect(find.text(t.reviewWrite), findsNothing);

          await tapVisible(find.text(t.bookingsTabReceived));
          expect(find.text(t.bookingsStatusPending), findsOneWidget);
          expect(
            find.text(t.bookingsReference('pending-', t.bookingsRoleReceived)),
            findsOneWidget,
          );
          fixture.transition = http.Response(
            jsonEncode({
              'error': 'subscription_required',
              'cupo': {'usados': 3, 'semana_inicio': '2026-10-26'},
            }),
            402,
          );
          await tapVisible(find.text(t.bookingsAccept));
          expect(find.text(t.bookingsLimitTitle), findsOneWidget);
          expect(
            find.text(t.bookingsLimitMessage('3', '2026-10-26')),
            findsOneWidget,
          );
          await tapVisible(find.text(t.bookingsLimitOk));
          expect(find.text(t.bookingsUpdateFailed), findsNothing);
          fixture.transition = http.Response('{"error":"private"}', 500);
          await tapVisible(find.text(t.bookingsAccept));
          expect(find.text(t.bookingsUpdateFailed), findsOneWidget);
          expect(fixture.transitions, hasLength(2));
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('bookings $locale retries a failed load into empty states', (
      tester,
    ) async {
      final fixture = BookingsFixture()
        ..failMe = true
        ..empty = true;
      await tester.pumpWidget(
        app(locale, MatchScreen(api: fixture.match, users: fixture.users)),
      );
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(tester.element(find.byType(MatchScreen)))!;
      expect(find.text(t.bookingsLoadFailed), findsOneWidget);
      expect(find.textContaining('private upstream'), findsNothing);
      fixture.failMe = false;
      await tester.tap(find.text(t.bookingsRetry));
      await tester.pumpAndSettle();
      expect(find.text(t.bookingsLoadFailed), findsNothing);
      expect(find.text(t.bookingsEmptyTitle), findsOneWidget);
      expect(find.text(t.bookingsExplore), findsOneWidget);
      await tester.tap(find.text(t.bookingsTabReceived));
      await tester.pumpAndSettle();
      expect(find.text(t.bookingsEmptyReceivedTitle), findsOneWidget);
      await tester.tap(find.byTooltip(t.bookingsRefresh));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('public reviews $locale paginate and retry', (tester) async {
      var fail = true;
      var calls = 0;
      final api = CompaApi(
        'https://api.example',
        client: MockClient((request) async {
          calls++;
          if (fail) return http.Response('{"error":"private"}', 503);
          return http.Response(
            jsonEncode({
              'items': [
                {'puntuacion': 4, 'comentario': 'Genial'},
              ],
              'total': 2,
            }),
            200,
          );
        }),
      );
      await tester.pumpWidget(
        app(
          locale,
          Scaffold(
            body: SingleChildScrollView(
              child: PublicReviews(api: api, id: 'compa-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(PublicReviews)),
      )!;
      expect(find.text(t.reviewsPublicTitle), findsOneWidget);
      expect(find.text(t.reviewsPublicLoadFailed), findsOneWidget);
      fail = false;
      await tester.tap(find.text(t.reviewsPublicLoadFailed));
      await tester.pumpAndSettle();
      expect(find.text(t.reviewsPublicItem('4')), findsOneWidget);
      await tester.tap(find.text(t.reviewsPublicMore));
      await tester.pumpAndSettle();
      expect(find.text(t.reviewsPublicItem('4')), findsNWidgets(2));
      expect(find.text(t.reviewsPublicMore), findsNothing);
      expect(calls, 3);
      expect(tester.takeException(), isNull);
    });
  }
}
