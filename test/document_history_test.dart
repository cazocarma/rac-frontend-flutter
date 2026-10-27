import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/documents/data/documents_api.dart';
import 'package:rentacompa/features/documents/ui/document_history_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

class HistoryApi extends DocumentsApi {
  HistoryApi() : super('https://fixture.invalid');
  final calls = <String?>[];
  bool empty = false, failNext = false;
  LegalDocument item(String id, {bool detail = false}) => LegalDocument(
    id: id,
    kind: 'privacy',
    version: 'historical-$id',
    sha256: 'a' * 64,
    acceptedAt: DateTime.utc(2026, 10, 25, 12),
    content: detail
        ? 'Texto histórico sintético, no términos definitivos.'
        : null,
  );
  @override
  Future<DocumentHistoryPage> history({String? cursor}) async {
    calls.add(cursor);
    if (failNext) {
      failNext = false;
      throw StateError('Synthetic failure');
    }
    if (empty) return const DocumentHistoryPage([], null);
    return DocumentHistoryPage([
      DocumentAcceptance(item(cursor == null ? 'one' : 'two'), 'account'),
    ], cursor == null ? 'next' : null);
  }

  @override
  Future<LegalDocument> document(String id) async => item(id, detail: true);
  @override
  Future<void> accept(
    LegalDocument document, {
    DocumentRegistry? registry,
  }) async => fail('History must not accept documents');
}

Widget app(HistoryApi api) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: DocumentHistoryScreen(api: api),
);
void main() {
  test(
    'history API is bounded, preserves cursor and rejects unsigned acceptance metadata',
    () async {
      final api = DocumentsApi(
        'https://fixture.invalid',
        token: () async => 'fixture',
        client: MockClient((request) async {
          expect(request.url.queryParameters, {
            'limit': '20',
            'cursor': 'fixture cursor',
          });
          return http.Response(
            jsonEncode({
              'items': [
                {
                  'id': 'old',
                  'kind': 'privacy',
                  'version': 'old-1',
                  'sha256': 'a' * 64,
                  'context': 'account',
                },
              ],
              'next_cursor': null,
            }),
            200,
          );
        }),
      );
      await expectLater(
        api.history(cursor: 'fixture cursor'),
        throwsFormatException,
      );
      api.close();
    },
  );
  for (final width in [360.0, 1200.0]) {
    testWidgets('historical reader is read-only at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = HistoryApi();
      await tester.pumpWidget(app(api));
      await tester.pumpAndSettle();
      expect(find.text('Privacidad · historical-one'), findsOneWidget);
      await tester.tap(find.text('Privacidad · historical-one'));
      await tester.pumpAndSettle();
      expect(
        find.text('Texto histórico sintético, no términos definitivos.'),
        findsOneWidget,
      );
      expect(find.text('Ya aceptaste esta versión.'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'failed next page preserves prior history and retries the same cursor',
    (tester) async {
      final api = HistoryApi();
      await tester.pumpWidget(app(api));
      await tester.pumpAndSettle();
      api.failNext = true;
      await tester.tap(find.text('Cargar más'));
      await tester.pumpAndSettle();
      expect(find.text('Privacidad · historical-one'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(api.calls, [null, 'next', 'next']);
      expect(find.text('Privacidad · historical-one'), findsOneWidget);
      expect(find.text('Privacidad · historical-two'), findsOneWidget);
      expect(find.text('Cargar más'), findsNothing);
    },
  );
  testWidgets('empty own history is explicit', (tester) async {
    await tester.pumpWidget(app(HistoryApi()..empty = true));
    await tester.pumpAndSettle();
    expect(find.text('Aún no has registrado aceptaciones.'), findsOneWidget);
  });
}
