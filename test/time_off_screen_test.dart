import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/match/ui/time_off_screen.dart';
import 'package:rentacompa/shared/services/json_api.dart';

class ScheduleApi extends JsonApi {
  ScheduleApi() : super('http://test.invalid', apiPath: '/api/match');
  bool fail = false;
  bool removed = false;
  String? lastMethod;
  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    if (method == 'DELETE') {
      lastMethod = method;
      if (fail) {
        throw const ApiException(503, 'fixture');
      }
      removed = true;
      return {'removed': true};
    }
    return {
      'items': removed
          ? []
          : [
              {
                'id': 'block',
                'desde': '2026-12-01',
                'hasta': '2026-12-02',
                'zona_horaria': 'America/Santiago',
              },
            ],
      'zona_horaria': 'America/Santiago',
      'fecha_min': '2026-10-21',
      'fecha_max': '2028-10-20',
    };
  }
}

void main() {
  testWidgets('narrow agenda shows zone and requires confirmed removal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ScheduleApi();
    await tester.pumpWidget(
      MaterialApp(
        home: TimeOffScreen(api: api, compaId: 'me'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2026-12-01 → 2026-12-02'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Quitar bloqueo'));
    await tester.pumpAndSettle();
    expect(api.removed, isFalse);
    await tester.tap(find.text('Conservar'));
    await tester.pumpAndSettle();
    expect(api.removed, isFalse);
    await tester.tap(find.byTooltip('Quitar bloqueo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitar bloqueo'));
    await tester.pumpAndSettle();
    expect(api.lastMethod, 'DELETE');
    expect(find.text('2026-12-01 → 2026-12-02'), findsNothing);
  });
  testWidgets('failed removal retains block and reports failure', (
    tester,
  ) async {
    final api = ScheduleApi()..fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: TimeOffScreen(api: api, compaId: 'me'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Quitar bloqueo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitar bloqueo'));
    await tester.pumpAndSettle();
    expect(api.removed, isFalse);
    expect(find.text('2026-12-01 → 2026-12-02'), findsOneWidget);
    expect(find.textContaining('No pudimos guardar'), findsOneWidget);
  });
}
