import '../../../shared/services/json_api.dart';
import '../../documents/data/documents_api.dart';

class AssessmentOption {
  const AssessmentOption(this.id, this.text);
  final String id, text;
}

class AssessmentQuestion {
  const AssessmentQuestion(this.id, this.text, this.options);
  final String id, text;
  final List<AssessmentOption> options;
}

class CompaAssessment {
  const CompaAssessment({
    required this.version,
    required this.sha256,
    required this.registry,
    required this.statements,
    required this.questions,
    this.passedAt,
  });
  final String version, sha256;
  final DocumentRegistry registry;
  final Map<String, String> statements;
  final List<AssessmentQuestion> questions;
  final DateTime? passedAt;
  static const statementIds = {
    'no_illicit_substances',
    'no_sexual_services',
    'catalog_only',
    'adults_only',
    'enforcement_and_appeal',
  };
  static final _id = RegExp(r'^[a-z][a-z0-9_]{0,63}$');
  static String text(dynamic value, int max) {
    if (value is! String || value.trim().isEmpty || value.runes.length > max) {
      throw const FormatException('Invalid assessment text');
    }
    return value;
  }

  factory CompaAssessment.fromJson(Map<String, dynamic> json) {
    final version = text(json['version'], 64), hash = text(json['sha256'], 64);
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$').hasMatch(version) ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash) ||
        json['statements'] is! List ||
        (json['statements'] as List).length != 5 ||
        json['questions'] is! List ||
        (json['questions'] as List).length != 3) {
      throw const FormatException('Invalid assessment');
    }
    final statements = <String, String>{};
    for (final item in json['statements'] as List) {
      if (item is! Map ||
          !statementIds.contains(item['id']) ||
          statements.containsKey(item['id'])) {
        throw const FormatException('Invalid declarations');
      }
      statements[item['id'] as String] = text(item['text'], 2000);
    }
    final questions = <AssessmentQuestion>[], ids = <String>{};
    for (final item in json['questions'] as List) {
      if (item is! Map ||
          item.containsKey('correct_option') ||
          item['id'] is! String ||
          !_id.hasMatch(item['id'] as String) ||
          !ids.add(item['id'] as String) ||
          item['options'] is! List ||
          (item['options'] as List).length < 2 ||
          (item['options'] as List).length > 4) {
        throw const FormatException('Invalid scenario');
      }
      final options = <AssessmentOption>[], optionIds = <String>{};
      for (final option in item['options'] as List) {
        if (option is! Map ||
            option['id'] is! String ||
            !_id.hasMatch(option['id'] as String) ||
            !optionIds.add(option['id'] as String)) {
          throw const FormatException('Invalid scenario option');
        }
        options.add(
          AssessmentOption(option['id'] as String, text(option['text'], 1000)),
        );
      }
      questions.add(
        AssessmentQuestion(
          item['id'] as String,
          text(item['text'], 2000),
          List.unmodifiable(options),
        ),
      );
    }
    return CompaAssessment(
      version: version,
      sha256: hash,
      registry: DocumentRegistry.fromReference(
        json['registry'] as Map<String, dynamic>,
      ),
      statements: Map.unmodifiable(statements),
      questions: List.unmodifiable(questions),
      passedAt: json['quiz_passed_at'] == null
          ? null
          : DateTime.parse(json['quiz_passed_at'] as String),
    );
  }
}

class AssessmentApi extends JsonApi {
  AssessmentApi(super.base, {super.client, super.token, super.refresh})
    : super(apiPath: '/api/user');
  Future<CompaAssessment> current() async => CompaAssessment.fromJson(
    await request('/me/compa/attestation?locale=es'),
  );
  Future<void> submit(
    CompaAssessment assessment,
    Map<String, bool> statements,
    Map<String, String> answers,
  ) async {
    await request(
      '/me/compa/attestation',
      body: {
        'version': assessment.version,
        'sha256': assessment.sha256,
        'registry': assessment.registry.reference,
        'statements': statements,
        'answers': answers,
      },
    );
  }
}
