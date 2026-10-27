import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @updatedRules.
  ///
  /// In es, this message translates to:
  /// **'Actualizamos nuestras reglas'**
  String get updatedRules;

  /// No description provided for @readDocuments.
  ///
  /// In es, this message translates to:
  /// **'Revisa las versiones pendientes antes de continuar. La operación original no se repetirá automáticamente.'**
  String get readDocuments;

  /// No description provided for @acceptContinue.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get acceptContinue;

  /// No description provided for @explicitConsent.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto las versiones indicadas.'**
  String get explicitConsent;

  /// No description provided for @readFullText.
  ///
  /// In es, this message translates to:
  /// **'Leer texto completo'**
  String get readFullText;

  /// No description provided for @readDone.
  ///
  /// In es, this message translates to:
  /// **'He leído esta versión'**
  String get readDone;

  /// No description provided for @savingConsent.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get savingConsent;

  /// No description provided for @documentsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las versiones pendientes. Vuelve a la acción original para actualizarlas.'**
  String get documentsUnavailable;

  /// No description provided for @consentFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar la aceptación. Puedes reintentar.'**
  String get consentFailed;

  /// No description provided for @documentsChanged.
  ///
  /// In es, this message translates to:
  /// **'Los documentos cambiaron. Vuelve a la acción original para revisar las versiones vigentes.'**
  String get documentsChanged;

  /// No description provided for @backToAction.
  ///
  /// In es, this message translates to:
  /// **'Volver a la acción'**
  String get backToAction;

  /// No description provided for @privacyEscape.
  ///
  /// In es, this message translates to:
  /// **'Ver mis datos o eliminar mi cuenta'**
  String get privacyEscape;

  /// No description provided for @privacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus datos y derechos'**
  String get privacyTitle;

  /// No description provided for @privacyPending.
  ///
  /// In es, this message translates to:
  /// **'En construcción: las solicitudes de exportación y eliminación aún no están disponibles. No hemos enviado ninguna solicitud. Puedes consultar tu perfil sin aceptar documentos.'**
  String get privacyPending;

  /// No description provided for @viewProfile.
  ///
  /// In es, this message translates to:
  /// **'Ver mis datos de perfil'**
  String get viewProfile;

  /// No description provided for @pendingVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String pendingVersion(String version);

  /// No description provided for @documentReadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esta versión exacta. Inténtalo nuevamente.'**
  String get documentReadFailed;

  /// No description provided for @compaRulesTitle.
  ///
  /// In es, this message translates to:
  /// **'Reglas para ser compa'**
  String get compaRulesTitle;

  /// No description provided for @compaRulesIntro.
  ///
  /// In es, this message translates to:
  /// **'Revisa cada declaración y responde las tres situaciones. Aprobar este paso no publica tu perfil ni verifica tu identidad.'**
  String get compaRulesIntro;

  /// No description provided for @compaRulesReview.
  ///
  /// In es, this message translates to:
  /// **'Revisar reglas y cuestionario'**
  String get compaRulesReview;

  /// No description provided for @compaRulesSubmit.
  ///
  /// In es, this message translates to:
  /// **'Confirmar declaraciones y respuestas'**
  String get compaRulesSubmit;

  /// No description provided for @compaRulesPassed.
  ///
  /// In es, this message translates to:
  /// **'Ya completaste esta versión del cuestionario.'**
  String get compaRulesPassed;

  /// No description provided for @compaRulesUnavailable.
  ///
  /// In es, this message translates to:
  /// **'En construcción: todavía no hay un cuestionario revisado disponible para tu cuenta o no pudimos cargarlo.'**
  String get compaRulesUnavailable;

  /// No description provided for @compaRulesRetry.
  ///
  /// In es, this message translates to:
  /// **'Volver a cargar'**
  String get compaRulesRetry;

  /// No description provided for @compaRulesWrong.
  ///
  /// In es, this message translates to:
  /// **'Revisa las tres situaciones. Todas deben responderse correctamente.'**
  String get compaRulesWrong;

  /// No description provided for @compaRulesDeclarations.
  ///
  /// In es, this message translates to:
  /// **'Marca cada declaración por separado antes de continuar.'**
  String get compaRulesDeclarations;

  /// No description provided for @compaRulesChanged.
  ///
  /// In es, this message translates to:
  /// **'La versión cambió. Vuelve a cargar el cuestionario y revisa todas las declaraciones nuevamente.'**
  String get compaRulesChanged;

  /// No description provided for @compaRulesFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tus respuestas. Se conservan para que puedas reintentar.'**
  String get compaRulesFailed;

  /// No description provided for @compaRulesContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get compaRulesContinue;

  /// No description provided for @compaRulesSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get compaRulesSaving;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
