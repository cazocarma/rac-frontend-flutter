import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/profile/ui/profile_screen.dart';
import 'package:rentacompa/shared/services/user_api.dart';
import 'package:rentacompa/shared/widgets/design.dart';

class ProfileApi extends UserApi {
  ProfileApi() : super('http://fixture');
  bool fail = false;
  Map<String, dynamic>? saved;
  @override
  Future<Map<String, dynamic>> me() async => {
    'nombre': 'Cris',
    'correo': 'cris@fixture.test',
    'role': 'cliente',
    'intereses': ['Cine'],
  };
  @override
  Future<void> savePersonalProfile(Map<String, dynamic> payload) async {
    if (fail) throw StateError('offline');
    saved = payload;
  }
}

void main() {
  testWidgets(
    'personal fields save without identity or role; failures retain edits',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ProfileApi();
      await tester.pumpWidget(
        MaterialApp(
          theme: racTheme(Brightness.light),
          home: ProfileScreen(api: api),
        ),
      );
      await tester.pumpAndSettle();
      final name = find.widgetWithText(TextFormField, 'Nombre visible');
      await tester.enterText(name, 'Cris actualizado');
      await tester.pumpAndSettle();
      api.fail = true;
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, 'Guardar cambios');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Se conservan en el formulario'),
        findsOneWidget,
      );
      expect(find.text('Cris actualizado'), findsOneWidget);
      api.fail = false;
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(api.saved!['nombre'], 'Cris actualizado');
      expect(api.saved!.containsKey('correo'), isFalse);
      expect(api.saved!.containsKey('role'), isFalse);
      expect(find.text('Tu perfil se guardó correctamente'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('profile fits narrow mobile and validates a short name', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 811);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ProfileApi();
    await tester.pumpWidget(
      MaterialApp(
        theme: racTheme(Brightness.dark),
        home: ProfileScreen(api: api),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre visible'),
      'A',
    );
    await tester.pumpAndSettle();
    final save = find.widgetWithText(FilledButton, 'Guardar cambios');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Ingresa al menos dos caracteres'), findsOneWidget);
    expect(api.saved, isNull);
    expect(tester.takeException(), isNull);
  });
}
