import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/documents/ui/document_prompt_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/documents/data/documents_api.dart';
import 'package:rentacompa/features/documents/ui/document_prompt.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/pending_documents.dart';
import 'package:rentacompa/shared/services/json_api.dart';

const id = '12345678-1234-4234-8234-123456789abc';
final hash = 'a' * 64;
final pending = DocumentPrecondition.parse(428, {
  'error': 'DOCUMENT_ACCEPTANCE_REQUIRED',
  'documents': [
    {
      'id': id,
      'kind': 'privacy',
      'sha256': hash,
      'material_version': 'abcdef12-1234-4234-8234-123456789abc',
    },
  ],
})!;

class PromptApi extends DocumentsApi {
  PromptApi() : super('https://fixture.invalid');
  int accepted = 0;
  bool conflict = false, changed = false;
  final registry = const DocumentRegistry(
    locale: 'es',
    version: 3,
    policyVersion: 'abcdef12-1234-4234-8234-123456789abc',
    summary: ['Cambio sintético revisado'],
  );
  LegalDocument item({bool detail = false}) => LegalDocument(
    id: id,
    kind: 'privacy',
    version: 'synthetic-1',
    sha256: changed && detail ? 'b' * 64 : hash,
    content: detail ? 'Texto sintético, no documento legal aprobado.' : null,
    registry: registry,
  );
  @override
  Future<DocumentCollection> collection() async =>
      DocumentCollection(items: [item()], registry: registry);
  @override
  Future<LegalDocument> document(String id) async => item(detail: true);
  @override
  Future<void> acceptBatch(
    List<LegalDocument> documents,
    DocumentRegistry registry,
  ) async {
    if (conflict) throw const ApiException(409, 'document_registry_changed');
    expect(documents.single.id, id);
    expect(documents.single.sha256, hash);
    expect(registry.version, 3);
    accepted++;
  }
}

Widget app(PromptApi api) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<bool>(
            builder: (_) => DocumentPrompt(pending: pending, api: api),
          ),
        ),
        child: const Text('Abrir'),
      ),
    ),
  ),
);
Future<void> open(WidgetTester tester, PromptApi api) async {
  await tester.pumpWidget(app(api));
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

Future<void> read(WidgetTester tester) async {
  await tester.tap(find.text('Privacidad'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('He leído esta versión'));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'batch acceptance binds exact documents and registry in one request',
    () async {
      var calls = 0;
      final fixture = PromptApi();
      final api = DocumentsApi(
        'https://fixture.invalid',
        token: () async => 'fixture',
        client: MockClient((request) async {
          calls++;
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map;
          expect(body['registry'], fixture.registry.reference);
          expect(body['documents'], [
            {'id': id, 'sha256': hash},
          ]);
          return http.Response('{}', 200);
        }),
      );
      await api.acceptBatch([fixture.item()], fixture.registry);
      expect(calls, 1);
      api.close();
    },
  );
  testWidgets(
    'concurrent prerequisites open one screen and unsubscribe on dispose',
    (tester) async {
      final events = StreamController<DocumentPrecondition>.broadcast();
      final key = GlobalKey<NavigatorState>();
      var created = 0;
      await tester.pumpWidget(
        DocumentPromptHost(
          navigatorKey: key,
          events: events.stream,
          createApi: () {
            created++;
            return PromptApi();
          },
          child: MaterialApp(
            navigatorKey: key,
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Original')),
          ),
        ),
      );
      events.add(pending);
      events.add(pending);
      await tester.pumpAndSettle();
      expect(created, 1);
      expect(find.byType(DocumentPrompt), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(events.hasListener, false);
      await events.close();
    },
  );
  testWidgets('a different exact hash cannot unlock consent', (tester) async {
    final api = PromptApi()..changed = true;
    await open(tester, api);
    await tester.tap(find.text('Privacidad'));
    await tester.pumpAndSettle();
    expect(
      find.text('No pudimos abrir esta versión exacta. Inténtalo nuevamente.'),
      findsOneWidget,
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    expect(api.accepted, 0);
  });

  for (final width in [360.0, 1200.0]) {
    testWidgets('explicit exact consent at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = PromptApi();
      await open(tester, api);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Aceptar y continuar'),
            )
            .onPressed,
        isNull,
      );
      await read(tester);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.ensureVisible(find.text('Aceptar y continuar'));
      await tester.tap(find.text('Aceptar y continuar'));
      await tester.pumpAndSettle();
      expect(api.accepted, 1);
      expect(find.text('Abrir'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('409 clears consent and prevents stale retry', (tester) async {
    final api = PromptApi()..conflict = true;
    await open(tester, api);
    await read(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Aceptar y continuar'));
    await tester.pumpAndSettle();
    expect(api.accepted, 0);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      false,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Aceptar y continuar'),
          )
          .onPressed,
      isNull,
    );
  });
  testWidgets('rights escape works with unchecked consent', (tester) async {
    final api = PromptApi();
    await open(tester, api);
    await tester.ensureVisible(find.text('Ver mis datos o eliminar mi cuenta'));
    await tester.tap(find.text('Ver mis datos o eliminar mi cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Tus datos y derechos'), findsOneWidget);
    expect(
      find.textContaining('No hemos enviado ninguna solicitud'),
      findsOneWidget,
    );
    expect(api.accepted, 0);
  });
}
