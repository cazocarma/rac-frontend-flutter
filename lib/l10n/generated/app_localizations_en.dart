// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get updatedRules => 'We updated our rules';

  @override
  String get readDocuments =>
      'Review the pending versions before continuing. Your original operation will not be repeated automatically.';

  @override
  String get acceptContinue => 'Accept and continue';

  @override
  String get explicitConsent => 'I have read and accept the listed versions.';

  @override
  String get readFullText => 'Read full text';

  @override
  String get readDone => 'I have read this version';

  @override
  String get savingConsent => 'Saving…';

  @override
  String get documentsUnavailable =>
      'We could not load the pending versions. Return to the original action to update them.';

  @override
  String get consentFailed =>
      'We could not save your acceptance. You can try again.';

  @override
  String get documentsChanged =>
      'The documents changed. Return to the original action to review the current versions.';

  @override
  String get backToAction => 'Return to action';

  @override
  String get privacyEscape => 'View my data or delete my account';

  @override
  String get privacyTitle => 'Your data and rights';

  @override
  String get privacyPending =>
      'Under construction: export and deletion requests are not available yet. No request has been submitted. You can view your profile without accepting documents.';

  @override
  String get viewProfile => 'View my profile data';

  @override
  String pendingVersion(String version) {
    return 'Version $version';
  }

  @override
  String get documentReadFailed =>
      'We could not open this exact version. Please try again.';

  @override
  String get compaRulesTitle => 'Rules for becoming a compa';

  @override
  String get compaRulesIntro =>
      'Review each declaration and answer the three scenarios. Passing this step does not publish your profile or verify your identity.';

  @override
  String get compaRulesReview => 'Review rules and questionnaire';

  @override
  String get compaRulesSubmit => 'Confirm declarations and answers';

  @override
  String get compaRulesPassed =>
      'You have already completed this questionnaire version.';

  @override
  String get compaRulesUnavailable =>
      'Under construction: no reviewed questionnaire is available for your account yet, or we could not load it.';

  @override
  String get compaRulesRetry => 'Reload';

  @override
  String get compaRulesWrong =>
      'Review the three scenarios. Every answer must be correct.';

  @override
  String get compaRulesDeclarations =>
      'Confirm each declaration separately before continuing.';

  @override
  String get compaRulesChanged =>
      'The version changed. Reload the questionnaire and review every declaration again.';

  @override
  String get compaRulesFailed =>
      'We could not save your answers. They are preserved so you can try again.';

  @override
  String get compaRulesContinue => 'Continue';

  @override
  String get compaRulesSaving => 'Saving…';
}
