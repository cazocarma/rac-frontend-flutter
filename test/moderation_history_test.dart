import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/chat/data/chat_api.dart';
import 'package:rentacompa/features/chat/ui/moderation_screen.dart';

Map<String, dynamic> report(
  String state, {
  String id = '10000000-0000-0000-0000-000000000001',
}) => {
  'id': id,
  'sesion_id': '20000000-0000-0000-0000-000000000001',
  'motivo': 'spam',
  'estado': state,
  'creado_en': '2026-10-21T12:00:00Z',
  'resuelto_en': state == 'abierto' ? null : '2026-10-21T13:00:00Z',
};

class HistoryApi extends ChatApi {
  HistoryApi() : super('http://test.invalid');
  final requests = <Uri>[];
  Future<Map<String, dynamic>> Function(Uri)? respond;
  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    final uri = Uri.parse(path);
    requests.add(uri);
    if (respond != null) return respond!(uri);
    return {
      'items': [report(uri.queryParameters['estado']!)],
      'has_more': false,
      'next_cursor': '',
    };
  }
}

void main() {
  testWidgets('closed history exposes metadata without accessing evidence', (
    tester,
  ) async {
    final api = HistoryApi();
    await tester.pumpWidget(MaterialApp(home: ModerationScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Atendidos'));
    await tester.pumpAndSettle();
    expect(find.text('Historial de reportes'), findsOneWidget);
    expect(find.text('Reporte atendido'), findsOneWidget);
    expect(find.textContaining('Cierre:'), findsOneWidget);
    expect(find.textContaining('21/10/2026'), findsNWidgets(2));
    expect(tester.widget<ListTile>(find.byType(ListTile)).onTap, isNull);
    expect(api.requests.any((u) => u.path.endsWith('/access')), isFalse);
  });
  testWidgets(
    'cursor pagination returns to prior page and resets on filter change',
    (tester) async {
      final api = HistoryApi()
        ..respond = (uri) async => {
          'items': [report(uri.queryParameters['estado']!)],
          'has_more': !uri.queryParameters.containsKey('despues'),
          'next_cursor': 'opaque-cursor',
        };
      await tester.pumpWidget(MaterialApp(home: ModerationScreen(api: api)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Siguientes'));
      await tester.tap(find.text('Siguientes'));
      await tester.pumpAndSettle();
      expect(api.requests.last.queryParameters['despues'], 'opaque-cursor');
      expect(find.text('Página 2'), findsOneWidget);
      await tester.tap(find.text('Anteriores'));
      await tester.pumpAndSettle();
      expect(api.requests.last.queryParameters.containsKey('despues'), isFalse);
      await tester.ensureVisible(find.text('Siguientes'));
      await tester.tap(find.text('Siguientes'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Todos'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Todos'));
      await tester.pumpAndSettle();
      expect(api.requests.last.queryParameters, {'estado': 'todos'});
      expect(find.text('Página 1'), findsOneWidget);
    },
  );
  testWidgets(
    'late response from prior filter cannot replace current results',
    (tester) async {
      final old = Completer<Map<String, dynamic>>();
      final current = Completer<Map<String, dynamic>>();
      final api = HistoryApi()
        ..respond = (uri) async {
          switch (uri.queryParameters['estado']) {
            case 'atendido':
              return old.future;
            case 'desestimado':
              return current.future;
            default:
              return {
                'items': <dynamic>[],
                'has_more': false,
                'next_cursor': '',
              };
          }
        };
      await tester.pumpWidget(MaterialApp(home: ModerationScreen(api: api)));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Atendidos'));
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Desestimados'));
      await tester.pump();
      current.complete({
        'items': [report('desestimado')],
        'has_more': false,
        'next_cursor': '',
      });
      await tester.pumpAndSettle();
      old.complete({
        'items': [report('atendido')],
        'has_more': false,
        'next_cursor': '',
      });
      await tester.pumpAndSettle();
      expect(find.text('Reporte desestimado'), findsOneWidget);
      expect(find.text('Reporte atendido'), findsNothing);
    },
  );
  testWidgets('history filters fit a narrow mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: ModerationScreen(api: HistoryApi())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Desestimados'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
