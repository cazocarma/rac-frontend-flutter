import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/booking/ui/booking_screen.dart';
import 'package:rentacompa/features/compas/data/compa_api.dart';
import 'package:rentacompa/features/compas/ui/compa_detail_screen.dart';
import 'package:rentacompa/features/compas/ui/compa_list_screen.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/auth_session.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'auth_test.dart' show FakeSession;

Map<String, dynamic> compa(
  int i, {
  double rating = 4.5,
  int reviews = 1,
  List<String> skills = const ['cine'],
  String? description = 'Plan tranquilo',
}) => {
  'id': 'compa-$i',
  'usuario_id': 'user-$i',
  'nombre': 'Compa $i',
  'tarifa_hora': 12000,
  'rating_promedio': rating,
  'cantidad_resenas': reviews,
  'habilidades': skills,
  'descripcion': description,
};

/// Serves discovery fixtures; mutate fields between pumps to change responses.
class CompaFixture {
  List<Map<String, dynamic>> cards = [compa(1)];
  Map<String, dynamic> detail = compa(1);
  bool fail = false;
  late final api = CompaApi(
    'https://api.example',
    client: MockClient((request) async {
      if (fail) return http.Response('{"error":"private upstream"}', 503);
      final path = request.url.path;
      if (path == '/api/user/skills') return http.Response('["cine"]', 200);
      if (path == '/api/user/compas') {
        return http.Response(jsonEncode(cards), 200);
      }
      if (path.endsWith('/reviews')) {
        return http.Response('{"items":[],"total":0}', 200);
      }
      return http.Response(jsonEncode(detail), 200);
    }),
  );
}

