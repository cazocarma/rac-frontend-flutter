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

  /// No description provided for @documentHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de aceptaciones'**
  String get documentHistoryTitle;

  /// No description provided for @documentHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado aceptaciones.'**
  String get documentHistoryEmpty;

  /// No description provided for @documentHistoryFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el historial. Puedes reintentar.'**
  String get documentHistoryFailed;

  /// No description provided for @documentHistoryMore.
  ///
  /// In es, this message translates to:
  /// **'Cargar más'**
  String get documentHistoryMore;

  /// No description provided for @documentHistoryRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get documentHistoryRetry;

  /// No description provided for @documentHistoryAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get documentHistoryAccount;

  /// No description provided for @documentHistoryOnboarding.
  ///
  /// In es, this message translates to:
  /// **'Registro como compa'**
  String get documentHistoryOnboarding;

  /// No description provided for @documentHistoryBooking.
  ///
  /// In es, this message translates to:
  /// **'Reserva'**
  String get documentHistoryBooking;

  /// No description provided for @documentHistoryAt.
  ///
  /// In es, this message translates to:
  /// **'Aceptado: {date} · {context}'**
  String documentHistoryAt(String date, String context);

  /// No description provided for @compaPrerequisitesPending.
  ///
  /// In es, this message translates to:
  /// **'Completa los documentos y reglas pendientes. Luego vuelve a activar tu perfil; conservamos lo que escribiste.'**
  String get compaPrerequisitesPending;

  /// No description provided for @staffTitle.
  ///
  /// In es, this message translates to:
  /// **'Consola de gestión'**
  String get staffTitle;

  /// No description provided for @staffAccess.
  ///
  /// In es, this message translates to:
  /// **'Acceso del equipo'**
  String get staffAccess;

  /// No description provided for @staffAccessHelp.
  ///
  /// In es, this message translates to:
  /// **'Usa tu cuenta del equipo y el segundo factor de autenticación.'**
  String get staffAccessHelp;

  /// No description provided for @staffSignIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con MFA'**
  String get staffSignIn;

  /// No description provided for @staffSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión del equipo'**
  String get staffSignOut;

  /// No description provided for @staffUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos validar el acceso. Reintenta o inicia sesión nuevamente.'**
  String get staffUnavailable;

  /// No description provided for @staffDenied.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta no tiene acceso a la consola.'**
  String get staffDenied;

  /// No description provided for @staffReady.
  ///
  /// In es, this message translates to:
  /// **'Sesión del equipo validada'**
  String get staffReady;

  /// No description provided for @staffRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get staffRetry;

  /// No description provided for @staffPending.
  ///
  /// In es, this message translates to:
  /// **'Las herramientas editoriales están en construcción.'**
  String get staffPending;

  /// No description provided for @staffReadRevision.
  ///
  /// In es, this message translates to:
  /// **'Consultar revisión exacta'**
  String get staffReadRevision;

  /// No description provided for @staffResource.
  ///
  /// In es, this message translates to:
  /// **'Tipo de recurso'**
  String get staffResource;

  /// No description provided for @staffDocument.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get staffDocument;

  /// No description provided for @staffAssessment.
  ///
  /// In es, this message translates to:
  /// **'Cuestionario privado'**
  String get staffAssessment;

  /// No description provided for @staffReference.
  ///
  /// In es, this message translates to:
  /// **'Identificador de revisión (UUID)'**
  String get staffReference;

  /// No description provided for @staffRevisionUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar esta revisión. Comprueba el identificador y tu acceso.'**
  String get staffRevisionUnavailable;

  /// No description provided for @staffConfirmDecision.
  ///
  /// In es, this message translates to:
  /// **'Confirmar decisión'**
  String get staffConfirmDecision;

  /// No description provided for @staffCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get staffCancel;

  /// No description provided for @staffApprove.
  ///
  /// In es, this message translates to:
  /// **'Aprobar revisión'**
  String get staffApprove;

  /// No description provided for @staffReject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar revisión'**
  String get staffReject;

  /// No description provided for @staffPublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar revisión'**
  String get staffPublish;

  /// No description provided for @staffReadAcknowledgement.
  ///
  /// In es, this message translates to:
  /// **'He revisado el contenido completo y su versión exacta.'**
  String get staffReadAcknowledgement;

  /// No description provided for @staffDecisionFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la operación. Conservamos los comandos pendientes para su revisión.'**
  String get staffDecisionFailed;

  /// No description provided for @staffDecisionCompleted.
  ///
  /// In es, this message translates to:
  /// **'Operación confirmada. Consulta la revisión para ver su estado actualizado.'**
  String get staffDecisionCompleted;

  /// No description provided for @staffPendingRecovery.
  ///
  /// In es, this message translates to:
  /// **'Hay comandos pendientes de confirmar. Reintenta el mismo comando o vuelve a autenticarte.'**
  String get staffPendingRecovery;

  /// No description provided for @staffRetrySameCommand.
  ///
  /// In es, this message translates to:
  /// **'Reintentar el mismo comando'**
  String get staffRetrySameCommand;

  /// No description provided for @staffCreateDraft.
  ///
  /// In es, this message translates to:
  /// **'Crear borrador de documento'**
  String get staffCreateDraft;

  /// No description provided for @staffConfirmDraft.
  ///
  /// In es, this message translates to:
  /// **'Confirmar borrador'**
  String get staffConfirmDraft;

  /// No description provided for @staffDraftHelp.
  ///
  /// In es, this message translates to:
  /// **'El borrador es inmutable. Requiere revisión de otra persona antes de publicarse; crearlo no activa nuevas obligaciones.'**
  String get staffDraftHelp;

  /// No description provided for @staffDocumentKind.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get staffDocumentKind;

  /// No description provided for @staffClientTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos para clientes'**
  String get staffClientTerms;

  /// No description provided for @staffCompaTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos para Compas'**
  String get staffCompaTerms;

  /// No description provided for @staffCommunityRules.
  ///
  /// In es, this message translates to:
  /// **'Normas de comunidad'**
  String get staffCommunityRules;

  /// No description provided for @staffPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get staffPrivacy;

  /// No description provided for @staffSafetyRules.
  ///
  /// In es, this message translates to:
  /// **'Normas de seguridad'**
  String get staffSafetyRules;

  /// No description provided for @staffVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get staffVersion;

  /// No description provided for @staffLocale.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get staffLocale;

  /// No description provided for @staffMaterialChange.
  ///
  /// In es, this message translates to:
  /// **'¿Requiere renovar la aceptación?'**
  String get staffMaterialChange;

  /// No description provided for @staffMaterialYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, cambio material'**
  String get staffMaterialYes;

  /// No description provided for @staffMaterialNo.
  ///
  /// In es, this message translates to:
  /// **'No, cambio no material'**
  String get staffMaterialNo;

  /// No description provided for @staffDocumentContent.
  ///
  /// In es, this message translates to:
  /// **'Texto completo'**
  String get staffDocumentContent;

  /// No description provided for @staffDraftInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa las selecciones, la versión y el texto. El máximo es 128 KiB de texto UTF-8.'**
  String get staffDraftInvalid;

  /// No description provided for @staffCreateAssessment.
  ///
  /// In es, this message translates to:
  /// **'Crear cuestionario privado'**
  String get staffCreateAssessment;

  /// No description provided for @staffConfirmAssessment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cuestionario'**
  String get staffConfirmAssessment;

  /// No description provided for @staffPrivateAssessmentHelp.
  ///
  /// In es, this message translates to:
  /// **'Incluye cinco compromisos y tres preguntas. Selecciona explícitamente las respuestas correctas. La clave es privada y el servidor calcula el hash de la revisión.'**
  String get staffPrivateAssessmentHelp;

  /// No description provided for @staffNoSubstances.
  ///
  /// In es, this message translates to:
  /// **'Compromiso sobre sustancias ilícitas'**
  String get staffNoSubstances;

  /// No description provided for @staffNoSexualServices.
  ///
  /// In es, this message translates to:
  /// **'Compromiso sobre servicios sexuales'**
  String get staffNoSexualServices;

  /// No description provided for @staffCatalogOnly.
  ///
  /// In es, this message translates to:
  /// **'Compromiso sobre actividades permitidas'**
  String get staffCatalogOnly;

  /// No description provided for @staffAdultsOnly.
  ///
  /// In es, this message translates to:
  /// **'Compromiso de mayoría de edad'**
  String get staffAdultsOnly;

  /// No description provided for @staffEnforcement.
  ///
  /// In es, this message translates to:
  /// **'Compromiso sobre medidas y apelación'**
  String get staffEnforcement;

  /// No description provided for @staffQuestion.
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get staffQuestion;

  /// No description provided for @staffOption.
  ///
  /// In es, this message translates to:
  /// **'Alternativa'**
  String get staffOption;

  /// No description provided for @staffCorrectOption.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta'**
  String get staffCorrectOption;

  /// No description provided for @staffAddOption.
  ///
  /// In es, this message translates to:
  /// **'Agregar alternativa'**
  String get staffAddOption;

  /// No description provided for @staffRemoveOption.
  ///
  /// In es, this message translates to:
  /// **'Quitar última alternativa'**
  String get staffRemoveOption;

  /// No description provided for @staffAssessmentInvalid.
  ///
  /// In es, this message translates to:
  /// **'Completa los compromisos, preguntas, alternativas y respuestas correctas. Revisa también versión e idioma.'**
  String get staffAssessmentInvalid;
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
