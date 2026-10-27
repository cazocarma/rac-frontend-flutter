import 'dart:async';
import 'package:rentacompa/features/documents/ui/document_prompt_host.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rentacompa/features/compa_onboarding/data/assessment_api.dart';
import 'package:rentacompa/features/compa_onboarding/ui/assessment_screen.dart';
import 'package:rentacompa/l10n/generated/app_localizations.dart';
import 'package:rentacompa/shared/services/json_api.dart';

Map<String, dynamic> sample() => {
  'version': 'synthetic-1',
  'sha256': 'a' * 64,
  'registry': {
    'locale': 'es',
    'version': 2,
    'policy_version': '11111111-1111-4111-8111-111111111111',
  },
  'statements': [
    for (final id in CompaAssessment.statementIds)
      {'id': id, 'text': 'Declaración sintética $id'},
  ],
  'questions': [
    for (final id in ['scenario_one', 'scenario_two', 'scenario_three'])
      {
        'id': id,
        'text': 'Situación sintética $id',
        'options': [
          {'id': 'reject_report', 'text': 'Rechazar y reportar'},
          {'id': 'proceed', 'text': 'Continuar'},
        ],
      },
  ],
  'quiz_passed_at': null,
};

class FakeAssessment extends AssessmentApi {
  FakeAssessment() : super('https://fixture.invalid');
  int submitted = 0;
  bool conflict = false, wrong = false, unavailable = false;
  @override
  Future<CompaAssessment> current() async {
    if (unavailable) throw const ApiException(503, 'attestations_unavailable');
    return CompaAssessment.fromJson(sample());
  }

  @override
  Future<void> submit(
    CompaAssessment assessment,
    Map<String, bool> statements,
    Map<String, String> answers,
  ) async {
    submitted++;
    expect(statements.length, 5);
    expect(statements.values.every((v) => v), true);
    expect(answers.length, 3);
    if (conflict) throw const ApiException(409, 'attestation_version_changed');
    if (wrong) throw const ApiException(422, 'quiz_incorrect');
  }
}

Widget app(FakeAssessment api) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: AssessmentScreen(api: api),
);
Future<void> complete(WidgetTester tester) async {
  for (final id in CompaAssessment.statementIds) {
    await tester.ensureVisible(find.byKey(ValueKey(id)));
    await tester.tap(find.byKey(ValueKey(id)));
    await tester.pump();
  }
  for (final id in ['scenario_one', 'scenario_two', 'scenario_three']) {
    await tester.ensureVisible(find.byKey(ValueKey('$id:reject_report')));
    await tester.tap(find.byKey(ValueKey('$id:reject_report')));
    await tester.pump();
  }
  await tester.ensureVisible(find.text('Confirmar declaraciones y respuestas'));
}

void main() {
  testWidgets(
    'a server prerequisite opens one assessment and disposes its subscription',
    (tester) async {
      final events = StreamController<void>.broadcast();
      final key = GlobalKey<NavigatorState>();
      var created = 0;
      await tester.pumpWidget(
        DocumentPromptHost(
          navigatorKey: key,
          assessmentEvents: events.stream,
          createAssessmentApi: () {
            created++;
            return FakeAssessment();
          },
          child: MaterialApp(
            navigatorKey: key,
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Original')),
          ),
        ),
      );
      events.add(null);
      events.add(null);
      await tester.pumpAndSettle();
      expect(created, 1);
      expect(find.byType(AssessmentScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(events.hasListener, false);
      await events.close();
    },
  );

  test('invalid or answer-key-bearing definitions cannot render', () {
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (json) => (json['statements'] as List).removeLast(),
      (json) =>
          (json['questions'] as List).first['correct_option'] = 'reject_report',
      (json) => (json['questions'] as List).first['options'].add({
        'id': 'proceed',
        'text': 'Duplicada',
      }),
      (json) => (json['registry'] as Map)['version'] = 0,
    ]) {
      final json = sample();
      mutate(json);
      expect(() => CompaAssessment.fromJson(json), throwsFormatException);
    }
  });
  test(
    'API submits only exact own version, declarations, answers and registry reference',
    () async {
      var calls = 0;
      final api = AssessmentApi(
        'https://fixture.invalid',
        token: () async => 'fixture',
        client: MockClient((request) async {
          calls++;
          final body = jsonDecode(request.body) as Map;
          expect(request.method, 'POST');
          expect(body.keys.toSet(), {
            'version',
            'sha256',
            'registry',
            'statements',
            'answers',
          });
          expect((body['registry'] as Map).keys.toSet(), {
            'locale',
            'version',
            'policy_version',
          });
          expect(body['version'], 'synthetic-1');
          return http.Response('{}', 200);
        }),
      );
      await api.submit(
        CompaAssessment.fromJson(sample()),
        {for (final id in CompaAssessment.statementIds) id: true},
        {
          for (final id in ['scenario_one', 'scenario_two', 'scenario_three'])
            id: 'reject_report',
        },
      );
      expect(calls, 1);
      api.close();
    },
  );
  for (final width in [360.0, 1200.0]) {
    testWidgets(
      'five unchecked declarations and three unanswered scenarios at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = FakeAssessment();
        await tester.pumpWidget(app(api));
        await tester.pumpAndSettle();
        for (final box in tester.widgetList<CheckboxListTile>(
          find.byType(CheckboxListTile),
        )) {
          expect(box.value, false);
        }
        for (final group in tester.widgetList<RadioGroup<String>>(
          find.byType(RadioGroup<String>),
        )) {
          expect(group.groupValue, isNull);
        }
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        expect(api.submitted, 0);
        await complete(tester);
        await tester.tap(find.text('Confirmar declaraciones y respuestas'));
        await tester.pumpAndSettle();
        expect(api.submitted, 1);
        expect(
          find.text('Ya completaste esta versión del cuestionario.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'incorrect answers preserve edits and a stale version clears them',
    (tester) async {
      final api = FakeAssessment()..wrong = true;
      await tester.pumpWidget(app(api));
      await tester.pumpAndSettle();
      await complete(tester);
      await tester.tap(find.text('Confirmar declaraciones y respuestas'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Revisa las tres situaciones. Todas deben responderse correctamente.',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      api.wrong = false;
      api.conflict = true;
      await tester.tap(find.text('Confirmar declaraciones y respuestas'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      for (final box in tester.widgetList<CheckboxListTile>(
        find.byType(CheckboxListTile),
      )) {
        expect(box.value, false);
      }
      await tester.ensureVisible(find.text('Volver a cargar'));
      await tester.tap(find.text('Volver a cargar'));
      await tester.pumpAndSettle();
      expect(api.submitted, 2);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    },
  );
  testWidgets('unavailable definition never invents declarations or success', (
    tester,
  ) async {
    final api = FakeAssessment()..unavailable = true;
    await tester.pumpWidget(app(api));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(
      find.textContaining('todavía no hay un cuestionario revisado'),
      findsOneWidget,
    );
    expect(api.submitted, 0);
  });
}
