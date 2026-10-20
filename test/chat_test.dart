import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/chat/data/chat_api.dart';
import 'package:rentacompa/features/chat/ui/chat_screen.dart';

const booking = 'c817cc70-1020-4ef7-9311-130000000003';
Map<String, dynamic> message(
  String id,
  String value, {
  bool own = false,
  String key = '',
}) => {
  'id': id,
  'numero': id,
  'contenido': value,
  'propio': own,
  'enviado_en': '2026-10-20T12:00:00Z',
  'envio_id': key,
};

class FakeChat extends ChatApi {
  FakeChat({this.writable = true}) : super('http://fixture.test');
  final bool writable;
  final keys = <String>[];
  final cursors = <String>[];
  bool failFirstSend = true;
  Completer<Map<String, dynamic>>? pending;
  @override
  Future<Map<String, dynamic>> history(String id, {String? before}) async => {
    'items': [message('1', 'Hola desde el compa')],
    'event_cursor': '1',
    'before': '',
    'has_more': false,
    'can_send': writable,
  };
  @override
  Future<Map<String, dynamic>> events(String id, String cursor) {
    cursors.add(cursor);
    pending = Completer<Map<String, dynamic>>();
    return pending!.future;
  }

  @override
  Future<Map<String, dynamic>> send(String id, String key, String text) async {
    keys.add(key);
    if (failFirstSend && keys.length == 1) {
      throw const ChatException(503, 'chat_unavailable');
    }
    return message('2', text, own: true, key: key);
  }
}

void main() {
  test(
    'expired token refreshes once and retries with the same payload',
    () async {
      int refreshes = 0;
      final calls = <http.Request>[];
      final api = ChatApi(
        'https://rac.test',
        token: () async => refreshes == 0 ? 'old' : 'new',
        refresh: () async {
          refreshes++;
        },
        client: MockClient((request) async {
          calls.add(request);
          return http.Response(
            jsonEncode(
              calls.length == 1 ? {'error': 'invalid_token'} : {'id': '2'},
            ),
            calls.length == 1 ? 401 : 201,
          );
        }),
      );
      final key = ChatApi.newRequestId();
      await api.send(booking, key, 'Reintento seguro');
      expect(refreshes, 1);
      expect(calls[0].body, calls[1].body);
      expect(calls[1].headers['Authorization'], 'Bearer new');
      api.close();
    },
  );
  test('API keeps tokens in headers and preserves the retry key', () async {
    final seen = <http.Request>[];
    final api = ChatApi(
      'https://rac.test',
      token: () async => 'test-token',
      client: MockClient((request) async {
        seen.add(request);
        return http.Response(jsonEncode({'id': '2'}), 201);
      }),
    );
    final key = ChatApi.newRequestId();
    expect(
      key,
      matches(
        RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ),
      ),
    );
    await api.send(booking, key, 'Hola');
    await api.send(booking, key, 'Hola');
    expect(seen.map((r) => r.headers['Authorization']).toList(), [
      'Bearer test-token',
      'Bearer test-token',
    ]);
    expect(seen.every((r) => !r.url.toString().contains('test-token')), isTrue);
    expect(
      jsonDecode(seen[0].body)['envio_id'],
      jsonDecode(seen[1].body)['envio_id'],
    );
    api.close();
  });
  testWidgets('uncertain send retains draft and retries the same UUID', (
    tester,
  ) async {
    final api = FakeChat();
    await tester.pumpWidget(
      MaterialApp(
        home: ChatConversationScreen(bookingId: booking, apiFactory: () => api),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nos vemos pronto');
    await tester.tap(find.byTooltip('Enviar mensaje'));
    await tester.pumpAndSettle();
    expect(find.text('Nos vemos pronto'), findsOneWidget);
    await tester.tap(find.byTooltip('Reintentar envío'));
    await tester.pumpAndSettle();
    expect(api.keys.length, 2);
    expect(api.keys[0], api.keys[1]);
    expect(find.text('Nos vemos pronto'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'replayed events merge once and advance cursor after processing',
    (tester) async {
      final api = FakeChat();
      await tester.pumpWidget(
        MaterialApp(
          home: ChatConversationScreen(
            bookingId: booking,
            apiFactory: () => api,
          ),
        ),
      );
      await tester.pumpAndSettle();
      api.pending!.complete({
        'items': [
          {'mensaje': message('1', 'Hola desde el compa')},
          {'mensaje': message('2', 'Nuevo mensaje')},
        ],
        'cursor': '2',
        'has_more': false,
        'can_send': true,
      });
      await tester.pumpAndSettle();
      expect(find.text('Hola desde el compa'), findsOneWidget);
      expect(find.text('Nuevo mensaje'), findsOneWidget);
      expect(api.cursors, ['1', '2']);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('closed booking shows history without composer or polling', (
    tester,
  ) async {
    final api = FakeChat(writable: false);
    await tester.pumpWidget(
      MaterialApp(
        home: ChatConversationScreen(bookingId: booking, apiFactory: () => api),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hola desde el compa'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(api.cursors, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
