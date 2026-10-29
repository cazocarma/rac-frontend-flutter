import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/auth/unified_auth_screen.dart';
import 'package:rentacompa/shared/services/auth_api.dart';
import 'package:rentacompa/shared/services/auth_session.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';

class FakeSession implements AuthSession {
  @override
  Future<void> refresh() async {}
  bool signedIn = false;
  bool cleared = false;
  bool fail = false;
  @override
  Map<String, dynamic> get claims => {
    'realm_access': {
      'roles': ['compa', 'cliente'],
    },
  };
  @override
  Future<void> login() async {
    if (fail) throw StateError('cancelled');
    signedIn = true;
  }

  @override
  Future<String?> accessToken() async =>
      signedIn ? 'verified-access-token' : null;
  @override
  Future<void> clear() async {
    signedIn = false;
    cleared = true;
  }

  @override
  Future<void> logout() async => clear();
}

void main() {
  test('staff manager has isolated client, callback and storage identity', () {
    final ordinary = OidcAuthSession();
    final staff = OidcAuthSession.staff(
      issuer: Uri.parse('https://identity.test/realms/rac'),
      appOrigin: Uri.parse('https://rac.test'),
    );
    expect(staff.manager.id, 'rac-staff-console');
    expect(ordinary.manager.id, isNull);
    expect(
      staff.manager.settings.redirectUri,
      Uri.parse('https://rac.test/staff/redirect.html'),
    );
    expect(
      staff.manager.settings.expectedIssuer,
      Uri.parse('https://identity.test/realms/rac'),
    );
    expect(ordinary.isStaff, isFalse);
    expect(
      () => OidcAuthSession.staff(
        issuer: Uri.parse('https://identity.test/realms/rac'),
        appOrigin: Uri.parse('https://rac.test/path?callback=evil'),
      ),
      throwsArgumentError,
    );
  });
  test(
    'migration removes legacy tokens without removing user preferences',
    () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'legacy',
        'refresh_token': 'legacy',
        'internal_token': 'legacy',
        'user_role': 'admin',
        'theme_mode': 'dark',
      });
      await Session.clearLegacyTokens();
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('access_token'), isNull);
      expect(preferences.getString('refresh_token'), isNull);
      expect(preferences.getString('internal_token'), isNull);
      expect(preferences.getString('user_role'), isNull);
      expect(preferences.getString('theme_mode'), 'dark');
    },
  );
  test('OIDC session provisions own profile with Bearer token', () async {
    final session = FakeSession();
    final auth = AuthApi(
      session: session,
      apiBase: 'http://api.example',
      client: MockClient((request) async {
        expect(request.url.path, '/api/user/me');
        expect(
          request.headers['Authorization'],
          'Bearer verified-access-token',
        );
        expect(request.body, isEmpty);
        return http.Response('{"id":"user"}', 200);
      }),
    );
    await auth.login();
    expect(session.signedIn, isTrue);
    await auth.logout();
    expect(await session.accessToken(), isNull);
  });
  test('profile failure clears local authenticated state', () async {
    final session = FakeSession();
    final auth = AuthApi(
      session: session,
      client: MockClient((_) async => http.Response('{}', 409)),
    );
    await expectLater(auth.login(), throwsStateError);
    expect(session.cleared, isTrue);
  });
  test('roles prioritize admin and preserve compa role', () {
    expect(
      Session.roleFromClaims({
        'realm_access': {
          'roles': ['cliente', 'compa'],
        },
      }),
      'compa',
    );
    expect(
      Session.roleFromClaims({
        'realm_access': {
          'roles': ['compa', 'admin'],
        },
      }),
      'admin',
    );
  });
  testWidgets('login opens provider and navigates; no app password form', (
    tester,
  ) async {
    final auth = AuthApi(
      session: FakeSession(),
      client: MockClient((_) async => http.Response('{"id":"own-user"}', 200)),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UnifiedAuthScreen(auth: auth),
        routes: {'/home': (_) => const Scaffold(body: Text('Inicio'))},
      ),
    );
    expect(find.byType(TextField), findsNothing);
    await tester.ensureVisible(find.text('Ingresar o crear cuenta'));
    await tester.tap(find.text('Ingresar o crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsOneWidget);
  });
  testWidgets('cancelled provider login shows retry and stays signed out', (
    tester,
  ) async {
    final session = FakeSession()..fail = true;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: UnifiedAuthScreen(auth: AuthApi(session: session)),
      ),
    );
    await tester.ensureVisible(find.text('Ingresar o crear cuenta'));
    await tester.tap(find.text('Ingresar o crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pudimos iniciar sesión'), findsOneWidget);
    expect(session.signedIn, isFalse);
  });
}
