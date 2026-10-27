import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/documents/data/documents_api.dart';
import 'package:rentacompa/features/documents/ui/documents_screen.dart';
import 'package:rentacompa/shared/services/json_api.dart';

class FakeDocuments extends DocumentsApi {
  FakeDocuments() : super('https://fixture.invalid');
  bool empty = false, accepted = false, conflict = false, changed = false;
  int calls = 0;
  final String hash = 'a' * 64;
  LegalDocument item({bool detail = false}) => LegalDocument(
    id: '11111111-1111-4111-8111-111111111111',
    kind: 'terms_client',
    version: 'fixture-1',
    sha256: changed && detail ? 'b' * 64 : hash,
    acceptedAt: accepted ? DateTime.utc(2026, 10, 26) : null,
    content: detail
        ? 'Documento sintético para pruebas. No son términos definitivos.'
        : null,
  );
  @override
  Future<List<LegalDocument>> documents() async => empty ? [] : [item()];
  @override
  Future<LegalDocument> document(String id) async => item(detail: true);
  @override
  Future<void> accept(
    LegalDocument document, {
    DocumentRegistry? registry,
  }) async {
    calls++;
    if (conflict) throw const ApiException(409, 'document_version_unavailable');
    expect(document.id, item().id);
    expect(document.sha256, hash);
    accepted = true;
  }
}

void main() {
  test(
    'active metadata carries the registry reference without summary or approval claims',
    () async {
      Map<String, dynamic>? accepted;
      final ref = {
        'locale': 'es',
        'version': 7,
        'policy_version': '22222222-2222-4222-8222-222222222222',
      };
      final sample = FakeDocuments();
      final api = DocumentsApi(
        'https://fixture.invalid',
        token: () async => 'fixture',
        refresh: () async {},
        client: MockClient((request) async {
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'registry': {
                  ...ref,
                  'summary': ['Resumen sintético revisado'],
                },
                'items': [
                  {
                    'id': sample.item().id,
                    'kind': 'terms_client',
                    'version': 'fixture-1',
                    'sha256': sample.hash,
                  },
                ],
              }),
              200,
            );
          }
          accepted = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"accepted":1}', 200);
        }),
      );
      addTearDown(api.close);
      addTearDown(sample.close);
      final items = await api.documents();
      expect(items.single.registry!.version, 7);
      await api.accept(items.single);
      expect(accepted!['registry'], ref);
      expect((accepted!['registry'] as Map).containsKey('summary'), isFalse);
    },
  );
  test(
    'invalid registry metadata is unavailable rather than an empty acceptance target',
    () {
      for (final value in [
        {'locale': 'es', 'version': 0, 'policy_version': 'bad', 'summary': []},
        {
          'locale': 'es',
          'version': 1,
          'policy_version': '22222222-2222-4222-8222-222222222222',
          'summary': ['1', '2', '3', '4'],
        },
      ]) {
        expect(() => DocumentRegistry.fromJson(value), throwsFormatException);
      }
    },
  );

  test('acceptance sends exact version hash and account context', () async {
    late Map<String, dynamic> body;
    final api = DocumentsApi(
      'https://fixture.invalid',
      token: () async => 'fixture',
      refresh: () async {},
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/user/me/documents/acceptances');
        body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('{"accepted":1}', 200);
      }),
    );
    addTearDown(api.close);
    final sample = FakeDocuments();
    addTearDown(sample.close);
    await api.accept(sample.item());
    expect(body, {
      'context': 'account',
      'documents': [
        {'id': sample.item().id, 'sha256': sample.hash},
      ],
    });
  });

  for (final width in [360.0, 1200.0]) {
    testWidgets(
      'explicit unchecked consent and successful persistence at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = FakeDocuments();
        addTearDown(api.close);
        await tester.pumpWidget(MaterialApp(home: DocumentsScreen(api: api)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Términos para clientes'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isFalse,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Confirmar aceptación'),
              )
              .onPressed,
          isNull,
        );
        expect(api.calls, 0);
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();
        await tester.ensureVisible(find.text('Confirmar aceptación'));
        await tester.tap(find.text('Confirmar aceptación'));
        await tester.pumpAndSettle();
        expect(api.calls, 1);
        expect(find.text('Versión fixture-1 · Aceptada'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('no fake consent when reviewed documents are unavailable', (
    tester,
  ) async {
    final api = FakeDocuments()..empty = true;
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: DocumentsScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('En construcción'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(api.calls, 0);
  });
  testWidgets('version conflict clears consent and prevents stale retry', (
    tester,
  ) async {
    final api = FakeDocuments()..conflict = true;
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: DocumentsScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Términos para clientes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Confirmar aceptación'));
    await tester.pumpAndSettle();
    expect(api.calls, 1);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirmar aceptación'),
          )
          .onPressed,
      isNull,
    );
    expect(find.textContaining('Los documentos cambiaron'), findsOneWidget);
  });
  testWidgets('changed content hash cannot be accepted from old metadata', (
    tester,
  ) async {
    final api = FakeDocuments()..changed = true;
    addTearDown(api.close);
    await tester.pumpWidget(MaterialApp(home: DocumentsScreen(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Términos para clientes'));
    await tester.pumpAndSettle();
    expect(find.text('No pudimos abrir esta versión'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(api.calls, 0);
  });
}
