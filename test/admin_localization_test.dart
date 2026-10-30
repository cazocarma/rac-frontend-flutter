import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/admin/ui/admin_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/widgets/brand.dart';
import 'admin_screen_test.dart' show AdminApi;

Widget app(String locale, Widget home) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets('admin $locale $width localizes sections and failures', (
        tester,
      ) async {
        // Tall enough for the lazy ListView to build every section.
        tester.view.physicalSize = Size(width, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = AdminApi()..status = 503;
        await tester.pumpWidget(app(locale, AdminScreen(api: api)));
        await tester.pumpAndSettle();
        final t = AppLocalizations.of(
          tester.element(find.byType(AdminScreen)),
        )!;
        expect(find.text(t.adminLoadFailed), findsOneWidget);
        expect(find.text(t.adminLoadHelp), findsOneWidget);
        api.status = null;
        await tester.tap(find.text(t.adminRetry));
        await tester.pumpAndSettle();
        for (final label in [
          t.adminTitle,
          t.adminHeadline,
          t.adminCommunity,
          t.adminUsers,
          t.adminCompas,
          t.adminBookings,
          t.adminPending,
          t.adminConfirmed,
          t.adminFinished,
          t.adminCancelled,
          t.adminExpired,
          t.adminModeration,
          t.moderationFilterOpen,
          t.moderationFilterHandled,
          t.moderationFilterDismissed,
          t.adminModerationNote,
          t.adminReviewReports,
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
        expect(find.textContaining(t.adminQueriedAt('')), findsOneWidget);
        expect(
          find.text('Usuarios con perfil'),
          locale == 'es' ? findsOneWidget : findsNothing,
        );
        api.status = 403;
        await tester.tap(find.byTooltip(t.adminRefresh));
        await tester.pumpAndSettle();
        expect(find.text(t.adminForbiddenTitle), findsOneWidget);
        expect(find.text(t.adminForbiddenMessage), findsOneWidget);
        expect(find.text(t.adminRetry), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('activity artwork $locale localizes its captions', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(locale, const Scaffold(body: Center(child: ActivityArtwork()))),
      );
      final t = AppLocalizations.of(
        tester.element(find.byType(ActivityArtwork)),
      )!;
      expect(find.text(t.artworkCoffee), findsOneWidget);
      expect(find.text(t.artworkRunning), findsOneWidget);
      expect(find.text(t.artworkMovie), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
