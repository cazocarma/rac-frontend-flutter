import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentacompa/app_routes.dart';
import 'package:rentacompa/features/settings/ui/settings_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/services/theme.dart';
import 'editorial_api_test.dart' show StaffFixture;

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'settings $locale $width preserves theme persistence and documents route',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          final previous = appTheme.mode;
          addTearDown(() => appTheme.setMode(previous));
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SettingsScreen(),
              routes: {
                '/documents': (_) =>
                    const Scaffold(body: Text('documents target')),
              },
            ),
          );
          final t = AppLocalizations.of(
            tester.element(find.byType(SettingsScreen)),
          )!;
          expect(find.text(t.settingsHeading), findsOneWidget);
          await tester.ensureVisible(find.text(t.settingsDark));
          await tester.tap(find.text(t.settingsDark));
          await tester.pumpAndSettle();
          expect(appTheme.mode, ThemeMode.dark);
          expect(
            (await SharedPreferences.getInstance()).getString('theme_mode'),
            'dark',
          );
          await tester.ensureVisible(find.text(t.settingsDocuments));
          await tester.tap(find.text(t.settingsDocuments));
          await tester.pumpAndSettle();
          expect(find.text('documents target'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets(
      'localized menu $locale keeps destination routes and admin role visibility',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final previous = Session.auth;
        Session.auth = StaffFixture();
        addTearDown(() => Session.auth = previous);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => const HomeShell().menu(context),
              ),
            ),
            routes: {
              '/settings': (_) => const Scaffold(body: Text('settings target')),
            },
          ),
        );
        await tester.pumpAndSettle();
        // The menu is rendered directly; use a built child context for translations.
        final t = AppLocalizations.of(tester.element(find.byType(ListView)))!;
        expect(
          const HomeShell()
              .destinations(tester.element(find.byType(ListView)))
              .map((d) => d.$3),
          [
            '/home',
            '/match',
            '/chat',
            '/become-compa',
            '/payments',
            '/alerts',
            '/profile',
            '/settings',
          ],
        );
        expect(find.text(t.navAdmin), findsOneWidget);
        await tester.ensureVisible(find.text(t.settingsTitle));
        await tester.tap(find.text(t.settingsTitle));
        await tester.pumpAndSettle();
        expect(find.text('settings target'), findsOneWidget);
      },
    );
  }
}
