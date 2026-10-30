import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/alerts/data/alert_api.dart';
import 'package:rentacompa/features/alerts/ui/notifications_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

class LocalizedInbox extends AlertApi {
  LocalizedInbox() : super('http://fixture.invalid');
  bool unavailable = true;
  bool unread = true;
  bool rejectRead = true;
  final offsets = <int>[];
  final locales = <String>[];
  @override
  Future<Map<String, dynamic>> notifications({
    int offset = 0,
    String locale = 'es',
  }) async {
    offsets.add(offset);
    locales.add(locale);
    if (unavailable) throw StateError('fixture unavailable');
    return {
      'items': [
        {
          'id': 'notice-1',
          'sesion_id': '12345678-booking',
          'tipo': 'reserva',
          'titulo': 'Texto histórico recibido del servidor',
          'creado_en': '2026-10-23T12:00:00Z',
          'leido_en': unread ? null : '2026-10-23T13:00:00Z',
        },
      ],
      'has_more': offset == 0,
      'no_leidas': unread ? 1 : 0,
    };
  }

  @override
  Future<void> readNotification(String id) async {
    if (rejectRead) throw StateError('fixture unavailable');
    unread = false;
  }
}

void main() {
  test('inbox requests titles in the given locale', () async {
    final seen = <Uri>[];
    final api = AlertApi(
      'https://api.example',
      token: () async => 'fixture-token',
      client: MockClient((request) async {
        seen.add(request.url);
        return http.Response(
          '{"items":[],"has_more":false,"no_leidas":0}',
          200,
        );
      }),
    );
    await api.notifications(offset: 20, locale: 'en');
    await api.notifications();
    expect(seen.map((u) => u.queryParameters).toList(), [
      {'limit': '20', 'offset': '20', 'locale': 'en'},
      {'limit': '20', 'offset': '0', 'locale': 'es'},
    ]);
    api.close();
  });
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('inbox $locale $width retries, preserves history and pages', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = LocalizedInbox();
        addTearDown(api.close);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: NotificationsScreen(api: api),
            routes: {
              '/match': (_) =>
                  const Scaffold(body: Text('booking destination')),
            },
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(NotificationsScreen)),
        )!;
        expect(find.text(t.notificationsLoadFailed), findsOneWidget);
        api.unavailable = false;
        await tester.tap(find.text(t.notificationsRetry));
        await tester.pumpAndSettle();
        expect(
          find.text('Texto histórico recibido del servidor'),
          findsOneWidget,
        );
        expect(find.text(t.notificationsUnread(1)), findsOneWidget);
        expect(
          find.textContaining(t.notificationsBookingReference('12345678')),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text(t.notificationsMarkRead));
        await tester.tap(find.text(t.notificationsMarkRead));
        await tester.pumpAndSettle();
        expect(find.text(t.notificationsUpdateFailed), findsOneWidget);
        expect(api.unread, isTrue);
        ScaffoldMessenger.of(
          tester.element(find.byType(NotificationsScreen)),
        ).removeCurrentSnackBar();
        await tester.pumpAndSettle();
        api.rejectRead = false;
        await tester.tap(find.text(t.notificationsMarkRead));
        await tester.pumpAndSettle();
        expect(find.text(t.notificationsUnread(0)), findsOneWidget);
        expect(find.text(t.notificationsMarkRead), findsNothing);
        await tester.ensureVisible(find.text(t.notificationsOlder));
        await tester.tap(find.text(t.notificationsOlder));
        await tester.pumpAndSettle();
        expect(api.offsets.last, 20);
        await tester.ensureVisible(find.text(t.notificationsNewer));
        await tester.tap(find.text(t.notificationsNewer));
        await tester.pumpAndSettle();
        expect(api.offsets.last, 0);
        expect(api.locales.toSet(), {locale});
        await tester.ensureVisible(find.text(t.notificationsViewBookings));
        await tester.tap(find.text(t.notificationsViewBookings));
        await tester.pumpAndSettle();
        expect(find.text('booking destination'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
