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

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsUpdateFailed =>
      'We could not update the notification. Try again.';

  @override
  String get notificationsAllFailed =>
      'We could not mark your notifications as read. Refresh to check their status.';

  @override
  String get notificationsAccount => 'Account';

  @override
  String get notificationsBooking => 'Booking';

  @override
  String notificationsBookingReference(String reference) {
    return 'Booking $reference';
  }

  @override
  String get notificationsRefresh => 'Refresh notifications';

  @override
  String get notificationsLoadFailed => 'We could not load your notifications';

  @override
  String get notificationsRetryMessage =>
      'Check your connection and try again.';

  @override
  String get notificationsRetry => 'Try again';

  @override
  String get notificationsHeading => 'Account and booking updates';

  @override
  String get notificationsDescription =>
      'Account and booking changes appear here. Email and phone notifications: under construction.';

  @override
  String notificationsUnread(int count) {
    return '$count unread in your inbox';
  }

  @override
  String get notificationsUpdating => 'Updating…';

  @override
  String get notificationsMarkAll => 'Mark all as read';

  @override
  String get notificationsCaughtUp => 'You are up to date';

  @override
  String get notificationsEmptyMessage =>
      'Future account and booking updates will appear here.';

  @override
  String get notificationsNew => 'New';

  @override
  String get notificationsMarkRead => 'Mark as read';

  @override
  String get notificationsViewAccount => 'View my account status';

  @override
  String get notificationsViewBookings => 'View my bookings';

  @override
  String get notificationsNewer => 'Newer';

  @override
  String get notificationsOlder => 'Older';

  @override
  String get plansTitle => 'Plans and subscription';

  @override
  String get plansEyebrow => 'At your pace';

  @override
  String get plansHeading => 'Start free. Grow at your pace.';

  @override
  String get plansDescription =>
      'A subscription expands your capacity to accept bookings as a Compa.';

  @override
  String get plansPending =>
      'Requests beyond your allowance remain pending. You choose which to confirm when capacity is available.';

  @override
  String get plansPaidTitle => 'More room to grow';

  @override
  String get plansFreeTitle => 'Free plan';

  @override
  String get plansPreparing => 'We are preparing subscriptions.';

  @override
  String get plansWeekly => '3 bookings per week';

  @override
  String get plansRequests =>
      'Receive requests without using your booking allowance.';

  @override
  String get plansConfirm => 'Confirm up to 3 bookings each week.';

  @override
  String get plansProfile =>
      'Publish your profile and manage your availability.';

  @override
  String get plansWeekRules =>
      'The allowance runs Monday to Sunday, using the activity date and Chilean time zone. Cancellation before the start restores the allowance; after the start, it remains used.';

  @override
  String get plansAcceptMore =>
      'Accept more bookings with an active subscription.';

  @override
  String get plansControl => 'Keep control of your pending requests.';

  @override
  String get plansPaymentDetails =>
      'Price, renewal and payment provider are being defined. Payments and subscription activation are not available yet. Your requests will not be accepted automatically.';

  @override
  String get plansPaymentsConstruction => 'Payments under construction';

  @override
  String get allowanceLoadFailed => 'We could not load your allowance';

  @override
  String get allowanceRetry => 'Retry allowance';

  @override
  String get allowanceRefresh => 'Refresh allowance';

  @override
  String get allowanceActive => 'Subscription active';

  @override
  String allowanceAvailable(int available, int limit) {
    return '$available of $limit free booking slots available';
  }

  @override
  String allowanceWeek(String date, int used) {
    return 'Week of $date · Chile · $used confirmed bookings';
  }

  @override
  String get allowanceSelectWeek => 'View another week';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileLoadFailed => 'We could not load your profile.';

  @override
  String get profileSaved => 'Your profile was saved';

  @override
  String get profileSaveFailed =>
      'We could not save your changes. They remain in the form; try again.';

  @override
  String get profilePhotoLoadFailed =>
      'We could not load your photo. You can try again.';

  @override
  String get profilePhotoTooLarge => 'The image must be no larger than 5 MB.';

  @override
  String get profilePhotoFormat => 'Choose a JPG or PNG photo.';

  @override
  String get profilePhotoInvalid =>
      'Choose a valid JPG or PNG image, between 32 and 4096 pixels per side and up to 12 megapixels.';

  @override
  String get profilePhotoBusy =>
      'Other photos are being processed. Try again in a few seconds.';

  @override
  String get profilePhotoSaveFailed =>
      'We could not confirm that your photo was saved. Try again.';

  @override
  String get profilePhotoConfirm => 'Confirm your photo';

  @override
  String get profilePhotoPreviewNote =>
      'The photo will be cropped to a square from the center. It will be public when your Compa profile is active.';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profilePhotoSave => 'Save photo';

  @override
  String get profilePhotoSaved => 'Your photo was saved';

  @override
  String get profilePhotoProcessFailed =>
      'We could not process the photo. Try again.';

  @override
  String get profilePhotoRemoveTitle => 'Remove your photo?';

  @override
  String get profilePhotoRemoveNote =>
      'Your profile will show your initial again.';

  @override
  String get profilePhotoKeep => 'Keep photo';

  @override
  String get profilePhotoRemove => 'Remove photo';

  @override
  String get profilePhotoRemoveFailed =>
      'We could not remove your photo. Try again.';

  @override
  String get profilePublicPreview => 'Public preview';

  @override
  String get profilePreviewTitle => 'This is how your introduction will look';

  @override
  String get profilePreviewNote =>
      'This preview includes your unsaved changes. It does not publish or activate your Compa profile.';

  @override
  String get profileNameValidation => 'Enter at least two characters';

  @override
  String get profilePhoneValidation => 'Enter a valid phone number';

  @override
  String get profileInterestsValidation =>
      'At most 15 interests of 40 characters each';

  @override
  String get profileRetryMessage => 'Try again.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get profileAccount => 'Your account';

  @override
  String get profileHeading => 'Make your profile your own';

  @override
  String get profileDescription =>
      'Tell us your name and what you enjoy doing.';

  @override
  String get profileBaseRole => 'Member';

  @override
  String get profileCompaRole => 'Compa';

  @override
  String get profileAdminRole => 'Administrator';

  @override
  String get profilePhotoProcessing => 'Processing photo…';

  @override
  String get profilePhotoChange => 'Change photo';

  @override
  String get profilePhotoHelp =>
      'Your photo and biography will be public when your Compa profile is active. JPG or PNG, up to 5 MB. The photo is saved separately.';

  @override
  String get profileName => 'Display name';

  @override
  String get profileNameHelp =>
      'This name appears on your Compa profile and bookings.';

  @override
  String get profileBiography => 'Public biography (optional)';

  @override
  String get profileBiographyHelp =>
      'Describe what you enjoy sharing. Avoid including private contact details.';

  @override
  String get profileEmail => 'Sign-in email';

  @override
  String get profileEmailHelp => 'Managed by your sign-in account.';

  @override
  String get profileContact => 'Contact details';

  @override
  String get profileContactHelp =>
      'These are optional. Your phone number and general location are not shown in the public catalogue.';

  @override
  String get profilePhone => 'Phone (optional)';

  @override
  String get profileCountry => 'Country (optional)';

  @override
  String get profileRegion => 'Region (optional)';

  @override
  String get profileCity => 'City (optional)';

  @override
  String get profileInterests => 'Your interests (optional)';

  @override
  String get profileInterestsHelp =>
      'Separate them with commas. For example: cinema, hiking, video games.';

  @override
  String get profileSaving => 'Saving…';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileDiscard => 'Discard changes';

  @override
  String get profileUnsaved => 'You have unsaved changes.';

  @override
  String get profileBookings => 'View my bookings';

  @override
  String get publicProfileName => 'Your display name';

  @override
  String get publicProfileTagline =>
      'A shared interest. A plan to enjoy together.';

  @override
  String get publicProfileAbout => 'About me';

  @override
  String get publicProfileEmptyBiography => 'There is no biography yet.';

  @override
  String get publicProfileInterests => 'I enjoy';

  @override
  String publicProfilePhotoLabel(String name) {
    return 'Photo of $name';
  }

  @override
  String get timeOffTitle => 'My days off';

  @override
  String get timeOffRefresh => 'Refresh days off';

  @override
  String get timeOffHeading => 'A break in your schedule';

  @override
  String get timeOffDescription =>
      'Block full days for holidays or other commitments. Dates use your schedule time zone. The last day is included.';

  @override
  String timeOffDescriptionWithZone(String zone) {
    return 'Block full days for holidays or other commitments. Dates use your schedule time zone: $zone. The last day is included.';
  }

  @override
  String get timeOffReservationsHelp =>
      'Existing bookings are not cancelled. Resolve pending or confirmed bookings before blocking that period.';

  @override
  String get timeOffForbidden => 'You can only manage your own schedule.';

  @override
  String get timeOffLoadFailed => 'We could not load your days off. Try again.';

  @override
  String get timeOffConflict =>
      'The period overlaps a booking or another block. Your bookings are unchanged.';

  @override
  String get timeOffSaveFailed =>
      'We could not save the change. Check the dates and try again.';

  @override
  String get timeOffTooLong => 'You can block up to 366 days per period.';

  @override
  String get timeOffPickerHelp => 'Unavailable days';

  @override
  String get timeOffPickerSave => 'Block days';

  @override
  String get timeOffRemoveTitle => 'Make these days available again?';

  @override
  String timeOffRemoveMessage(String start, String end) {
    return 'The block from $start to $end will be removed. Your weekly schedule is unchanged.';
  }

  @override
  String get timeOffKeep => 'Keep block';

  @override
  String get timeOffRemove => 'Remove block';

  @override
  String get timeOffRetry => 'Try again';

  @override
  String get timeOffSaving => 'Saving…';

  @override
  String get timeOffAdd => 'Add days off';

  @override
  String get timeOffEmpty =>
      'You have no current blocks. Your weekly availability applies.';

  @override
  String timeOffFullDays(String zone) {
    return 'Full days · $zone';
  }
}
