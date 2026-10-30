import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/chat/data/chat_api.dart';
import 'package:rentacompa/features/chat/ui/chat_safety_screen.dart';
import 'package:rentacompa/features/chat/ui/chat_screen.dart';
import 'package:rentacompa/features/chat/ui/moderation_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/auth_session.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'auth_test.dart' show FakeSession;

const booking = 'c817cc70-1020-4ef7-9311-130000000003';

/// One fake for list, conversation, safety and moderation screens.
class LocalizedChat extends ChatApi {
  LocalizedChat() : super('http://fixture.invalid');
  ChatException? listFailure, historyFailure, safetyFailure, moderationFailure;
  bool writable = true;
  final sendFailures = <ChatException>[];
  final sent = <String>[];
  List<Map<String, dynamic>> conversationItems = [
    {
      'nombre': 'Ana',
      'estado': 'activa',
      'sesion_id': booking,
      'ultimo_mensaje': '',
    },
    {
      'nombre': 'Luis',
      'estado': 'finalizada',
      'sesion_id': booking,
      'ultimo_mensaje': 'Hasta pronto',
    },
  ];
  @override
  Future<Map<String, dynamic>> conversations({int offset = 0}) async {
    if (listFailure != null) throw listFailure!;
    return {'items': conversationItems, 'has_more': offset == 0};
  }

  @override
  Future<Map<String, dynamic>> history(String id, {String? before}) async {
    if (historyFailure != null) throw historyFailure!;
    return {
      'items': <dynamic>[],
      'event_cursor': '1',
      'before': '',
      'has_more': false,
      'can_send': writable,
    };
  }

  @override
  Future<Map<String, dynamic>> events(String id, String cursor) =>
      Completer<Map<String, dynamic>>().future;

  @override
  Future<Map<String, dynamic>> send(String id, String key, String text) async {
    sent.add(text);
    if (sendFailures.isNotEmpty) throw sendFailures.removeAt(0);
    return {
      'id': '2',
      'numero': '2',
      'contenido': text,
      'propio': true,
      'enviado_en': '2026-10-20T12:00:00Z',
      'envio_id': key,
    };
  }

  @override
  Future<Map<String, dynamic>> safety(String id) async {
    if (safetyFailure != null) throw safetyFailure!;
    return {
      'bloqueada': true,
      'bloqueada_por_mi': false,
      'reportada': true,
      'estado_reporte': 'atendido',
    };
  }

  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    if (moderationFailure != null) throw moderationFailure!;
    return {
      'items': [
        {
          'id': '10000000-0000-0000-0000-000000000001',
          'sesion_id': '20000000-0000-0000-0000-000000000001',
          'motivo': 'contenido_inapropiado',
          'estado': 'desestimado',
          'creado_en': '2026-10-21T12:00:00Z',
          'resuelto_en': null,
        },
      ],
      'has_more': false,
      'next_cursor': '',
    };
  }
}

Widget app(String locale, Widget home) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void setWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

AppLocalizations l10n(WidgetTester tester, Type type) =>
    AppLocalizations.of(tester.element(find.byType(type)))!;

