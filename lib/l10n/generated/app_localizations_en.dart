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
      'We could not complete the operation. Check your access or try again.';

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

  @override
  String get staffActivateBundle => 'Activate document bundle';

  @override
  String get staffPrepareActivation => 'Read and prepare activation';

  @override
  String get staffConfirmActivation => 'Confirm bundle activation';

  @override
  String get staffRegistryVersion => 'Bundle version';

  @override
  String get staffActivationHelp =>
      'Five reviewed and published documents and one assessment will become active. The server supplies the current version; if it changes before confirmation, review and prepare the bundle again.';

  @override
  String get staffActivationSummary =>
      'Change summary (up to three lines, optional)';

  @override
  String get staffActivationInvalid =>
      'We could not prepare this bundle. Check references, language, publications and summary; read again before confirming.';

  @override
  String get staffStepUpRequired =>
      'Your security verification expired. Sign in with MFA again to continue with the same command.';

  @override
  String get compaTitle => 'Become a Compa';

  @override
  String get compaAddAvailability =>
      'Add at least one time window to receive bookings.';

  @override
  String get compaPublished => 'Your Compa profile was saved successfully.';

  @override
  String get compaSessionPending =>
      'Your profile was saved, but we could not update your session permissions. Select Refresh session to continue.';

  @override
  String get compaSaveFailed =>
      'We could not save your profile. Check your connection and try again. Your previous changes are preserved.';

  @override
  String get compaWindowsLimit => 'Up to 3 time windows per day.';

  @override
  String get compaWindowFormat => 'Use HH:mm-HH:mm, for example 18:00-22:00.';

  @override
  String get compaWindowsOverlap =>
      'Check the order and avoid overlapping times.';

  @override
  String get compaLoadFailed => 'We could not load your profile';

  @override
  String get compaConnectionRetry => 'Check your connection and try again.';

  @override
  String get compaRetry => 'Retry';

  @override
  String get compaProfileHeading => 'Your Compa profile';

  @override
  String get compaStartHeading => 'Share what you enjoy doing';

  @override
  String get compaPublishingInfo =>
      'Set up the activities you offer and your availability. Review the rules and documents before continuing.';

  @override
  String get compaAboutLabel => 'Tell us about yourself';

  @override
  String get compaAboutHint =>
      'The activities you offer and what spending time with you will be like';

  @override
  String get compaAboutShort =>
      'Tell us a little more: at least 20 characters.';

  @override
  String get compaRateLabel => 'Hourly rate (CLP)';

  @override
  String get compaRateHelp =>
      'Reference amount. Payments are under construction.';

  @override
  String get compaRateInvalid =>
      'Enter a valid amount with up to 2 decimal places.';

  @override
  String get compaSkillsLabel => 'Skills';

  @override
  String get compaSkillsHint => 'barbecue, movies, running';

  @override
  String get compaSkillsHelp => 'Separate with commas. Between 1 and 8 skills.';

  @override
  String get compaSkillsInvalid =>
      'Add 1 to 8 skills, each between 2 and 40 characters.';

  @override
  String get compaAvailabilityHeading => 'Your weekly availability';

  @override
  String get compaAvailabilityHelp =>
      'Enter times in your time zone. Leave a day blank if you are unavailable. Add up to 3 comma-separated windows; for example 15:00-18:00, 20:00-23:00. Existing bookings keep their date and time.';

  @override
  String get compaTimeZone => 'Time zone';

  @override
  String get compaSaving => 'Saving…';

  @override
  String get compaSaveChanges => 'Save changes';

  @override
  String get compaActivateProfile => 'Publish my profile';

  @override
  String get compaLoginFailed => 'We could not open sign-in. Try again.';

  @override
  String get compaRefreshSession => 'Refresh session';

  @override
  String get compaOpenAgenda => 'Open my schedule';

  @override
  String get compaMonday => 'Monday';

  @override
  String get compaTuesday => 'Tuesday';

  @override
  String get compaWednesday => 'Wednesday';

  @override
  String get compaThursday => 'Thursday';

  @override
  String get compaFriday => 'Friday';

  @override
  String get compaSaturday => 'Saturday';

  @override
  String get compaSunday => 'Sunday';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsHeading => 'Your way';

  @override
  String get settingsDescription => 'Customize how RAC looks on this device.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSystem => 'Use device settings';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsDocuments => 'Documents and agreements';

  @override
  String get settingsDocumentsHelp => 'View versions and your acceptances.';

  @override
  String get commonConstruction => 'Under construction';

  @override
  String get settingsPending =>
      'Notification, privacy and language preferences.';

  @override
  String get navExplore => 'Explore';

  @override
  String get navBookings => 'My bookings';

  @override
  String get navMessages => 'Messages';

  @override
  String get navPayments => 'Plans and payments';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'My profile';

  @override
  String get navTagline => 'Time to share.';

  @override
  String get navSpace => 'YOUR SPACE';

  @override
  String get navAdmin => 'Administration';

  @override
  String get navShare => 'Share what you enjoy';

  @override
  String get navProfileInfo =>
      'Set up your profile and availability to share activities.';

  @override
  String get navLogout => 'Sign out';

  @override
  String get navExploreTitle => 'Explore Compas';

  @override
  String get navOpenNotifications => 'View notifications';

  @override
  String get navBookingsShort => 'Bookings';

  @override
  String get navProfileShort => 'Profile';

  @override
  String get accessFailed => 'We could not sign you in. Try again.';

  @override
  String get accessStory => 'The best plans\nare shared.';

  @override
  String get accessStoryHelp =>
      'A walk, a coffee or something new.\nFind someone to enjoy it with.';

  @override
  String get accessBrandLine => 'RENT-A-COMPA · GOOD COMPANY';

  @override
  String get accessHeading => 'Your next plan\nstarts here.';

  @override
  String get accessDescription =>
      'Meet Compas, find shared interests and make time to spend together.';

  @override
  String get accessMovies => 'Movies';

  @override
  String get accessRunning => 'Running';

  @override
  String get accessKaraoke => 'Karaoke';

  @override
  String get accessOpening => 'Opening sign-in…';

  @override
  String get accessContinue => 'Sign in or create an account';

  @override
  String get accessReturn =>
      'After signing in, you will return automatically to RAC.';

  @override
  String get documentTermsClient => 'Client terms';

  @override
  String get documentTermsCompa => 'Compa terms';

  @override
  String get documentCommunity => 'Community rules';

  @override
  String get documentPrivacy => 'Privacy';

  @override
  String get documentSafety => 'Safety rules';

  @override
  String get documentGeneric => 'Document';

  @override
  String get documentsLoadFailed => 'We could not load the documents';

  @override
  String get documentsRetryLater => 'Try again in a moment.';

  @override
  String get documentsRetry => 'Retry';

  @override
  String get documentsPendingReview =>
      'Documents will be available once their review is complete.';

  @override
  String get documentsAccount => 'Your account';

  @override
  String get documentsHeading => 'Information and agreements';

  @override
  String get documentsDescription =>
      'View each version and check which ones you have accepted.';

  @override
  String get documentsNotAccepted => 'Not accepted';

  @override
  String get documentsAccepted => 'Accepted';

  @override
  String get readerDocumentsChanged =>
      'The documents changed. Return to the list to refresh them.';

  @override
  String get documentsAcceptFailed =>
      'We could not confirm acceptance. You can retry.';

  @override
  String get documentsOpenFailed => 'We could not open this version';

  @override
  String get documentsReturnRefresh =>
      'Try again or return to the list to refresh it.';

  @override
  String get documentsAlreadyAccepted =>
      'You have already accepted this version.';

  @override
  String get documentsConsent => 'I accept this version of the document.';

  @override
  String get documentsConfirm => 'Confirm acceptance';

  @override
  String documentVersion(String version) {
    return 'Version $version';
  }

  @override
  String documentsVersionStatus(String version, String status) {
    return 'Version $version · $status';
  }
}
