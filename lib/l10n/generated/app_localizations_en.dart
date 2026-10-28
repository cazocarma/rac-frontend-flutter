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

  @override
  String get documentHistoryTitle => 'Acceptance history';

  @override
  String get documentHistoryEmpty =>
      'You have not recorded any acceptances yet.';

  @override
  String get documentHistoryFailed =>
      'We could not load your history. You can try again.';

  @override
  String get documentHistoryMore => 'Load more';

  @override
  String get documentHistoryRetry => 'Try again';

  @override
  String get documentHistoryAccount => 'Account';

  @override
  String get documentHistoryOnboarding => 'Compa onboarding';

  @override
  String get documentHistoryBooking => 'Booking';

  @override
  String documentHistoryAt(String date, String context) {
    return 'Accepted: $date · $context';
  }

  @override
  String get compaPrerequisitesPending =>
      'Complete the pending documents and rules, then activate your profile again. Your edits are preserved.';

  @override
  String get staffTitle => 'Management console';

  @override
  String get staffAccess => 'Team access';

  @override
  String get staffAccessHelp =>
      'Use your team account and second authentication factor.';

  @override
  String get staffSignIn => 'Sign in with MFA';

  @override
  String get staffSignOut => 'Sign out of team session';

  @override
  String get staffUnavailable =>
      'We could not validate access. Retry or sign in again.';

  @override
  String get staffDenied => 'This account cannot access the console.';

  @override
  String get staffReady => 'Team session verified';

  @override
  String get staffRetry => 'Retry';

  @override
  String get staffPending => 'Editorial tools are under construction.';

  @override
  String get staffReadRevision => 'Read exact revision';

  @override
  String get staffResource => 'Resource type';

  @override
  String get staffDocument => 'Document';

  @override
  String get staffAssessment => 'Private assessment';

  @override
  String get staffReference => 'Revision identifier (UUID)';

  @override
  String get staffRevisionUnavailable =>
      'We could not read this revision. Check its identifier and your access.';

  @override
  String get staffConfirmDecision => 'Confirm decision';

  @override
  String get staffCancel => 'Cancel';

  @override
  String get staffApprove => 'Approve revision';

  @override
  String get staffReject => 'Reject revision';

  @override
  String get staffPublish => 'Publish revision';

  @override
  String get staffReadAcknowledgement =>
      'I reviewed the complete content and its exact version.';

  @override
  String get staffDecisionFailed =>
      'We could not complete the operation. Pending commands remain available for review.';

  @override
  String get staffDecisionCompleted =>
      'Operation confirmed. Read the revision again to view its current state.';

  @override
  String get staffPendingRecovery =>
      'Commands await confirmation. Retry the same command or authenticate again.';

  @override
  String get staffRetrySameCommand => 'Retry the same command';

  @override
  String get staffCreateDraft => 'Create document draft';

  @override
  String get staffConfirmDraft => 'Confirm draft';

  @override
  String get staffDraftHelp =>
      'Drafts are immutable. Another person must review them before publication; creating a draft does not activate new obligations.';

  @override
  String get staffDocumentKind => 'Document';

  @override
  String get staffClientTerms => 'Client terms';

  @override
  String get staffCompaTerms => 'Compa terms';

  @override
  String get staffCommunityRules => 'Community rules';

  @override
  String get staffPrivacy => 'Privacy';

  @override
  String get staffSafetyRules => 'Safety rules';

  @override
  String get staffVersion => 'Version';

  @override
  String get staffLocale => 'Language';

  @override
  String get staffMaterialChange => 'Does acceptance need to be renewed?';

  @override
  String get staffMaterialYes => 'Yes, material change';

  @override
  String get staffMaterialNo => 'No, non-material change';

  @override
  String get staffDocumentContent => 'Complete text';

  @override
  String get staffDraftInvalid =>
      'Check selections, version and text. The limit is 128 KiB of UTF-8 text.';

  @override
  String get staffCreateAssessment => 'Create private assessment';

  @override
  String get staffConfirmAssessment => 'Confirm assessment';

  @override
  String get staffPrivateAssessmentHelp =>
      'Include five commitments and three questions. Explicitly select correct answers. The answer key is private and the server computes the revision hash.';

  @override
  String get staffNoSubstances => 'Commitment about illicit substances';

  @override
  String get staffNoSexualServices => 'Commitment about sexual services';

  @override
  String get staffCatalogOnly => 'Commitment about permitted activities';

  @override
  String get staffAdultsOnly => 'Adult age commitment';

  @override
  String get staffEnforcement => 'Commitment about enforcement and appeals';

  @override
  String get staffQuestion => 'Question';

  @override
  String get staffOption => 'Option';

  @override
  String get staffCorrectOption => 'Correct answer';

  @override
  String get staffAddOption => 'Add option';

  @override
  String get staffRemoveOption => 'Remove last option';

  @override
  String get staffAssessmentInvalid =>
      'Complete commitments, questions, options and correct answers. Also check version and language.';
}
