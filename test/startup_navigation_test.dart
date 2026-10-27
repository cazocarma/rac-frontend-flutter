import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/main.dart';

Widget screen(String name) => Scaffold(
  appBar: AppBar(title: Text(name)),
  body: Builder(
    builder: (context) => Text('canPop:${Navigator.canPop(context)}'),
  ),
);
Widget app(String requested, {bool logged = true}) => MaterialApp(
  home: StartupGate(
    requestedRoute: requested,
    checkSession: () async => logged,
  ),
  routes: {
    '/home': (_) => screen('Home fixture'),
    '/documents': (_) => screen('Documents fixture'),
    '/login': (_) => screen('Login fixture'),
  },
);
void main() {
  testWidgets(
    'direct authenticated document URL returns to home instead of a blank navigator',
    (tester) async {
      await tester.pumpWidget(app('/documents'));
      await tester.pumpAndSettle();
      expect(find.text('Documents fixture'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Documents fixture'))).canPop(),
        true,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Home fixture'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.text('Home fixture'))).canPop(),
        false,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('unknown direct route resolves to a single home page', (
    tester,
  ) async {
    await tester.pumpWidget(app('/unknown'));
    await tester.pumpAndSettle();
    expect(find.text('Home fixture'), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.text('Home fixture'))).canPop(),
      false,
    );
  });
  testWidgets('anonymous direct route does not enter the authenticated stack', (
    tester,
  ) async {
    await tester.pumpWidget(app('/documents', logged: false));
    await tester.pumpAndSettle();
    expect(find.text('Login fixture'), findsOneWidget);
    expect(find.text('Home fixture'), findsNothing);
    expect(find.text('Documents fixture'), findsNothing);
  });
}
