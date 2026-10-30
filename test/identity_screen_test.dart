import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentacompa/features/identity/data/identity_api.dart';
import 'package:rentacompa/features/identity/ui/identity_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';

class FakeIdentityApi extends IdentityApi {
  FakeIdentityApi() : super('http://fixture.invalid');
  String state = 'none';
  int? loadFailure, startFailure;
  final purposes = <String>[];
  @override
  Future<String> status() async {
    if (loadFailure != null) throw ApiException(loadFailure!, 'private');
    return state;
  }

  @override
  Future<({String status, String? url})> start(String purpose) async {
    purposes.add(purpose);
    if (startFailure != null) throw ApiException(startFailure!, 'private');
    state = 'pending';
    return (
      status: 'pending',
      url: 'https://provider.example/session?ref=fake_1',
    );
  }
}

void main() {
  for (final locale in ['es', 'en']) {
    for (final width in [360.0, 1200.0]) {
      testWidgets(
        'identity $locale $width starts, opens provider and shows states',
        (tester) async {
          tester.view.physicalSize = Size(width, 1400);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = FakeIdentityApi()..loadFailure = 500;
          final opened = <Uri>[];
          var openResult = true;
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: IdentityScreen(
                purpose: 'compa_onboarding',
                api: api,
                open: (uri) async {
                  opened.add(uri);
                  return openResult;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          final t = AppLocalizations.of(
            tester.element(find.byType(IdentityScreen)),
          )!;
          for (final text in [
            t.identityTitle,
            t.identityWhy,
            t.identityStored,
            t.identityProcessor,
            t.identityNoGuarantee,
          ]) {
            expect(find.text(text), findsOneWidget, reason: text);
          }
          expect(find.text(t.identityLoadFailed), findsOneWidget);
          expect(find.text(t.identityStart), findsNothing);
          expect(find.textContaining('private'), findsNothing);
          api.loadFailure = null;
          await tester.tap(find.text(t.identityRetry));
          await tester.pumpAndSettle();
          await tester.tap(find.text(t.identityStart));
          await tester.pumpAndSettle();
          expect(api.purposes, ['compa_onboarding']);
          expect(opened.single.host, 'provider.example');
          expect(find.text(t.identityPending), findsOneWidget);
          expect(find.text(t.identityPendingHelp), findsOneWidget);
          openResult = false;
          await tester.tap(find.text(t.identityStart));
          await tester.pumpAndSettle();
          expect(find.text(t.identityOpenFailed), findsOneWidget);
          for (final entry in {
            'approved': t.identityApproved,
            'needs_review': t.identityReview,
          }.entries) {
            api.state = entry.key;
            await tester.tap(find.byTooltip(t.identityRefresh));
            await tester.pumpAndSettle();
            expect(find.text(entry.value), findsOneWidget);
            expect(find.byType(FilledButton), findsNothing, reason: entry.key);
          }
          for (final entry in {
            'rejected': t.identityRejected,
            'expired': t.identityExpired,
          }.entries) {
            api.state = entry.key;
            await tester.tap(find.byTooltip(t.identityRefresh));
            await tester.pumpAndSettle();
            expect(find.text(entry.value), findsOneWidget);
            expect(
              find.widgetWithText(FilledButton, t.identityRetry),
              findsOneWidget,
            );
          }
          api.startFailure = 500;
          await tester.tap(find.text(t.identityRetry));
          await tester.pumpAndSettle();
          expect(find.text(t.identityStartFailed), findsOneWidget);
          expect(find.text('Identidad verificada'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('identity $locale without a provider offers no flow', (
      tester,
    ) async {
      final api = FakeIdentityApi()..loadFailure = 503;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: IdentityScreen(api: api, open: (_) async => true),
        ),
      );
      await tester.pumpAndSettle();
      final t = AppLocalizations.of(
        tester.element(find.byType(IdentityScreen)),
      )!;
      expect(find.text(t.identityUnavailable), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(api.purposes, isEmpty);
    });
  }
}
