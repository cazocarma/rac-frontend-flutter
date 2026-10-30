import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/match/ui/time_off_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';
import 'time_off_screen_test.dart' show ScheduleApi;

class LocalizedSchedule extends ScheduleApi {
  int? loadFailure;
  bool invalidBounds = false;
  @override
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    if (method == null && body == null && loadFailure != null) {
      throw ApiException(loadFailure!, 'private upstream diagnostic');
    }
    final value = await super.request(
      path,
      body: body,
      poll: poll,
      retryAuth: retryAuth,
      method: method,
    );
    return invalidBounds ? {...value, 'fecha_min': '2050-01-01'} : value;
  }
}

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'time off $locale $width confirms deletion and rejects stale empty agenda after failed refresh',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = LocalizedSchedule();
          addTearDown(api.close);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: TimeOffScreen(api: api, compaId: 'me'),
            ),
          );
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(TimeOffScreen)),
          )!;
          expect(
            find.text(t.timeOffFullDays('America/Santiago')),
            findsOneWidget,
          );
          await tester.tap(find.byTooltip(t.timeOffRemove));
          await tester.pumpAndSettle();
          expect(
            find.text(t.timeOffRemoveMessage('2026-12-01', '2026-12-02')),
            findsOneWidget,
          );
          await tester.tap(find.text(t.timeOffKeep));
          await tester.pumpAndSettle();
          expect(api.removed, isFalse);
          api.fail = true;
          await tester.tap(find.byTooltip(t.timeOffRemove));
          await tester.pumpAndSettle();
          await tester.tap(find.text(t.timeOffRemove));
          await tester.pumpAndSettle();
          expect(find.text(t.timeOffSaveFailed), findsOneWidget);
          expect(find.text('2026-12-01 → 2026-12-02'), findsOneWidget);
          api.fail = false;
          await tester.tap(find.byTooltip(t.timeOffRemove));
          await tester.pumpAndSettle();
          await tester.tap(find.text(t.timeOffRemove));
          await tester.pumpAndSettle();
          expect(api.lastMethod, 'DELETE');
          expect(find.text(t.timeOffEmpty), findsOneWidget);
          api.loadFailure = 503;
          await tester.tap(find.byTooltip(t.timeOffRefresh));
          await tester.pumpAndSettle();
          expect(find.text(t.timeOffLoadFailed), findsOneWidget);
          expect(find.text(t.timeOffEmpty), findsNothing);
          expect(find.text(t.timeOffAdd), findsNothing);
          expect(find.textContaining('private upstream'), findsNothing);
          api.loadFailure = null;
          await tester.tap(find.text(t.timeOffRetry));
          await tester.pumpAndSettle();
          expect(find.text(t.timeOffAdd), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets(
      'time off $locale rejects invalid bounds and explains owner denial',
      (tester) async {
        final api = LocalizedSchedule()..loadFailure = 403;
        addTearDown(api.close);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TimeOffScreen(api: api, compaId: 'me'),
          ),
        );
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(TimeOffScreen)),
        )!;
        expect(find.text(t.timeOffForbidden), findsOneWidget);
        api.loadFailure = null;
        api.invalidBounds = true;
        await tester.tap(find.text(t.timeOffRetry));
        await tester.pumpAndSettle();
        expect(find.text(t.timeOffLoadFailed), findsOneWidget);
        expect(find.text(t.timeOffAdd), findsNothing);
        expect(find.text('2026-12-01 → 2026-12-02'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
