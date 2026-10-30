import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'profile_test.dart' show ProfileApi;

class LocalizedProfile extends ProfileApi {
  bool unavailable = true;
  int loads = 0;
  @override
  Future<Map<String, dynamic>> me() async {
    loads++;
    if (unavailable) throw StateError('private upstream diagnostic');
    return {
      ...await super.me(),
      'telefono': '123456789',
      'pais': 'Private country',
      'foto_version': 'fixture-photo',
    };
  }

  @override
  Future<Uint8List?> ownPhoto() async =>
      throw const ProfilePhotoException(ProfilePhotoFailure.load);
}

void main() {
  testWidgets('stored profile failure follows locale without another request', (
    tester,
  ) async {
    final api = LocalizedProfile();
    addTearDown(api.client.close);
    Widget app(String locale) => MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProfileScreen(api: api),
    );
    await tester.pumpWidget(app('es'));
    await tester.pumpAndSettle();
    final spanish = AppLocalizations.of(
      tester.element(find.byType(ProfileScreen)),
    )!;
    expect(find.text(spanish.profileLoadFailed), findsOneWidget);
    api.unavailable = false;
    await tester.pumpWidget(app('en'));
    await tester.pumpAndSettle();
    final english = AppLocalizations.of(
      tester.element(find.byType(ProfileScreen)),
    )!;
    expect(find.text(english.profileLoadFailed), findsOneWidget);
    expect(find.text(spanish.profileLoadFailed), findsNothing);
    expect(api.loads, 1);
    expect(tester.takeException(), isNull);
  });
  for (final entry in {
    400: ProfilePhotoFailure.invalidImage,
    415: ProfilePhotoFailure.invalidImage,
    413: ProfilePhotoFailure.tooLarge,
    429: ProfilePhotoFailure.busy,
    503: ProfilePhotoFailure.save,
  }.entries) {
    test(
      'photo API maps ${entry.key} to a typed failure without upstream text',
      () async {
        final api = UserApi(
          'https://fixture.invalid',
          tokenProvider: () async => 'fixture',
          client: MockClient((request) async {
            expect(request.method, 'PUT');
            expect(request.headers['Content-Type'], 'image/png');
            expect(request.headers['Authorization'], 'Bearer fixture');
            return http.Response('private upstream diagnostic', entry.key);
          }),
        );
        addTearDown(api.client.close);
        await expectLater(
          api.savePhoto(Uint8List.fromList([1, 2]), 'image/png'),
          throwsA(
            isA<ProfilePhotoException>().having(
              (error) => error.failure,
              'failure',
              entry.value,
            ),
          ),
        );
      },
    );
  }
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'profile $locale $width retains draft, localizes errors and keeps contacts out of preview',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = LocalizedProfile();
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
          expect(find.text(t.profileLoadFailed), findsOneWidget);
          expect(find.textContaining('private upstream'), findsNothing);
          api.unavailable = false;
          await tester.tap(find.text(t.profileRetry));
          await tester.pumpAndSettle();
          expect(find.text(t.profilePhotoLoadFailed), findsOneWidget);
          final name = find.widgetWithText(TextFormField, t.profileName);
          await tester.ensureVisible(name);
          await tester.enterText(name, 'Synthetic updated name');
          final biography = find.widgetWithText(
            TextFormField,
            t.profileBiography,
          );
          await tester.ensureVisible(biography);
          await tester.enterText(biography, 'Synthetic unsaved biography');
          FocusManager.instance.primaryFocus?.unfocus();
          final preview = find.text(t.profilePublicPreview);
          await tester.ensureVisible(preview);
          await tester.tap(preview);
          await tester.pumpAndSettle();
          expect(find.text('Synthetic unsaved biography'), findsOneWidget);
          expect(find.text(t.publicProfileAbout), findsOneWidget);
          expect(find.text('123456789'), findsNothing);
          expect(find.text('Private country'), findsNothing);
          expect(find.text('cris@fixture.test'), findsNothing);
          expect(api.saved, isNull);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          api.fail = true;
          final save = find.text(t.profileSave);
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(find.text(t.profileSaveFailed), findsOneWidget);
          expect(find.text('Synthetic updated name'), findsOneWidget);
          expect(find.text('Synthetic unsaved biography'), findsOneWidget);
          api.fail = false;
          await tester.ensureVisible(save);
          await tester.tap(save);
          await tester.pumpAndSettle();
          expect(api.saved?['nombre'], 'Synthetic updated name');
          expect(api.saved?['biografia'], 'Synthetic unsaved biography');
          expect(api.saved?.containsKey('correo'), isFalse);
          expect(api.saved?.containsKey('role'), isFalse);
          expect(find.text(t.profileSaved), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