void main() {
  late AuthSession previous;
  setUp(() {
    previous = Session.auth;
    Session.auth = FakeSession()..signedIn = true;
  });
  tearDown(() => Session.auth = previous);

  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'conversation $locale $width localizes link state, errors and composer',
        (tester) async {
          setWidth(tester, width);
          final api = LocalizedChat()
            ..historyFailure = const ChatException(404, 'not_found');
          await tester.pumpWidget(
            app(
              locale,
              ChatConversationScreen(bookingId: booking, apiFactory: () => api),
            ),
          );
          await tester.pumpAndSettle();
          final t = l10n(tester, ChatConversationScreen);
          expect(find.text(t.chatDefaultName), findsOneWidget);
          expect(find.text(t.chatLinkOffline), findsOneWidget);
          expect(find.text(t.chatErrorGone), findsOneWidget);
          expect(find.textContaining('not_found'), findsNothing);
          api.historyFailure = null;
          await tester.tap(find.text(t.chatRetryConnection));
          await tester.pumpAndSettle();
          expect(find.text(t.chatLinkConnected), findsOneWidget);
          expect(find.text(t.chatPrivate), findsOneWidget);
          expect(
            find.text(t.chatBookingWritable(booking.substring(0, 8))),
            findsOneWidget,
          );
          expect(find.text(t.chatEmptyTitle), findsOneWidget);
          expect(
            find.text('Conectado'),
            locale == 'es' ? findsOneWidget : findsNothing,
          );
          // 1001 flags: within the field's grapheme limit, over 2000 runes.
          await tester.enterText(find.byType(TextField), '🇨🇱' * 1001);
          await tester.tap(find.byTooltip(t.chatSend));
          await tester.pumpAndSettle();
          expect(find.text(t.chatTooLong), findsOneWidget);
          expect(api.sent, isEmpty);
          api.sendFailures.add(const ChatException(503, 'unavailable'));
          await tester.enterText(find.byType(TextField), 'Hola');
          await tester.tap(find.byTooltip(t.chatSend));
          await tester.pumpAndSettle();
          expect(find.text(t.chatErrorUnavailable), findsOneWidget);
          expect(find.text(t.chatTooLong), findsNothing);
          await tester.tap(find.byTooltip(t.chatRetrySend));
          await tester.pumpAndSettle();
          expect(api.sent, ['Hola', 'Hola']);
          expect(find.text(t.chatErrorUnavailable), findsNothing);
          expect(find.text(t.chatYou), findsOneWidget);
          expect(find.textContaining(t.chatSaved), findsOneWidget);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }

    testWidgets('closed conversation $locale is read only', (tester) async {
      final api = LocalizedChat()..writable = false;
      await tester.pumpWidget(
        app(
          locale,
          ChatConversationScreen(
            bookingId: booking,
            name: 'Ana',
            apiFactory: () => api,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final t = l10n(tester, ChatConversationScreen);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text(t.chatLinkReadOnly), findsOneWidget);
      expect(
        find.text(t.chatBookingReadOnly(booking.substring(0, 8))),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('conversation list $locale localizes states and failures', (
      tester,
    ) async {
      final api = LocalizedChat()
        ..listFailure = const ChatException(401, 'invalid_token');
      await tester.pumpWidget(app(locale, ChatListScreen(api: api)));
      await tester.pumpAndSettle();
      final t = l10n(tester, ChatListScreen);
      expect(find.text(t.chatListLoadFailed), findsOneWidget);
      expect(find.text(t.chatErrorSession), findsOneWidget);
      api.listFailure = null;
      await tester.tap(find.text(t.chatRetry));
      await tester.pumpAndSettle();
      expect(find.text(t.chatTitle), findsOneWidget);
      expect(
        find.text(
          t.chatListSubtitle(
            t.chatStateActive,
            booking.substring(0, 8),
            t.chatListFirstHello,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          t.chatListSubtitle(
            t.chatStateFinished,
            booking.substring(0, 8),
            'Hasta pronto',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(t.chatListOlder), findsOneWidget);
      expect(find.byTooltip(t.chatModeration), findsNothing);
      api.conversationItems = [];
      await tester.tap(find.byTooltip(t.chatRefreshList));
      await tester.pumpAndSettle();
      expect(find.text(t.chatListEmptyTitle), findsOneWidget);
      expect(find.text(t.chatListBookings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('safety $locale localizes block, report state and failure', (
      tester,
    ) async {
      final api = LocalizedChat()
        ..safetyFailure = const ChatException(503, 'unavailable');
      await tester.pumpWidget(
        app(locale, ChatSafetyScreen(bookingId: booking, api: api)),
      );
      await tester.pumpAndSettle();
      final t = l10n(tester, ChatSafetyScreen);
      expect(find.text(t.safetyLoadFailed), findsOneWidget);
      api.safetyFailure = null;
      await tester.tap(find.text(t.safetyRetry));
      await tester.pumpAndSettle();
      expect(find.text(t.safetyHeadline), findsOneWidget);
      expect(find.text(t.safetyBlocked), findsOneWidget);
      expect(find.text(t.safetyOtherBlock), findsOneWidget);
      expect(find.text(t.safetyBlock), findsOneWidget);
      expect(find.text(t.reportStatusHandled), findsOneWidget);
      expect(find.text(t.safetySendReport), findsNothing);
      expect(reportReasonLabel(t, 'otro'), t.reportReasonOther);
      expect(reportReasonLabel(t, 'future'), t.reportReasonGeneric);
      expect(reportStatusLabel(t, 'future'), isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('moderation $locale localizes queue, access denial and case', (
      tester,
    ) async {
      final api = LocalizedChat()
        ..moderationFailure = const ChatException(403, 'forbidden');
      await tester.pumpWidget(app(locale, ModerationScreen(api: api)));
      await tester.pumpAndSettle();
      final t = l10n(tester, ModerationScreen);
      expect(find.text(t.moderationForbidden), findsOneWidget);
      api.moderationFailure = const ChatException(500, 'unavailable');
      await tester.tap(find.text(t.moderationRetry));
      await tester.pumpAndSettle();
      expect(find.text(t.moderationLoadFailed), findsOneWidget);
      expect(find.text(t.moderationForbidden), findsNothing);
      api.moderationFailure = null;
      await tester.tap(find.text(t.moderationRetry));
      await tester.pumpAndSettle();
      expect(find.text(t.moderationPending), findsOneWidget);
      expect(find.text(t.moderationFilterHandled), findsOneWidget);
      expect(find.text(t.reportReasonInappropriate), findsOneWidget);
      expect(find.text(t.reportStatusDismissed), findsOneWidget);
      expect(
        find.text(t.moderationClosedAt(t.moderationDateUnavailable)),
        findsOneWidget,
      );
      expect(find.text(t.moderationPage(1)), findsOneWidget);
      await tester.pumpWidget(
        app(
          locale,
          ModerationCaseScreen(
            id: '10000000-0000-0000-0000-000000000001',
            api: api,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(t.moderationCaseTitle('10000000')), findsOneWidget);
      await tester.ensureVisible(find.text(t.moderationAccess));
      await tester.tap(find.text(t.moderationAccess));
      await tester.pumpAndSettle();
      expect(find.text(t.moderationJustificationTooShort), findsOneWidget);
      api.moderationFailure = const ChatException(409, 'closed');
      await tester.enterText(
        find.byType(TextFormField),
        'Revisar el incidente reportado',
      );
      await tester.ensureVisible(find.text(t.moderationAccess));
      await tester.tap(find.text(t.moderationAccess));
      await tester.pumpAndSettle();
      expect(find.text(t.moderationAccessFailed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