/// Serves one future slot; [submit] decides the booking response.
class MatchFixture {
  Map<String, dynamic> availability = {
    'lunes': ['15:00-18:00'],
  };
  List<String> slots = [
    DateTime.now().add(const Duration(days: 2)).toUtc().toIso8601String(),
  ];
  bool failLoad = false;
  http.Response submit = http.Response('{"id":"session-1"}', 201);
  int submissions = 0;
  late final api = MatchApi(
    'https://api.example',
    client: MockClient((request) async {
      if (request.method == 'POST') {
        submissions++;
        return submit;
      }
      if (failLoad) return http.Response('{"error":"private upstream"}', 503);
      if (request.url.path.endsWith('/slots')) {
        return http.Response(
          jsonEncode({'slots': slots, 'zona_horaria': 'America/Santiago'}),
          200,
        );
      }
      return http.Response(jsonEncode({'availability': availability}), 200);
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

AppLocalizations l10n(WidgetTester tester, Type type) =>
    AppLocalizations.of(tester.element(find.byType(type)))!;

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
        'explore $locale $width localizes counts, empty and failed states',
        (tester) async {
          setWidth(tester, width);
          final fixture = CompaFixture();
          await tester.pumpWidget(
            app(locale, Scaffold(body: CompaListScreen(api: fixture.api))),
          );
          await tester.pumpAndSettle();
          final t = l10n(tester, CompaListScreen);
          expect(find.text(t.exploreTitle), findsOneWidget);
          expect(find.text(t.exploreCount(1, '1')), findsOneWidget);
          expect(find.text(t.exploreAllSkills), findsOneWidget);
          expect(
            find.bySemanticsLabel(
              t.exploreCardSemantics(
                'Compa 1',
                'cine',
                '\$12.000',
                t.exploreCardRating('4.5'),
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text('Encuentra tu compa'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          fixture.cards = [
            for (var i = 1; i <= 12; i++)
              compa(i, rating: 0, skills: const [], description: null),
          ];
          await tester.tap(find.byTooltip(t.exploreRefresh));
          await tester.pumpAndSettle();
          expect(find.text(t.exploreCount(12, '12+')), findsOneWidget);
          expect(find.text(t.exploreNoSkills), findsWidgets);
          expect(find.text(t.exploreNoDescription), findsWidgets);
          expect(find.text(t.exploreNewInRac), findsWidgets);
          expect(find.text(t.exploreShowMore), findsOneWidget);
          fixture.fail = true;
          await tester.tap(find.byTooltip(t.exploreRefresh));
          await tester.pumpAndSettle();
          expect(find.text(t.exploreLoadFailed), findsOneWidget);
          expect(find.text(t.exploreShowMore), findsNothing);
          expect(find.textContaining('private upstream'), findsNothing);
          fixture
            ..fail = false
            ..cards = [];
          await tester.ensureVisible(find.text(t.exploreRetry));
          await tester.tap(find.text(t.exploreRetry));
          await tester.pumpAndSettle();
          expect(find.text(t.exploreLoadFailed), findsNothing);
          expect(find.text(t.exploreEmptyTitle), findsOneWidget);
          expect(find.text(t.exploreShowAll), findsOneWidget);
          fixture.cards = [compa(1)];
          await tester.ensureVisible(find.text(t.exploreShowAll));
          await tester.tap(find.text(t.exploreShowAll));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Compa 1'));
          await tester.tap(find.text('Compa 1'));
          await tester.pumpAndSettle();
          expect(find.text(t.compaDetailTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'compa detail $locale $width localizes ratings, fallbacks and retry',
        (tester) async {
          setWidth(tester, width);
          final fixture = CompaFixture()..fail = true;
          await tester.pumpWidget(
            app(locale, CompaDetailScreen(api: fixture.api, id: 'compa-1')),
          );
          await tester.pumpAndSettle();
          final t = l10n(tester, CompaDetailScreen);
          expect(find.text(t.compaDetailLoadFailed), findsOneWidget);
          expect(find.text(t.compaDetailLoadHelp), findsOneWidget);
          expect(find.textContaining('private upstream'), findsNothing);
          fixture
            ..fail = false
            ..detail = compa(1, reviews: 3, description: null);
          await tester.ensureVisible(find.text(t.compaDetailRetry));
          await tester.tap(find.text(t.compaDetailRetry));
          await tester.pumpAndSettle();
          expect(find.text(t.compaDetailRating('4.5', 3)), findsOneWidget);
          expect(find.text(t.compaDetailNoDescription), findsOneWidget);
          expect(find.text(t.compaDetailActivities), findsOneWidget);
          expect(find.text(t.compaDetailRate('\$12.000')), findsOneWidget);
          expect(find.text(t.compaDetailBookingHelp), findsOneWidget);
          expect(find.text(t.compaDetailBook), findsOneWidget);
          expect(
            find.text('★ 4.5 · 3 reseñas verificadas'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'booking $locale $width localizes steps and classifies exact failures',
        (tester) async {
          setWidth(tester, width);
          final fixture = MatchFixture()..failLoad = true;
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingScreen(
                compaId: 'compa-1',
                compaName: 'Compa 1',
                rate: 12000,
                api: fixture.api,
              ),
              routes: {'/match': (_) => const Scaffold(body: Text('bookings'))},
            ),
          );
          await tester.pumpAndSettle();
          final t = l10n(tester, BookingScreen);
          Future<void> tapVisible(Finder finder) async {
            await tester.ensureVisible(finder);
            await tester.tap(finder);
            await tester.pumpAndSettle();
          }

          expect(find.text(t.bookingTitle), findsOneWidget);
          expect(find.text(t.bookingWith('Compa 1')), findsOneWidget);
          expect(find.text(t.bookingLoadFailed), findsOneWidget);
          expect(find.textContaining('private upstream'), findsNothing);
          expect(find.text(t.bookingHours(1)), findsOneWidget);
          expect(find.text(t.bookingHours(2)), findsOneWidget);
          expect(
            find.text('2 horas'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          fixture
            ..failLoad = false
            ..availability = {}
            ..slots = [];
          await tapVisible(find.text(t.bookingRefresh));
          expect(find.text(t.bookingLoadFailed), findsNothing);
          expect(find.text(t.bookingNoSchedule), findsOneWidget);
          fixture.availability = {
            'lunes': ['15:00-18:00'],
          };
          await tapVisible(find.text(t.bookingHours(2)));
          expect(find.text(t.bookingNoSlots), findsOneWidget);
          expect(
            find.text(t.bookingReferenceValue('\$24.000')),
            findsOneWidget,
          );
          fixture.slots = MatchFixture().slots;
          await tapVisible(find.text(t.bookingRefresh));
          expect(find.text(t.bookingSelectSlot), findsOneWidget);
          expect(find.text(t.bookingNoCharge), findsOneWidget);
          final slot = find.byType(ChoiceChip).last;

          Future<void> attempt(http.Response response, String expected) async {
            fixture.submit = response;
            await tapVisible(slot);
            await tapVisible(find.text(t.bookingSubmit));
            expect(find.text(expected), findsOneWidget);
          }

          await attempt(
            http.Response('{"error":"colision_horaria"}', 400),
            t.bookingSlotTaken,
          );
          await attempt(
            http.Response('{"error":"fuera_de_disponibilidad"}', 400),
            t.bookingAvailabilityChanged,
          );
          await attempt(
            http.Response('{"error":"compa_sin_disponibilidad"}', 400),
            t.bookingAvailabilityChanged,
          );
          // Substrings of other codes or numbers no longer change guidance.
          await attempt(
            http.Response('{"error":"invalid_body","ref":"4090"}', 400),
            t.bookingSubmitFailed,
          );
          await attempt(
            http.Response('{"error":"sin_permiso_disponibilidad"}', 400),
            t.bookingSubmitFailed,
          );
          await attempt(
            http.Response('<html>disponibilidad</html>', 502),
            t.bookingSubmitFailed,
          );
          await attempt(http.Response('{}', 409), t.bookingSlotTaken);
          expect(find.textContaining('colision'), findsNothing);
          expect(fixture.submissions, 7);
          fixture.submit = http.Response('{"id":"session-1"}', 201);
          await tapVisible(slot);
          await tester.ensureVisible(find.text(t.bookingSubmit));
          await tester.tap(find.text(t.bookingSubmit));
          await tester.pump();
          expect(find.text(t.bookingSent), findsOneWidget);
          await tester.pumpAndSettle();
          expect(find.text('bookings'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
