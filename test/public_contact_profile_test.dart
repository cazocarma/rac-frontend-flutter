import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';
import 'profile_test.dart' show ProfileApi;

class ContactProfileApi extends ProfileApi {
  bool reject = true;
  @override
  Future<void> savePersonalProfile(Map<String, dynamic> payload) async {
    if (reject) throw const ApiException(400, 'public_contact_not_allowed');
    await super.savePersonalProfile(payload);
  }
}

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'profile contact rejection retains draft and allows correction $locale $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = ContactProfileApi();
          addTearDown(api.client.close);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ProfileScreen(api: api),
            ),
          );
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(ProfileScreen)),
          )!;
          final name = find.widgetWithText(TextFormField, t.profileName);
          await tester.ensureVisible(name);
          await tester.enterText(name, 'Synthetic draft');
          final save = find.text(t.profileSave);
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(find.text(t.publicContactNotAllowed), findsOneWidget);
          expect(find.text('Synthetic draft'), findsOneWidget);
          expect(api.saved, isNull);
          api.reject = false;
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(api.saved?['nombre'], 'Synthetic draft');
          expect(find.text(t.publicContactNotAllowed), findsNothing);
          expect(find.text(t.profileSaved), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
