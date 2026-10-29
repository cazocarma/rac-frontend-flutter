import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/compa_onboarding/ui/become_compa_screen.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'Compa $locale at $width preserves draft and wire day after prerequisite rejection',
        (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          Map<String, dynamic>? saved;
          final api = UserApi(
            'https://fixture.invalid',
            tokenProvider: () async => 'fixture',
            client: MockClient((request) async {
              if (request.method == 'PUT') {
                saved = jsonDecode(request.body) as Map<String, dynamic>;
                return http.Response(
                  '{"error":"DOCUMENT_ACCEPTANCE_REQUIRED"}',
                  428,
                );
              }
              return request.url.path.endsWith('/me/compa')
                  ? http.Response('{}', 404)
                  : http.Response('{"role":"cliente"}', 200);
            }),
          );
          addTearDown(api.client.close);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BecomeCompaScreen(api: api),
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(BecomeCompaScreen));
          final t = AppLocalizations.of(context)!;
          Finder field(String label) => find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == label,
          );
          await tester.enterText(
            field(t.compaAboutLabel),
            'Synthetic description for localization checks.',
          );
          await tester.enterText(field(t.compaRateLabel), '12000');
          await tester.enterText(field(t.compaSkillsLabel), 'cine');
          await tester.ensureVisible(field(t.compaMonday));
          await tester.enterText(field(t.compaMonday), '18:00-20:00');
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          final activate = find.widgetWithText(
            FilledButton,
            t.compaActivateProfile,
          );
          await tester.ensureVisible(activate);
          await tester.pumpAndSettle();
          await tester.tap(activate);
          await tester.pumpAndSettle();
          expect(saved?['availability'], {
            'lunes': ['18:00-20:00'],
          });
          expect(
            saved?['descripcion'],
            'Synthetic description for localization checks.',
          );
          expect(find.text(t.compaPrerequisitesPending), findsOneWidget);
          expect(
            find.text('Synthetic description for localization checks.'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
