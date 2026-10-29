import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/alerts/data/alert_api.dart';
import 'package:rentacompa/features/alerts/ui/notifications_screen.dart';

class FakeInbox extends AlertApi {
  FakeInbox() : super('http://fixture.invalid');
  bool failed = false;
  int unread = 3;
  @override
  Future<Map<String, dynamic>> notifications({int offset = 0}) async => {
    'items': [],
    'has_more': false,
    'no_leidas': unread,
  };
  @override
  Future<void> readAll() async {
    if (failed) throw StateError('unavailable');
    unread = 0;
  }
}

class AccountInbox extends AlertApi {
  AccountInbox() : super('http://fixture.invalid');
  bool read = false;
  @override
  Future<Map<String, dynamic>> notifications({int offset = 0}) async => {
    'items': [
      {
        'id': 'notice-1',
        'sesion_id': null,
        'tipo': 'estado_cuenta',
        'titulo': 'Actualización de tu cuenta',
        'creado_en': '2026-10-23T12:00:00Z',
        'leido_en': read ? '2026-10-23T13:00:00Z' : null,
      },
    ],
    'has_more': false,
    'no_leidas': read ? 0 : 1,
  };
  @override
  Future<void> readNotification(String id) async {
    read = true;
  }
}

void main() {
  test('alert API refreshes once and preserves the idempotent PUT', () async {
    var refreshed = false;
    final requests = <http.Request>[];
    final api = AlertApi(
      'https://rac.test',
      token: () async => refreshed ? 'new' : 'old',
      refresh: () async {
        refreshed = true;
      },
      client: MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode(
            refreshed ? {'actualizadas': 3} : {'error': 'invalid_token'},
          ),
          refreshed ? 200 : 401,
        );
      }),
    );
    await api.readAll();
    expect(requests.length, 2);
    expect(
      requests.every(
        (r) =>
            r.method == 'PUT' &&
            r.url.path == '/api/alert/notifications/read-all',
      ),
      true,
    );
    expect(requests.last.headers['Authorization'], 'Bearer new');
    api.close();
  });
  testWidgets(
    'global unread counter survives failures and updates after mark all',
    (tester) async {
      final api = FakeInbox()..failed = true;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 sin leer en tu bandeja'), findsOneWidget);
      await tester.tap(find.text('Marcar todas como leídas'));
      await tester.pumpAndSettle();
      expect(find.text('3 sin leer en tu bandeja'), findsOneWidget);
      expect(
        find.textContaining('No pudimos marcar tus avisos'),
        findsOneWidget,
      );
      api.failed = false;
      await tester.tap(find.text('Marcar todas como leídas'));
      await tester.pumpAndSettle();
      expect(find.text('0 sin leer en tu bandeja'), findsOneWidget);
      expect(find.text('Marcar todas como leídas'), findsNothing);
    },
  );
  for (final width in [360.0, 1200.0]) {
    testWidgets('account notice has no fabricated booking at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = AccountInbox();
      addTearDown(api.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationsScreen(api: api),
          routes: {
            '/profile': (_) => const Scaffold(body: Text('Perfil de destino')),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Actualización de tu cuenta'), findsOneWidget);
      expect(find.text('Ver estado de mi cuenta'), findsOneWidget);
      expect(find.text('Ver mis reservas'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Marcar como leída'));
      await tester.pumpAndSettle();
      expect(api.read, isTrue);
      expect(find.text('0 sin leer en tu bandeja'), findsOneWidget);
      await tester.tap(find.text('Ver estado de mi cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Perfil de destino'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
