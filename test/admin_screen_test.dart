import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/admin/ui/admin_screen.dart';
import 'package:rentacompa/shared/services/json_api.dart';

class AdminApi extends JsonApi {
  AdminApi() : super('http://test.invalid', apiPath: '/api/admin');
  int calls = 0;
  int? status;
  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    calls++;
    if (status != null) {
      throw ApiException(status!, 'fixture');
    }
    return {
      'usuarios': {'total': 12, 'compas': 4},
      'reservas': {
        'pendiente': 3,
        'activa': 2,
        'finalizada': 1,
        'cancelada': 0,
        'expirada': 0,
      },
      'reportes': {'abierto': 1, 'atendido': 2, 'desestimado': 0},
      'consultado_en': '2026-10-21T12:00:00Z',
    };
  }
}

void main() {
  testWidgets('shows real counts and adapts to narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = AdminApi();
    await tester.pumpWidget(MaterialApp(home: AdminScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Usuarios con perfil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('failure hides prior counts and can retry', (tester) async {
    final api = AdminApi();
    await tester.pumpWidget(MaterialApp(home: AdminScreen(api: api)));
    await tester.pumpAndSettle();
    api.status = 503;
    await tester.tap(find.byTooltip('Actualizar resumen'));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsNothing);
    expect(find.text('No pudimos cargar el resumen'), findsOneWidget);
    api.status = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsOneWidget);
  });
  testWidgets('forbidden shows access message without retry', (tester) async {
    final api = AdminApi()..status = 403;
    await tester.pumpWidget(MaterialApp(home: AdminScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Acceso reservado a administradores'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });
}
