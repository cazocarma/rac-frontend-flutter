import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/chat/data/chat_api.dart';
import 'package:rentacompa/features/chat/ui/chat_safety_screen.dart';
import 'package:rentacompa/features/chat/ui/moderation_screen.dart';

class SafetyApi extends ChatApi {
  SafetyApi() : super('http://fixture.invalid');
  bool blocked = false, reported = false;
  int reads = 0;
  String? saved;
  @override
  Future<Map<String, dynamic>> safety(String id) async => {
    'bloqueada': blocked,
    'bloqueada_por_mi': blocked,
    'reportada': reported,
  };
  @override
  Future<Map<String, dynamic>> block(String id, bool value) async {
    blocked = value;
    return {};
  }

  @override
  Future<Map<String, dynamic>> report(
    String id,
    String reason,
    String detail,
  ) async {
    reported = true;
    saved = detail;
    return {'id': 'report'};
  }

  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
  }) async {
    reads++;
    return {
      'motivo': 'acoso',
      'detalle': 'Descripción privada del reporte',
      'items': [],
      'has_more': false,
      'before': '',
    };
  }
}

void main() {
  testWidgets('blocking requires confirmation and only removes own block', (
    tester,
  ) async {
    final api = SafetyApi();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatSafetyScreen(bookingId: 'booking', api: api),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear conversación'));
    await tester.pumpAndSettle();
    expect(api.blocked, false);
    await tester.tap(find.text('Confirmar bloqueo'));
    await tester.pumpAndSettle();
    expect(api.blocked, true);
    expect(find.text('Retirar mi bloqueo'), findsOneWidget);
    await tester.tap(find.text('Retirar mi bloqueo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retirar bloqueo'));
    await tester.pumpAndSettle();
    expect(api.blocked, false);
  });
  testWidgets('report validates detail and replaces form after confirmation', (
    tester,
  ) async {
    final api = SafetyApi();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatSafetyScreen(bookingId: 'booking', api: api),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.text('Enviar reporte');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(api.reported, false);
    expect(
      find.text('Cuéntanos lo ocurrido en al menos 10 caracteres.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byType(TextFormField),
      'Descripción sintética del incidente',
    );
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(api.saved, 'Descripción sintética del incidente');
    expect(find.text('Enviar reporte'), findsNothing);
    expect(find.textContaining('Reporte recibido'), findsOneWidget);
  });
  testWidgets(
    'moderation does not fetch evidence before explicit justified access',
    (tester) async {
      final api = SafetyApi();
      await tester.pumpWidget(
        MaterialApp(
          home: ModerationCaseScreen(
            id: 'c817cc70-1020-4ef7-9311-130000000003',
            api: api,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.reads, 0);
      expect(find.text('Descripción privada del reporte'), findsNothing);
      await tester.ensureVisible(find.text('Consultar y registrar acceso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Consultar y registrar acceso'));
      await tester.pumpAndSettle();
      expect(api.reads, 0);
      await tester.enterText(
        find.byType(TextFormField),
        'Revisar el incidente denunciado',
      );
      await tester.ensureVisible(find.text('Consultar y registrar acceso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Consultar y registrar acceso'));
      await tester.pumpAndSettle();
      expect(api.reads, 1);
      expect(find.text('Descripción privada del reporte'), findsOneWidget);
    },
  );
}
