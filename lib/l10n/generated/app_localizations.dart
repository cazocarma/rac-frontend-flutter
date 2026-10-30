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
  /// **'No pudimos completar la operación. Revisa tu acceso o vuelve a intentarlo.'**
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

  /// No description provided for @staffActivateBundle.
  ///
  /// In es, this message translates to:
  /// **'Activar conjunto de documentos'**
  String get staffActivateBundle;

  /// No description provided for @staffPrepareActivation.
  ///
  /// In es, this message translates to:
  /// **'Consultar y preparar activación'**
  String get staffPrepareActivation;

  /// No description provided for @staffConfirmActivation.
  ///
  /// In es, this message translates to:
  /// **'Confirmar activación del conjunto'**
  String get staffConfirmActivation;

  /// No description provided for @staffRegistryVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión del conjunto'**
  String get staffRegistryVersion;

  /// No description provided for @staffActivationHelp.
  ///
  /// In es, this message translates to:
  /// **'Se activarán cinco documentos y un cuestionario ya revisados y publicados. La versión se consulta al servidor; si cambia antes de confirmar, debes revisar y preparar nuevamente el conjunto.'**
  String get staffActivationHelp;

  /// No description provided for @staffActivationSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de cambios (hasta tres líneas, opcional)'**
  String get staffActivationSummary;

  /// No description provided for @staffActivationInvalid.
  ///
  /// In es, this message translates to:
  /// **'No pudimos preparar este conjunto. Revisa referencias, idioma, publicaciones y resumen; vuelve a consultar antes de confirmar.'**
  String get staffActivationInvalid;

  /// No description provided for @staffStepUpRequired.
  ///
  /// In es, this message translates to:
  /// **'Tu verificación de seguridad venció. Ingresa nuevamente con MFA para continuar con el mismo comando.'**
  String get staffStepUpRequired;

  /// No description provided for @compaTitle.
  ///
  /// In es, this message translates to:
  /// **'Sé Compa'**
  String get compaTitle;

  /// No description provided for @compaAddAvailability.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un horario para recibir reservas.'**
  String get compaAddAvailability;

  /// No description provided for @compaPublished.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil compa se guardó correctamente.'**
  String get compaPublished;

  /// No description provided for @compaSessionPending.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil se guardó, pero no pudimos actualizar los permisos de tu sesión. Pulsa Actualizar sesión para continuar.'**
  String get compaSessionPending;

  /// No description provided for @compaSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu perfil. Revisa tu conexión e inténtalo nuevamente. Tus cambios anteriores se conservan.'**
  String get compaSaveFailed;

  /// No description provided for @compaWindowsLimit.
  ///
  /// In es, this message translates to:
  /// **'Hasta 3 franjas por día.'**
  String get compaWindowsLimit;

  /// No description provided for @compaWindowFormat.
  ///
  /// In es, this message translates to:
  /// **'Usa HH:mm-HH:mm, por ejemplo 18:00-22:00.'**
  String get compaWindowFormat;

  /// No description provided for @compaWindowsOverlap.
  ///
  /// In es, this message translates to:
  /// **'Revisa el orden y evita horarios superpuestos.'**
  String get compaWindowsOverlap;

  /// No description provided for @compaLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu perfil'**
  String get compaLoadFailed;

  /// No description provided for @compaConnectionRetry.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo nuevamente.'**
  String get compaConnectionRetry;

  /// No description provided for @compaRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get compaRetry;

  /// No description provided for @compaProfileHeading.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil como compa'**
  String get compaProfileHeading;

  /// No description provided for @compaStartHeading.
  ///
  /// In es, this message translates to:
  /// **'Comparte lo que te gusta hacer'**
  String get compaStartHeading;

  /// No description provided for @compaPublishingInfo.
  ///
  /// In es, this message translates to:
  /// **'Configura las actividades que ofreces y tus horarios. Revisa las reglas y los documentos antes de continuar.'**
  String get compaPublishingInfo;

  /// No description provided for @compaAboutLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos sobre ti'**
  String get compaAboutLabel;

  /// No description provided for @compaAboutHint.
  ///
  /// In es, this message translates to:
  /// **'Qué actividades ofreces y cómo será compartir contigo'**
  String get compaAboutHint;

  /// No description provided for @compaAboutShort.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos un poco más: al menos 20 caracteres.'**
  String get compaAboutShort;

  /// No description provided for @compaRateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tarifa por hora (CLP)'**
  String get compaRateLabel;

  /// No description provided for @compaRateHelp.
  ///
  /// In es, this message translates to:
  /// **'Valor referencial. Los cobros están en construcción.'**
  String get compaRateHelp;

  /// No description provided for @compaRateInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido, con hasta 2 decimales.'**
  String get compaRateInvalid;

  /// No description provided for @compaSkillsLabel.
  ///
  /// In es, this message translates to:
  /// **'Habilidades'**
  String get compaSkillsLabel;

  /// No description provided for @compaSkillsHint.
  ///
  /// In es, this message translates to:
  /// **'asado, cine, running'**
  String get compaSkillsHint;

  /// No description provided for @compaSkillsHelp.
  ///
  /// In es, this message translates to:
  /// **'Separa con comas. Entre 1 y 8 habilidades.'**
  String get compaSkillsHelp;

  /// No description provided for @compaSkillsInvalid.
  ///
  /// In es, this message translates to:
  /// **'Agrega de 1 a 8 habilidades, de 2 a 40 caracteres cada una.'**
  String get compaSkillsInvalid;

  /// No description provided for @compaAvailabilityHeading.
  ///
  /// In es, this message translates to:
  /// **'Tu disponibilidad semanal'**
  String get compaAvailabilityHeading;

  /// No description provided for @compaAvailabilityHelp.
  ///
  /// In es, this message translates to:
  /// **'Escribe las horas de tu zona. Deja vacío un día si no estás disponible. Puedes agregar hasta 3 franjas separadas por comas; por ejemplo 15:00-18:00, 20:00-23:00. Las reservas existentes mantienen su fecha y hora.'**
  String get compaAvailabilityHelp;

  /// No description provided for @compaTimeZone.
  ///
  /// In es, this message translates to:
  /// **'Zona horaria'**
  String get compaTimeZone;

  /// No description provided for @compaSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get compaSaving;

  /// No description provided for @compaSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get compaSaveChanges;

  /// No description provided for @compaActivateProfile.
  ///
  /// In es, this message translates to:
  /// **'Publicar mi perfil'**
  String get compaActivateProfile;

  /// No description provided for @compaLoginFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el acceso. Inténtalo otra vez.'**
  String get compaLoginFailed;

  /// No description provided for @compaRefreshSession.
  ///
  /// In es, this message translates to:
  /// **'Actualizar sesión'**
  String get compaRefreshSession;

  /// No description provided for @compaOpenAgenda.
  ///
  /// In es, this message translates to:
  /// **'Ir a mi agenda'**
  String get compaOpenAgenda;

  /// No description provided for @compaMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get compaMonday;

  /// No description provided for @compaTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get compaTuesday;

  /// No description provided for @compaWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get compaWednesday;

  /// No description provided for @compaThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get compaThursday;

  /// No description provided for @compaFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get compaFriday;

  /// No description provided for @compaSaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get compaSaturday;

  /// No description provided for @compaSunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get compaSunday;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsPreferences;

  /// No description provided for @settingsHeading.
  ///
  /// In es, this message translates to:
  /// **'A tu manera'**
  String get settingsHeading;

  /// No description provided for @settingsDescription.
  ///
  /// In es, this message translates to:
  /// **'Personaliza cómo se ve RAC en este dispositivo.'**
  String get settingsDescription;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsSystem.
  ///
  /// In es, this message translates to:
  /// **'Usar configuración del dispositivo'**
  String get settingsSystem;

  /// No description provided for @settingsLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsDark;

  /// No description provided for @settingsDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentos y acuerdos'**
  String get settingsDocuments;

  /// No description provided for @settingsDocumentsHelp.
  ///
  /// In es, this message translates to:
  /// **'Consulta las versiones y tus aceptaciones.'**
  String get settingsDocumentsHelp;

  /// No description provided for @commonConstruction.
  ///
  /// In es, this message translates to:
  /// **'En construcción'**
  String get commonConstruction;

  /// No description provided for @settingsPending.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de notificaciones, privacidad e idioma.'**
  String get settingsPending;

  /// No description provided for @navExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get navExplore;

  /// No description provided for @navBookings.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get navBookings;

  /// No description provided for @navMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get navMessages;

  /// No description provided for @navPayments.
  ///
  /// In es, this message translates to:
  /// **'Planes y pagos'**
  String get navPayments;

  /// No description provided for @navNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get navProfile;

  /// No description provided for @navTagline.
  ///
  /// In es, this message translates to:
  /// **'Tiempo para compartir.'**
  String get navTagline;

  /// No description provided for @navSpace.
  ///
  /// In es, this message translates to:
  /// **'TU ESPACIO'**
  String get navSpace;

  /// No description provided for @navAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administración'**
  String get navAdmin;

  /// No description provided for @navShare.
  ///
  /// In es, this message translates to:
  /// **'Comparte lo que te gusta'**
  String get navShare;

  /// No description provided for @navProfileInfo.
  ///
  /// In es, this message translates to:
  /// **'Configura tu perfil y disponibilidad para compartir actividades.'**
  String get navProfileInfo;

  /// No description provided for @navLogout.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get navLogout;

  /// No description provided for @navExploreTitle.
  ///
  /// In es, this message translates to:
  /// **'Explorar compas'**
  String get navExploreTitle;

  /// No description provided for @navOpenNotifications.
  ///
  /// In es, this message translates to:
  /// **'Ver notificaciones'**
  String get navOpenNotifications;

  /// No description provided for @navBookingsShort.
  ///
  /// In es, this message translates to:
  /// **'Reservas'**
  String get navBookingsShort;

  /// No description provided for @navProfileShort.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfileShort;

  /// No description provided for @accessFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos iniciar sesión. Inténtalo nuevamente.'**
  String get accessFailed;

  /// No description provided for @accessStory.
  ///
  /// In es, this message translates to:
  /// **'Los mejores planes\nse comparten.'**
  String get accessStory;

  /// No description provided for @accessStoryHelp.
  ///
  /// In es, this message translates to:
  /// **'Una caminata, un café o algo nuevo.\nEncuentra con quién disfrutarlo.'**
  String get accessStoryHelp;

  /// No description provided for @accessBrandLine.
  ///
  /// In es, this message translates to:
  /// **'RENT-A-COMPA · BUENA COMPAÑÍA'**
  String get accessBrandLine;

  /// No description provided for @accessHeading.
  ///
  /// In es, this message translates to:
  /// **'Tu próximo plan\nempieza aquí.'**
  String get accessHeading;

  /// No description provided for @accessDescription.
  ///
  /// In es, this message translates to:
  /// **'Conoce compas, encuentra intereses en común y organiza tiempo para compartir.'**
  String get accessDescription;

  /// No description provided for @accessMovies.
  ///
  /// In es, this message translates to:
  /// **'Cine'**
  String get accessMovies;

  /// No description provided for @accessRunning.
  ///
  /// In es, this message translates to:
  /// **'Running'**
  String get accessRunning;

  /// No description provided for @accessKaraoke.
  ///
  /// In es, this message translates to:
  /// **'Karaoke'**
  String get accessKaraoke;

  /// No description provided for @accessOpening.
  ///
  /// In es, this message translates to:
  /// **'Abriendo inicio de sesión…'**
  String get accessOpening;

  /// No description provided for @accessContinue.
  ///
  /// In es, this message translates to:
  /// **'Ingresar o crear cuenta'**
  String get accessContinue;

  /// No description provided for @accessReturn.
  ///
  /// In es, this message translates to:
  /// **'Al ingresar, volverás automáticamente a RAC.'**
  String get accessReturn;

  /// No description provided for @documentTermsClient.
  ///
  /// In es, this message translates to:
  /// **'Términos para clientes'**
  String get documentTermsClient;

  /// No description provided for @documentTermsCompa.
  ///
  /// In es, this message translates to:
  /// **'Términos para compas'**
  String get documentTermsCompa;

  /// No description provided for @documentCommunity.
  ///
  /// In es, this message translates to:
  /// **'Reglas de la comunidad'**
  String get documentCommunity;

  /// No description provided for @documentPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get documentPrivacy;

  /// No description provided for @documentSafety.
  ///
  /// In es, this message translates to:
  /// **'Reglas de seguridad'**
  String get documentSafety;

  /// No description provided for @documentGeneric.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get documentGeneric;

  /// No description provided for @documentsLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los documentos'**
  String get documentsLoadFailed;

  /// No description provided for @documentsRetryLater.
  ///
  /// In es, this message translates to:
  /// **'Inténtalo otra vez en unos momentos.'**
  String get documentsRetryLater;

  /// No description provided for @documentsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get documentsRetry;

  /// No description provided for @documentsPendingReview.
  ///
  /// In es, this message translates to:
  /// **'Los documentos estarán disponibles cuando termine su revisión.'**
  String get documentsPendingReview;

  /// No description provided for @documentsAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get documentsAccount;

  /// No description provided for @documentsHeading.
  ///
  /// In es, this message translates to:
  /// **'Información y acuerdos'**
  String get documentsHeading;

  /// No description provided for @documentsDescription.
  ///
  /// In es, this message translates to:
  /// **'Consulta cada versión y revisa cuáles has aceptado.'**
  String get documentsDescription;

  /// No description provided for @documentsNotAccepted.
  ///
  /// In es, this message translates to:
  /// **'Sin aceptar'**
  String get documentsNotAccepted;

  /// No description provided for @documentsAccepted.
  ///
  /// In es, this message translates to:
  /// **'Aceptada'**
  String get documentsAccepted;

  /// No description provided for @readerDocumentsChanged.
  ///
  /// In es, this message translates to:
  /// **'Los documentos cambiaron. Vuelve a la lista para actualizarlos.'**
  String get readerDocumentsChanged;

  /// No description provided for @documentsAcceptFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar la aceptación. Puedes reintentar.'**
  String get documentsAcceptFailed;

  /// No description provided for @documentsOpenFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esta versión'**
  String get documentsOpenFailed;

  /// No description provided for @documentsReturnRefresh.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a intentarlo o regresa a la lista para actualizarla.'**
  String get documentsReturnRefresh;

  /// No description provided for @documentsAlreadyAccepted.
  ///
  /// In es, this message translates to:
  /// **'Ya aceptaste esta versión.'**
  String get documentsAlreadyAccepted;

  /// No description provided for @documentsConsent.
  ///
  /// In es, this message translates to:
  /// **'Acepto esta versión del documento.'**
  String get documentsConsent;

  /// No description provided for @documentsConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar aceptación'**
  String get documentsConfirm;

  /// No description provided for @documentVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String documentVersion(String version);

  /// No description provided for @documentsVersionStatus.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} · {status}'**
  String documentsVersionStatus(String version, String status);

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @notificationsUpdateFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar la notificación. Inténtalo otra vez.'**
  String get notificationsUpdateFailed;

  /// No description provided for @notificationsAllFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos marcar tus avisos. Actualiza para comprobar su estado.'**
  String get notificationsAllFailed;

  /// No description provided for @notificationsAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get notificationsAccount;

  /// No description provided for @notificationsBooking.
  ///
  /// In es, this message translates to:
  /// **'Reserva'**
  String get notificationsBooking;

  /// No description provided for @notificationsBookingReference.
  ///
  /// In es, this message translates to:
  /// **'Reserva {reference}'**
  String notificationsBookingReference(String reference);

  /// No description provided for @notificationsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar notificaciones'**
  String get notificationsRefresh;

  /// No description provided for @notificationsLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus notificaciones'**
  String get notificationsLoadFailed;

  /// No description provided for @notificationsRetryMessage.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo nuevamente.'**
  String get notificationsRetryMessage;

  /// No description provided for @notificationsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get notificationsRetry;

  /// No description provided for @notificationsHeading.
  ///
  /// In es, this message translates to:
  /// **'Novedades de tu cuenta y reservas'**
  String get notificationsHeading;

  /// No description provided for @notificationsDescription.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás cambios de tu cuenta y tus reservas. Avisos por correo y al teléfono: en construcción.'**
  String get notificationsDescription;

  /// No description provided for @notificationsUnread.
  ///
  /// In es, this message translates to:
  /// **'{count} sin leer en tu bandeja'**
  String notificationsUnread(int count);

  /// No description provided for @notificationsUpdating.
  ///
  /// In es, this message translates to:
  /// **'Actualizando…'**
  String get notificationsUpdating;

  /// No description provided for @notificationsMarkAll.
  ///
  /// In es, this message translates to:
  /// **'Marcar todas como leídas'**
  String get notificationsMarkAll;

  /// No description provided for @notificationsCaughtUp.
  ///
  /// In es, this message translates to:
  /// **'Estás al día'**
  String get notificationsCaughtUp;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Los próximos cambios de tu cuenta y tus reservas aparecerán aquí.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva'**
  String get notificationsNew;

  /// No description provided for @notificationsMarkRead.
  ///
  /// In es, this message translates to:
  /// **'Marcar como leída'**
  String get notificationsMarkRead;

  /// No description provided for @notificationsViewAccount.
  ///
  /// In es, this message translates to:
  /// **'Ver estado de mi cuenta'**
  String get notificationsViewAccount;

  /// No description provided for @notificationsViewBookings.
  ///
  /// In es, this message translates to:
  /// **'Ver mis reservas'**
  String get notificationsViewBookings;

  /// No description provided for @notificationsNewer.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get notificationsNewer;

  /// No description provided for @notificationsOlder.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get notificationsOlder;

  /// No description provided for @plansTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes y suscripción'**
  String get plansTitle;

  /// No description provided for @plansEyebrow.
  ///
  /// In es, this message translates to:
  /// **'A tu ritmo'**
  String get plansEyebrow;

  /// No description provided for @plansHeading.
  ///
  /// In es, this message translates to:
  /// **'Empieza gratis. Crece a tu ritmo.'**
  String get plansHeading;

  /// No description provided for @plansDescription.
  ///
  /// In es, this message translates to:
  /// **'La suscripción amplía tu capacidad para aceptar reservas como compa.'**
  String get plansDescription;

  /// No description provided for @plansPending.
  ///
  /// In es, this message translates to:
  /// **'Las solicitudes que superen tu cupo permanecen pendientes. Tú decides cuáles confirmar cuando tengas capacidad disponible.'**
  String get plansPending;

  /// No description provided for @plansPaidTitle.
  ///
  /// In es, this message translates to:
  /// **'Más espacio para crecer'**
  String get plansPaidTitle;

  /// No description provided for @plansFreeTitle.
  ///
  /// In es, this message translates to:
  /// **'Plan gratuito'**
  String get plansFreeTitle;

  /// No description provided for @plansPreparing.
  ///
  /// In es, this message translates to:
  /// **'Estamos preparando la suscripción.'**
  String get plansPreparing;

  /// No description provided for @plansWeekly.
  ///
  /// In es, this message translates to:
  /// **'3 reservas por semana'**
  String get plansWeekly;

  /// No description provided for @plansRequests.
  ///
  /// In es, this message translates to:
  /// **'Recibe solicitudes sin límite de cupos.'**
  String get plansRequests;

  /// No description provided for @plansConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirma hasta 3 reservas cada semana.'**
  String get plansConfirm;

  /// No description provided for @plansProfile.
  ///
  /// In es, this message translates to:
  /// **'Publica tu perfil y administra tu agenda.'**
  String get plansProfile;

  /// No description provided for @plansWeekRules.
  ///
  /// In es, this message translates to:
  /// **'El cupo se calcula de lunes a domingo, según la fecha de la actividad y la zona horaria de Chile. Si cancelas antes del inicio, recuperas el cupo; después del inicio, se mantiene consumido.'**
  String get plansWeekRules;

  /// No description provided for @plansAcceptMore.
  ///
  /// In es, this message translates to:
  /// **'Acepta más reservas con una suscripción activa.'**
  String get plansAcceptMore;

  /// No description provided for @plansControl.
  ///
  /// In es, this message translates to:
  /// **'Conserva el control de tus solicitudes pendientes.'**
  String get plansControl;

  /// No description provided for @plansPaymentDetails.
  ///
  /// In es, this message translates to:
  /// **'Estamos definiendo el precio, la renovación y el proveedor de pago. No se realizarán cobros ni se simularán suscripciones. Tus solicitudes no se aceptarán automáticamente.'**
  String get plansPaymentDetails;

  /// No description provided for @plansPaymentsConstruction.
  ///
  /// In es, this message translates to:
  /// **'Pagos en construcción'**
  String get plansPaymentsConstruction;

  /// No description provided for @allowanceLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar tus cupos'**
  String get allowanceLoadFailed;

  /// No description provided for @allowanceRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar cupos'**
  String get allowanceRetry;

  /// No description provided for @allowanceRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar cupos'**
  String get allowanceRefresh;

  /// No description provided for @allowanceActive.
  ///
  /// In es, this message translates to:
  /// **'Suscripción activa'**
  String get allowanceActive;

  /// No description provided for @allowanceAvailable.
  ///
  /// In es, this message translates to:
  /// **'{available} de {limit} cupos gratuitos disponibles'**
  String allowanceAvailable(int available, int limit);

  /// No description provided for @allowanceWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana del {date} · Chile · {used} reservas confirmadas'**
  String allowanceWeek(String date, int used);

  /// No description provided for @allowanceSelectWeek.
  ///
  /// In es, this message translates to:
  /// **'Consultar otra semana'**
  String get allowanceSelectWeek;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu perfil.'**
  String get profileLoadFailed;

  /// No description provided for @profileSaved.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil se guardó correctamente'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tus cambios. Se conservan en el formulario; vuelve a intentarlo.'**
  String get profileSaveFailed;

  /// No description provided for @profilePhotoLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu foto. Puedes volver a intentarlo.'**
  String get profilePhotoLoadFailed;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen debe pesar como máximo 5 MB.'**
  String get profilePhotoTooLarge;

  /// No description provided for @profilePhotoFormat.
  ///
  /// In es, this message translates to:
  /// **'Elige una foto JPG o PNG.'**
  String get profilePhotoFormat;

  /// No description provided for @profilePhotoInvalid.
  ///
  /// In es, this message translates to:
  /// **'Elige una imagen JPG o PNG válida, entre 32 y 4096 píxeles por lado y hasta 12 megapíxeles.'**
  String get profilePhotoInvalid;

  /// No description provided for @profilePhotoBusy.
  ///
  /// In es, this message translates to:
  /// **'Estamos procesando otras fotos. Inténtalo en unos segundos.'**
  String get profilePhotoBusy;

  /// No description provided for @profilePhotoSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el guardado de tu foto. Inténtalo nuevamente.'**
  String get profilePhotoSaveFailed;

  /// No description provided for @profilePhotoConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu foto'**
  String get profilePhotoConfirm;

  /// No description provided for @profilePhotoPreviewNote.
  ///
  /// In es, this message translates to:
  /// **'Se recortará al centro en formato cuadrado. Será pública al activar tu perfil compa.'**
  String get profilePhotoPreviewNote;

  /// No description provided for @profileCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get profileCancel;

  /// No description provided for @profilePhotoSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar foto'**
  String get profilePhotoSave;

  /// No description provided for @profilePhotoSaved.
  ///
  /// In es, this message translates to:
  /// **'Tu foto se guardó correctamente'**
  String get profilePhotoSaved;

  /// No description provided for @profilePhotoProcessFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos procesar la foto. Inténtalo nuevamente.'**
  String get profilePhotoProcessFailed;

  /// No description provided for @profilePhotoRemoveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar tu foto?'**
  String get profilePhotoRemoveTitle;

  /// No description provided for @profilePhotoRemoveNote.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil volverá a mostrar tu inicial.'**
  String get profilePhotoRemoveNote;

  /// No description provided for @profilePhotoKeep.
  ///
  /// In es, this message translates to:
  /// **'Conservar'**
  String get profilePhotoKeep;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoRemoveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos quitar tu foto. Inténtalo nuevamente.'**
  String get profilePhotoRemoveFailed;

  /// No description provided for @profilePublicPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa pública'**
  String get profilePublicPreview;

  /// No description provided for @profilePreviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Así se verá tu presentación'**
  String get profilePreviewTitle;

  /// No description provided for @profilePreviewNote.
  ///
  /// In es, this message translates to:
  /// **'Esta vista incluye tus cambios sin guardar. No publica ni activa tu perfil compa.'**
  String get profilePreviewNote;

  /// No description provided for @profileNameValidation.
  ///
  /// In es, this message translates to:
  /// **'Ingresa al menos dos caracteres'**
  String get profileNameValidation;

  /// No description provided for @profilePhoneValidation.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un teléfono válido'**
  String get profilePhoneValidation;

  /// No description provided for @profileInterestsValidation.
  ///
  /// In es, this message translates to:
  /// **'Máximo 15 intereses de 40 caracteres'**
  String get profileInterestsValidation;

  /// No description provided for @profileRetryMessage.
  ///
  /// In es, this message translates to:
  /// **'Inténtalo nuevamente.'**
  String get profileRetryMessage;

  /// No description provided for @profileRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get profileRetry;

  /// No description provided for @profileAccount.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get profileAccount;

  /// No description provided for @profileHeading.
  ///
  /// In es, this message translates to:
  /// **'Hagamos tu perfil más tuyo'**
  String get profileHeading;

  /// No description provided for @profileDescription.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos cómo te llamas y qué te gusta hacer.'**
  String get profileDescription;

  /// No description provided for @profileBaseRole.
  ///
  /// In es, this message translates to:
  /// **'Usuario base'**
  String get profileBaseRole;

  /// No description provided for @profileCompaRole.
  ///
  /// In es, this message translates to:
  /// **'Compa'**
  String get profileCompaRole;

  /// No description provided for @profileAdminRole.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get profileAdminRole;

  /// No description provided for @profilePhotoProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando foto…'**
  String get profilePhotoProcessing;

  /// No description provided for @profilePhotoChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get profilePhotoChange;

  /// No description provided for @profilePhotoHelp.
  ///
  /// In es, this message translates to:
  /// **'Foto y biografía serán públicas al activar tu perfil compa. JPG o PNG, máximo 5 MB. La foto se guarda por separado.'**
  String get profilePhotoHelp;

  /// No description provided for @profileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre visible'**
  String get profileName;

  /// No description provided for @profileNameHelp.
  ///
  /// In es, this message translates to:
  /// **'Este nombre aparece en tu perfil compa y tus reservas.'**
  String get profileNameHelp;

  /// No description provided for @profileBiography.
  ///
  /// In es, this message translates to:
  /// **'Biografía pública (opcional)'**
  String get profileBiography;

  /// No description provided for @profileBiographyHelp.
  ///
  /// In es, this message translates to:
  /// **'Cuenta qué te gusta compartir. Evita incluir datos de contacto privados.'**
  String get profileBiographyHelp;

  /// No description provided for @profileEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo de acceso'**
  String get profileEmail;

  /// No description provided for @profileEmailHelp.
  ///
  /// In es, this message translates to:
  /// **'Gestionado por tu cuenta de acceso.'**
  String get profileEmailHelp;

  /// No description provided for @profileContact.
  ///
  /// In es, this message translates to:
  /// **'Datos de contacto'**
  String get profileContact;

  /// No description provided for @profileContactHelp.
  ///
  /// In es, this message translates to:
  /// **'Son opcionales. Tu teléfono y ubicación general no se muestran en el catálogo público.'**
  String get profileContactHelp;

  /// No description provided for @profilePhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (opcional)'**
  String get profilePhone;

  /// No description provided for @profileCountry.
  ///
  /// In es, this message translates to:
  /// **'País (opcional)'**
  String get profileCountry;

  /// No description provided for @profileRegion.
  ///
  /// In es, this message translates to:
  /// **'Región (opcional)'**
  String get profileRegion;

  /// No description provided for @profileCity.
  ///
  /// In es, this message translates to:
  /// **'Ciudad (opcional)'**
  String get profileCity;

  /// No description provided for @profileInterests.
  ///
  /// In es, this message translates to:
  /// **'Tus intereses (opcionales)'**
  String get profileInterests;

  /// No description provided for @profileInterestsHelp.
  ///
  /// In es, this message translates to:
  /// **'Sepáralos con comas. Por ejemplo: cine, trekking, videojuegos.'**
  String get profileInterestsHelp;

  /// No description provided for @profileSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get profileSaving;

  /// No description provided for @profileSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get profileSave;

  /// No description provided for @profileDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar cambios'**
  String get profileDiscard;

  /// No description provided for @profileUnsaved.
  ///
  /// In es, this message translates to:
  /// **'Tienes cambios sin guardar.'**
  String get profileUnsaved;

  /// No description provided for @profileBookings.
  ///
  /// In es, this message translates to:
  /// **'Ver mis reservas'**
  String get profileBookings;

  /// No description provided for @publicProfileName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre visible'**
  String get publicProfileName;

  /// No description provided for @publicProfileTagline.
  ///
  /// In es, this message translates to:
  /// **'Un interés en común. Un plan para compartir.'**
  String get publicProfileTagline;

  /// No description provided for @publicProfileAbout.
  ///
  /// In es, this message translates to:
  /// **'Sobre mí'**
  String get publicProfileAbout;

  /// No description provided for @publicProfileEmptyBiography.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay una biografía.'**
  String get publicProfileEmptyBiography;

  /// No description provided for @publicProfileInterests.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get publicProfileInterests;

  /// No description provided for @publicProfilePhotoLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto de {name}'**
  String publicProfilePhotoLabel(String name);

  /// No description provided for @timeOffTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis días libres'**
  String get timeOffTitle;

  /// No description provided for @timeOffRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar días libres'**
  String get timeOffRefresh;

  /// No description provided for @timeOffHeading.
  ///
  /// In es, this message translates to:
  /// **'Una pausa en tu agenda'**
  String get timeOffHeading;

  /// No description provided for @timeOffDescription.
  ///
  /// In es, this message translates to:
  /// **'Bloquea días completos para vacaciones u otros compromisos. Las fechas usan la zona de tu agenda. El último día también queda bloqueado.'**
  String get timeOffDescription;

  /// No description provided for @timeOffDescriptionWithZone.
  ///
  /// In es, this message translates to:
  /// **'Bloquea días completos para vacaciones u otros compromisos. Las fechas usan la zona de tu agenda: {zone}. El último día también queda bloqueado.'**
  String timeOffDescriptionWithZone(String zone);

  /// No description provided for @timeOffReservationsHelp.
  ///
  /// In es, this message translates to:
  /// **'No se cancelan reservas existentes. Si hay una pendiente o confirmada, resuélvela antes de bloquear ese período.'**
  String get timeOffReservationsHelp;

  /// No description provided for @timeOffForbidden.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes gestionar tu propia agenda.'**
  String get timeOffForbidden;

  /// No description provided for @timeOffLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los días libres. Inténtalo nuevamente.'**
  String get timeOffLoadFailed;

  /// No description provided for @timeOffConflict.
  ///
  /// In es, this message translates to:
  /// **'El período se cruza con una reserva o con otro bloqueo. Tus reservas se conservan.'**
  String get timeOffConflict;

  /// No description provided for @timeOffSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar el cambio. Revisa las fechas e inténtalo nuevamente.'**
  String get timeOffSaveFailed;

  /// No description provided for @timeOffTooLong.
  ///
  /// In es, this message translates to:
  /// **'Puedes bloquear hasta 366 días por período.'**
  String get timeOffTooLong;

  /// No description provided for @timeOffPickerHelp.
  ///
  /// In es, this message translates to:
  /// **'Días sin disponibilidad'**
  String get timeOffPickerHelp;

  /// No description provided for @timeOffPickerSave.
  ///
  /// In es, this message translates to:
  /// **'Bloquear días'**
  String get timeOffPickerSave;

  /// No description provided for @timeOffRemoveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Volver a ofrecer estos días?'**
  String get timeOffRemoveTitle;

  /// No description provided for @timeOffRemoveMessage.
  ///
  /// In es, this message translates to:
  /// **'Se quitará el bloqueo del {start} al {end}. Se conserva tu horario semanal.'**
  String timeOffRemoveMessage(String start, String end);

  /// No description provided for @timeOffKeep.
  ///
  /// In es, this message translates to:
  /// **'Conservar'**
  String get timeOffKeep;

  /// No description provided for @timeOffRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar bloqueo'**
  String get timeOffRemove;

  /// No description provided for @timeOffRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get timeOffRetry;

  /// No description provided for @timeOffSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get timeOffSaving;

  /// No description provided for @timeOffAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar días libres'**
  String get timeOffAdd;

  /// No description provided for @timeOffEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes bloqueos vigentes. Se aplica tu disponibilidad semanal.'**
  String get timeOffEmpty;

  /// No description provided for @timeOffFullDays.
  ///
  /// In es, this message translates to:
  /// **'Días completos · {zone}'**
  String timeOffFullDays(String zone);

  /// No description provided for @standingLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar el estado de tu cuenta'**
  String get standingLoadFailed;

  /// No description provided for @standingSuspended.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta tiene actividades suspendidas'**
  String get standingSuspended;

  /// No description provided for @standingRestricted.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta tiene restricciones'**
  String get standingRestricted;

  /// No description provided for @standingUnavailableHelp.
  ///
  /// In es, this message translates to:
  /// **'Algunas operaciones pueden no estar disponibles. Puedes seguir consultando tus reservas y las herramientas de seguridad.'**
  String get standingUnavailableHelp;

  /// No description provided for @standingRestrictedHelp.
  ///
  /// In es, this message translates to:
  /// **'Algunas acciones están limitadas. Conservas el acceso a tus reservas y a las herramientas de protección disponibles.'**
  String get standingRestrictedHelp;

  /// No description provided for @standingRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get standingRetry;

  /// No description provided for @constructionDescription.
  ///
  /// In es, this message translates to:
  /// **'Esta sección todavía no está disponible.'**
  String get constructionDescription;

  /// No description provided for @constructionBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get constructionBack;

  /// No description provided for @exploreHeroEyebrow.
  ///
  /// In es, this message translates to:
  /// **'HAZ ESPACIO PARA UN BUEN PLAN'**
  String get exploreHeroEyebrow;

  /// No description provided for @exploreHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Un buen plan empieza\ncon buena compañía.'**
  String get exploreHeroTitle;

  /// No description provided for @exploreHeroBody.
  ///
  /// In es, this message translates to:
  /// **'Descubre personas con quienes compartir lo que te gusta.'**
  String get exploreHeroBody;

  /// No description provided for @exploreHeroHint.
  ///
  /// In es, this message translates to:
  /// **'Tú eliges el plan. Encuentra tu compa.'**
  String get exploreHeroHint;

  /// No description provided for @exploreQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustaría hacer?'**
  String get exploreQuestion;

  /// No description provided for @exploreQuestionHelp.
  ///
  /// In es, this message translates to:
  /// **'Busca por habilidad o explora algo diferente.'**
  String get exploreQuestionHelp;

  /// No description provided for @exploreSearchHintCompact.
  ///
  /// In es, this message translates to:
  /// **'Cine, running, café…'**
  String get exploreSearchHintCompact;

  /// No description provided for @exploreSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Busca una habilidad: cine, running, café…'**
  String get exploreSearchHint;

  /// No description provided for @exploreClearSearch.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get exploreClearSearch;

  /// No description provided for @exploreSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get exploreSearch;

  /// No description provided for @exploreAllSkills.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get exploreAllSkills;

  /// No description provided for @exploreTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu compa'**
  String get exploreTitle;

  /// No description provided for @exploreRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get exploreRefresh;

  /// No description provided for @exploreCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{amount} compa para conocer} other{{amount} compas para conocer}}'**
  String exploreCount(int count, String amount);

  /// No description provided for @exploreLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los compas. Inténtalo otra vez.'**
  String get exploreLoadFailed;

  /// No description provided for @exploreRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get exploreRetry;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos compas'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba otra habilidad o selecciona Todos.'**
  String get exploreEmptyMessage;

  /// No description provided for @exploreShowAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los compas'**
  String get exploreShowAll;

  /// No description provided for @exploreShowMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más compas'**
  String get exploreShowMore;

  /// No description provided for @exploreFooter.
  ///
  /// In es, this message translates to:
  /// **'Encuentra un interés en común. Revisa el perfil y acuerda tu próxima experiencia.'**
  String get exploreFooter;

  /// No description provided for @exploreCardSemantics.
  ///
  /// In es, this message translates to:
  /// **'Ver perfil de {name}. {skills}. {rate} CLP por hora. {rating}.'**
  String exploreCardSemantics(
    String name,
    String skills,
    String rate,
    String rating,
  );

  /// No description provided for @exploreCardRating.
  ///
  /// In es, this message translates to:
  /// **'Calificación {rating}'**
  String exploreCardRating(String rating);

  /// No description provided for @exploreNewInRac.
  ///
  /// In es, this message translates to:
  /// **'Nuevo en RAC'**
  String get exploreNewInRac;

  /// No description provided for @exploreNoSkills.
  ///
  /// In es, this message translates to:
  /// **'Conoce sus intereses'**
  String get exploreNoSkills;

  /// No description provided for @exploreNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Comparte una nueva experiencia.'**
  String get exploreNoDescription;

  /// No description provided for @explorePerHour.
  ///
  /// In es, this message translates to:
  /// **'/ hora'**
  String get explorePerHour;

  /// No description provided for @compaDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Conoce a tu compa'**
  String get compaDetailTitle;

  /// No description provided for @compaDetailLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el perfil'**
  String get compaDetailLoadFailed;

  /// No description provided for @compaDetailLoadHelp.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo nuevamente.'**
  String get compaDetailLoadHelp;

  /// No description provided for @compaDetailRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get compaDetailRetry;

  /// No description provided for @compaDetailRating.
  ///
  /// In es, this message translates to:
  /// **'★ {rating} · {count, plural, =1{{count} reseña verificada} other{{count} reseñas verificadas}}'**
  String compaDetailRating(String rating, int count);

  /// No description provided for @compaDetailUnrated.
  ///
  /// In es, this message translates to:
  /// **'Nuevo en RAC · Aún sin calificaciones'**
  String get compaDetailUnrated;

  /// No description provided for @compaDetailActivities.
  ///
  /// In es, this message translates to:
  /// **'Lo que podemos hacer'**
  String get compaDetailActivities;

  /// No description provided for @compaDetailNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Este compa todavía no agregó una descripción.'**
  String get compaDetailNoDescription;

  /// No description provided for @compaDetailRate.
  ///
  /// In es, this message translates to:
  /// **'{amount} CLP / hora'**
  String compaDetailRate(String amount);

  /// No description provided for @compaDetailBookingHelp.
  ///
  /// In es, this message translates to:
  /// **'Consulta horarios y envía una solicitud. Sin cobro por ahora.'**
  String get compaDetailBookingHelp;

  /// No description provided for @compaDetailBook.
  ///
  /// In es, this message translates to:
  /// **'Reservar'**
  String get compaDetailBook;

  /// No description provided for @bookingTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu próxima experiencia'**
  String get bookingTitle;

  /// No description provided for @bookingWith.
  ///
  /// In es, this message translates to:
  /// **'Reserva con {name}'**
  String bookingWith(String name);

  /// No description provided for @bookingIntro.
  ///
  /// In es, this message translates to:
  /// **'Elige cuándo y por cuánto tiempo. El compa debe aceptar tu solicitud.'**
  String get bookingIntro;

  /// No description provided for @bookingStepDate.
  ///
  /// In es, this message translates to:
  /// **'1. Fecha y duración'**
  String get bookingStepDate;

  /// No description provided for @bookingHours.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} hora} other{{count} horas}}'**
  String bookingHours(int count);

  /// No description provided for @bookingStepTime.
  ///
  /// In es, this message translates to:
  /// **'2. Hora de inicio'**
  String get bookingStepTime;

  /// No description provided for @bookingZones.
  ///
  /// In es, this message translates to:
  /// **'Horarios en tu zona local ({local}). Agenda del compa: {zone}. Se confirma disponibilidad al enviar.'**
  String bookingZones(String local, String zone);

  /// No description provided for @bookingNoSchedule.
  ///
  /// In es, this message translates to:
  /// **'Este compa aún no publicó horarios. Puedes explorar otros compas.'**
  String get bookingNoSchedule;

  /// No description provided for @bookingNoSlots.
  ///
  /// In es, this message translates to:
  /// **'No hay horarios disponibles para esta fecha y duración. Prueba otro día o una duración menor.'**
  String get bookingNoSlots;

  /// No description provided for @bookingStepReview.
  ///
  /// In es, this message translates to:
  /// **'3. Revisa tu solicitud'**
  String get bookingStepReview;

  /// No description provided for @bookingSelectSlot.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un horario para continuar.'**
  String get bookingSelectSlot;

  /// No description provided for @bookingReferenceValue.
  ///
  /// In es, this message translates to:
  /// **'Valor referencial: {amount} CLP'**
  String bookingReferenceValue(String amount);

  /// No description provided for @bookingNoCharge.
  ///
  /// In es, this message translates to:
  /// **'No se realizará ningún cobro. Pagos en construcción.'**
  String get bookingNoCharge;

  /// No description provided for @bookingSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get bookingSending;

  /// No description provided for @bookingSubmit.
  ///
  /// In es, this message translates to:
  /// **'Solicitar reserva'**
  String get bookingSubmit;

  /// No description provided for @bookingRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar disponibilidad'**
  String get bookingRefresh;

  /// No description provided for @bookingSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada. Puedes seguir su estado en Mis reservas.'**
  String get bookingSent;

  /// No description provided for @bookingLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar la disponibilidad. Vuelve a intentarlo.'**
  String get bookingLoadFailed;

  /// No description provided for @bookingSlotPast.
  ///
  /// In es, this message translates to:
  /// **'Ese horario ya pasó. Selecciona otro horario disponible.'**
  String get bookingSlotPast;

  /// No description provided for @bookingSlotTaken.
  ///
  /// In es, this message translates to:
  /// **'Ese horario acaba de ocuparse. Elige otro e inténtalo nuevamente.'**
  String get bookingSlotTaken;

  /// No description provided for @bookingAvailabilityChanged.
  ///
  /// In es, this message translates to:
  /// **'La disponibilidad cambió. Selecciona otro horario.'**
  String get bookingAvailabilityChanged;

  /// No description provided for @bookingSubmitFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar la solicitud. Inténtalo nuevamente.'**
  String get bookingSubmitFailed;

  /// No description provided for @bookingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis reservas'**
  String get bookingsTitle;

  /// No description provided for @bookingsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar reservas'**
  String get bookingsRefresh;

  /// No description provided for @bookingsHeadline.
  ///
  /// In es, this message translates to:
  /// **'Tus planes, en un solo lugar.'**
  String get bookingsHeadline;

  /// No description provided for @bookingsIntro.
  ///
  /// In es, this message translates to:
  /// **'Sigue tus solicitudes y gestiona las experiencias confirmadas.'**
  String get bookingsIntro;

  /// No description provided for @bookingsLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus reservas'**
  String get bookingsLoadFailed;

  /// No description provided for @bookingsLoadHelp.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo nuevamente.'**
  String get bookingsLoadHelp;

  /// No description provided for @bookingsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get bookingsRetry;

  /// No description provided for @bookingsTabHired.
  ///
  /// In es, this message translates to:
  /// **'Mis contrataciones'**
  String get bookingsTabHired;

  /// No description provided for @bookingsTabReceived.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes recibidas'**
  String get bookingsTabReceived;

  /// No description provided for @bookingsEmptyReceivedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu agenda está libre'**
  String get bookingsEmptyReceivedTitle;

  /// No description provided for @bookingsEmptyReceivedMessage.
  ///
  /// In es, this message translates to:
  /// **'Las solicitudes que recibas aparecerán aquí.'**
  String get bookingsEmptyReceivedMessage;

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu próximo plan te espera'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Explora los compas y encuentra una experiencia para compartir.'**
  String get bookingsEmptyMessage;

  /// No description provided for @bookingsExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar compas'**
  String get bookingsExplore;

  /// No description provided for @bookingsStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de aceptación'**
  String get bookingsStatusPending;

  /// No description provided for @bookingsStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get bookingsStatusActive;

  /// No description provided for @bookingsStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get bookingsStatusCancelled;

  /// No description provided for @bookingsStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencida sin aceptación'**
  String get bookingsStatusExpired;

  /// No description provided for @bookingsStatusFinished.
  ///
  /// In es, this message translates to:
  /// **'Finalizada'**
  String get bookingsStatusFinished;

  /// No description provided for @bookingsStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Estado no reconocido'**
  String get bookingsStatusUnknown;

  /// No description provided for @bookingsNoCharge.
  ///
  /// In es, this message translates to:
  /// **'Pagos en construcción · Sin cobro'**
  String get bookingsNoCharge;

  /// No description provided for @bookingsReference.
  ///
  /// In es, this message translates to:
  /// **'Reserva {id} · {role}'**
  String bookingsReference(String id, String role);

  /// No description provided for @bookingsRoleReceived.
  ///
  /// In es, this message translates to:
  /// **'Solicitud recibida'**
  String get bookingsRoleReceived;

  /// No description provided for @bookingsRoleHired.
  ///
  /// In es, this message translates to:
  /// **'Tu contratación'**
  String get bookingsRoleHired;

  /// No description provided for @bookingsOpenChat.
  ///
  /// In es, this message translates to:
  /// **'Abrir conversación'**
  String get bookingsOpenChat;

  /// No description provided for @bookingsReviewLater.
  ///
  /// In es, this message translates to:
  /// **'Podrás dejar una reseña cuando termine el horario reservado.'**
  String get bookingsReviewLater;

  /// No description provided for @bookingsAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get bookingsAccept;

  /// No description provided for @bookingsFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get bookingsFinish;

  /// No description provided for @bookingsCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get bookingsCancel;

  /// No description provided for @bookingsUpdating.
  ///
  /// In es, this message translates to:
  /// **'Actualizando…'**
  String get bookingsUpdating;

  /// No description provided for @bookingsUpdateFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la reserva. Revisa su estado e inténtalo nuevamente.'**
  String get bookingsUpdateFailed;

  /// No description provided for @bookingsCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar esta reserva?'**
  String get bookingsCancelTitle;

  /// No description provided for @bookingsCancelMessage.
  ///
  /// In es, this message translates to:
  /// **'La solicitud quedará cancelada. Puedes crear otra reserva cuando quieras.'**
  String get bookingsCancelMessage;

  /// No description provided for @bookingsTimeOff.
  ///
  /// In es, this message translates to:
  /// **'Mis días libres'**
  String get bookingsTimeOff;

  /// No description provided for @bookingsKeep.
  ///
  /// In es, this message translates to:
  /// **'Conservar'**
  String get bookingsKeep;

  /// No description provided for @bookingsConfirmCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar reserva'**
  String get bookingsConfirmCancel;

  /// No description provided for @bookingsLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Alcanzaste tus 3 reservas gratis'**
  String get bookingsLimitTitle;

  /// No description provided for @bookingsLimitMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya utilizaste {used} cupos en la semana que empieza el {weekStart} (Chile).\n\nEsta solicitud sigue pendiente. Para aceptar más necesitarás una suscripción. Los pagos todavía están en construcción.'**
  String bookingsLimitMessage(String used, String weekStart);

  /// No description provided for @bookingsLimitOk.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get bookingsLimitOk;

  /// No description provided for @bookingsLimitPlans.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get bookingsLimitPlans;

  /// No description provided for @reviewRetryLoad.
  ///
  /// In es, this message translates to:
  /// **'Reintentar carga de reseña'**
  String get reviewRetryLoad;

  /// No description provided for @reviewVerified.
  ///
  /// In es, this message translates to:
  /// **'★ {score}/5 · Reseña verificada'**
  String reviewVerified(String score);

  /// No description provided for @reviewWrite.
  ///
  /// In es, this message translates to:
  /// **'Dejar una reseña'**
  String get reviewWrite;

  /// No description provided for @reviewDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo estuvo la experiencia?'**
  String get reviewDialogTitle;

  /// No description provided for @reviewDialogIntro.
  ///
  /// In es, this message translates to:
  /// **'Tu reseña será pública y quedará vinculada a una reserva verificada. Se envía una sola vez y no se puede editar.'**
  String get reviewDialogIntro;

  /// No description provided for @reviewStars.
  ///
  /// In es, this message translates to:
  /// **'{count} de 5 estrellas'**
  String reviewStars(int count);

  /// No description provided for @reviewComment.
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get reviewComment;

  /// No description provided for @reviewCommentHelp.
  ///
  /// In es, this message translates to:
  /// **'Evita incluir datos de contacto o información privada.'**
  String get reviewCommentHelp;

  /// No description provided for @reviewSendFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el envío. Reintenta o vuelve a la reserva para comprobar si se guardó.'**
  String get reviewSendFailed;

  /// No description provided for @reviewConflict.
  ///
  /// In es, this message translates to:
  /// **'Esta reserva todavía no permite reseñas o ya tiene una. Vuelve a la reserva para comprobar su estado.'**
  String get reviewConflict;

  /// No description provided for @reviewBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get reviewBack;

  /// No description provided for @reviewSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get reviewSending;

  /// No description provided for @reviewPublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar reseña'**
  String get reviewPublish;

  /// No description provided for @reviewsPublicTitle.
  ///
  /// In es, this message translates to:
  /// **'Reseñas de reservas verificadas'**
  String get reviewsPublicTitle;

  /// No description provided for @reviewsPublicEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay reseñas. Solo pueden valorar quienes completaron una reserva.'**
  String get reviewsPublicEmpty;

  /// No description provided for @reviewsPublicItem.
  ///
  /// In es, this message translates to:
  /// **'★ {score}/5 · Reserva verificada'**
  String reviewsPublicItem(String score);

  /// No description provided for @reviewsPublicLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las reseñas. Reintentar'**
  String get reviewsPublicLoadFailed;

  /// No description provided for @reviewsPublicMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más reseñas'**
  String get reviewsPublicMore;

  /// No description provided for @chatStateActive.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get chatStateActive;

  /// No description provided for @chatStateFinished.
  ///
  /// In es, this message translates to:
  /// **'Finalizada · Solo lectura'**
  String get chatStateFinished;

  /// No description provided for @chatStateClosed.
  ///
  /// In es, this message translates to:
  /// **'Cancelada · Solo lectura'**
  String get chatStateClosed;

  /// No description provided for @chatTitle.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get chatTitle;

  /// No description provided for @chatModeration.
  ///
  /// In es, this message translates to:
  /// **'Moderación de reportes'**
  String get chatModeration;

  /// No description provided for @chatRefreshList.
  ///
  /// In es, this message translates to:
  /// **'Actualizar conversaciones'**
  String get chatRefreshList;

  /// No description provided for @chatListLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus conversaciones'**
  String get chatListLoadFailed;

  /// No description provided for @chatCheckConnection.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo nuevamente.'**
  String get chatCheckConnection;

  /// No description provided for @chatRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get chatRetry;

  /// No description provided for @chatListHeadline.
  ///
  /// In es, this message translates to:
  /// **'Conversemos el próximo plan'**
  String get chatListHeadline;

  /// No description provided for @chatListIntro.
  ///
  /// In es, this message translates to:
  /// **'Cada conversación pertenece a una reserva confirmada. Solo sus dos participantes pueden acceder.'**
  String get chatListIntro;

  /// No description provided for @chatListEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes conversaciones'**
  String get chatListEmptyTitle;

  /// No description provided for @chatListEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Al confirmar una reserva podrás coordinar los detalles con tu compa.'**
  String get chatListEmptyMessage;

  /// No description provided for @chatListBookings.
  ///
  /// In es, this message translates to:
  /// **'Ver mis reservas'**
  String get chatListBookings;

  /// No description provided for @chatListSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{state} · Reserva {booking}\n{preview}'**
  String chatListSubtitle(String state, String booking, String preview);

  /// No description provided for @chatListFirstHello.
  ///
  /// In es, this message translates to:
  /// **'Sé el primero en saludar'**
  String get chatListFirstHello;

  /// No description provided for @chatListNewer.
  ///
  /// In es, this message translates to:
  /// **'Más recientes'**
  String get chatListNewer;

  /// No description provided for @chatListOlder.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get chatListOlder;

  /// No description provided for @chatDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Tu conversación'**
  String get chatDefaultName;

  /// No description provided for @chatSafety.
  ///
  /// In es, this message translates to:
  /// **'Seguridad de la conversación'**
  String get chatSafety;

  /// No description provided for @chatRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar conversación'**
  String get chatRefresh;

  /// No description provided for @chatPrivate.
  ///
  /// In es, this message translates to:
  /// **'Conversación privada'**
  String get chatPrivate;

  /// No description provided for @chatLinkConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get chatLinkConnecting;

  /// No description provided for @chatLinkPaused.
  ///
  /// In es, this message translates to:
  /// **'En pausa'**
  String get chatLinkPaused;

  /// No description provided for @chatLinkConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get chatLinkConnected;

  /// No description provided for @chatLinkReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura'**
  String get chatLinkReadOnly;

  /// No description provided for @chatLinkOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get chatLinkOffline;

  /// No description provided for @chatLinkReconnecting.
  ///
  /// In es, this message translates to:
  /// **'Reconectando…'**
  String get chatLinkReconnecting;

  /// No description provided for @chatBookingWritable.
  ///
  /// In es, this message translates to:
  /// **'Reserva {booking} · Coordina los detalles de tu plan.'**
  String chatBookingWritable(String booking);

  /// No description provided for @chatBookingReadOnly.
  ///
  /// In es, this message translates to:
  /// **'Reserva {booking} · El historial se conserva en solo lectura.'**
  String chatBookingReadOnly(String booking);

  /// No description provided for @chatRetryConnection.
  ///
  /// In es, this message translates to:
  /// **'Reintentar conexión'**
  String get chatRetryConnection;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Un saludo abre la conversación'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Los mensajes de esta reserva aparecerán aquí.'**
  String get chatEmptyMessage;

  /// No description provided for @chatLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get chatLoading;

  /// No description provided for @chatLoadOlder.
  ///
  /// In es, this message translates to:
  /// **'Cargar mensajes anteriores'**
  String get chatLoadOlder;

  /// No description provided for @chatYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get chatYou;

  /// No description provided for @chatSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get chatSaved;

  /// No description provided for @chatMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get chatMessage;

  /// No description provided for @chatMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje…'**
  String get chatMessageHint;

  /// No description provided for @chatRetrySend.
  ///
  /// In es, this message translates to:
  /// **'Reintentar envío'**
  String get chatRetrySend;

  /// No description provided for @chatSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get chatSend;

  /// No description provided for @chatTooLong.
  ///
  /// In es, this message translates to:
  /// **'Usa hasta 2000 caracteres por mensaje.'**
  String get chatTooLong;

  /// No description provided for @chatInterrupted.
  ///
  /// In es, this message translates to:
  /// **'Se interrumpió la conexión. Reintentaremos sin perder el historial.'**
  String get chatInterrupted;

  /// No description provided for @chatErrorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa el motivo y la descripción antes de continuar.'**
  String get chatErrorInvalid;

  /// No description provided for @chatErrorForbidden.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no tiene permiso para esta acción.'**
  String get chatErrorForbidden;

  /// No description provided for @chatErrorSession.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión venció. Vuelve a ingresar para continuar.'**
  String get chatErrorSession;

  /// No description provided for @chatErrorGone.
  ///
  /// In es, this message translates to:
  /// **'Esta conversación ya no está disponible para tu cuenta.'**
  String get chatErrorGone;

  /// No description provided for @chatErrorChanged.
  ///
  /// In es, this message translates to:
  /// **'La reserva cambió de estado. Actualiza la conversación.'**
  String get chatErrorChanged;

  /// No description provided for @chatErrorBusy.
  ///
  /// In es, this message translates to:
  /// **'Hay demasiadas conexiones. Reintentaremos en unos momentos.'**
  String get chatErrorBusy;

  /// No description provided for @chatErrorUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar. Conservamos tu mensaje para reintentar aquí.'**
  String get chatErrorUnavailable;

  /// No description provided for @reportStatusOpen.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de revisión'**
  String get reportStatusOpen;

  /// No description provided for @reportStatusHandled.
  ///
  /// In es, this message translates to:
  /// **'Reporte atendido'**
  String get reportStatusHandled;

  /// No description provided for @reportStatusDismissed.
  ///
  /// In es, this message translates to:
  /// **'Reporte desestimado'**
  String get reportStatusDismissed;

  /// No description provided for @reportStatusReceived.
  ///
  /// In es, this message translates to:
  /// **'Reporte recibido'**
  String get reportStatusReceived;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In es, this message translates to:
  /// **'Acoso o amenazas'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o publicidad'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonOther.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get reportReasonOther;

  /// No description provided for @reportReasonGeneric.
  ///
  /// In es, this message translates to:
  /// **'Reporte'**
  String get reportReasonGeneric;

  /// No description provided for @safetyLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las opciones de seguridad. Inténtalo de nuevo.'**
  String get safetyLoadFailed;

  /// No description provided for @safetyChangeFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el cambio. Actualiza para comprobar su estado antes de reintentar.'**
  String get safetyChangeFailed;

  /// No description provided for @safetyUnblockTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Retirar tu bloqueo?'**
  String get safetyUnblockTitle;

  /// No description provided for @safetyBlockTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Bloquear esta conversación?'**
  String get safetyBlockTitle;

  /// No description provided for @safetyUnblockMessage.
  ///
  /// In es, this message translates to:
  /// **'Se podrá conversar si la otra persona tampoco mantiene un bloqueo y la reserva sigue activa.'**
  String get safetyUnblockMessage;

  /// No description provided for @safetyBlockMessage.
  ///
  /// In es, this message translates to:
  /// **'Se detendrán los mensajes nuevos de ambos participantes. Conservarás el historial. La reserva y sus condiciones siguen vigentes.'**
  String get safetyBlockMessage;

  /// No description provided for @safetyBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get safetyBack;

  /// No description provided for @safetyConfirmUnblock.
  ///
  /// In es, this message translates to:
  /// **'Retirar bloqueo'**
  String get safetyConfirmUnblock;

  /// No description provided for @safetyConfirmBlock.
  ///
  /// In es, this message translates to:
  /// **'Confirmar bloqueo'**
  String get safetyConfirmBlock;

  /// No description provided for @safetyRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar seguridad'**
  String get safetyRefresh;

  /// No description provided for @safetyHeadline.
  ///
  /// In es, this message translates to:
  /// **'Tu tranquilidad importa'**
  String get safetyHeadline;

  /// No description provided for @safetyIntro.
  ///
  /// In es, this message translates to:
  /// **'Estas opciones se aplican a esta conversación. Bloquear y reportar son decisiones independientes.'**
  String get safetyIntro;

  /// No description provided for @safetyRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get safetyRetry;

  /// No description provided for @safetyBlocked.
  ///
  /// In es, this message translates to:
  /// **'Conversación bloqueada'**
  String get safetyBlocked;

  /// No description provided for @safetyControl.
  ///
  /// In es, this message translates to:
  /// **'Controla quién puede escribirte'**
  String get safetyControl;

  /// No description provided for @safetyOwnBlock.
  ///
  /// In es, this message translates to:
  /// **'Mantienes un bloqueo activo. Puedes retirarlo cuando quieras.'**
  String get safetyOwnBlock;

  /// No description provided for @safetyOtherBlock.
  ///
  /// In es, this message translates to:
  /// **'Hay un bloqueo activo de la otra persona. El historial sigue disponible.'**
  String get safetyOtherBlock;

  /// No description provided for @safetyCanBlock.
  ///
  /// In es, this message translates to:
  /// **'Puedes detener los mensajes nuevos sin borrar el historial.'**
  String get safetyCanBlock;

  /// No description provided for @safetyRemoveOwnBlock.
  ///
  /// In es, this message translates to:
  /// **'Retirar mi bloqueo'**
  String get safetyRemoveOwnBlock;

  /// No description provided for @safetyBlock.
  ///
  /// In es, this message translates to:
  /// **'Bloquear conversación'**
  String get safetyBlock;

  /// No description provided for @safetyReportPending.
  ///
  /// In es, this message translates to:
  /// **'Puedes actualizar esta pantalla para consultar el estado de tu reporte. No necesitas enviarlo otra vez.'**
  String get safetyReportPending;

  /// No description provided for @safetyReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar un problema'**
  String get safetyReportTitle;

  /// No description provided for @safetyReportNotice.
  ///
  /// In es, this message translates to:
  /// **'El equipo de moderación podrá consultar tu descripción y el historial existente al enviar el reporte. Cada consulta requiere una justificación y queda registrada. No incluyas contraseñas ni información privada ajena al incidente.'**
  String get safetyReportNotice;

  /// No description provided for @safetyReason.
  ///
  /// In es, this message translates to:
  /// **'Motivo del reporte'**
  String get safetyReason;

  /// No description provided for @safetyDetail.
  ///
  /// In es, this message translates to:
  /// **'Describe qué ocurrió'**
  String get safetyDetail;

  /// No description provided for @safetyDetailTooShort.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos lo ocurrido en al menos 10 caracteres.'**
  String get safetyDetailTooShort;

  /// No description provided for @safetySendReport.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte'**
  String get safetySendReport;

  /// No description provided for @safetyManualReview.
  ///
  /// In es, this message translates to:
  /// **'Los reportes se revisan manualmente. Su envío no cancela la reserva ni modifica sus condiciones.'**
  String get safetyManualReview;

  /// No description provided for @moderationRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar reportes'**
  String get moderationRefresh;

  /// No description provided for @moderationFilterOpen.
  ///
  /// In es, this message translates to:
  /// **'Abiertos'**
  String get moderationFilterOpen;

  /// No description provided for @moderationFilterHandled.
  ///
  /// In es, this message translates to:
  /// **'Atendidos'**
  String get moderationFilterHandled;

  /// No description provided for @moderationFilterDismissed.
  ///
  /// In es, this message translates to:
  /// **'Desestimados'**
  String get moderationFilterDismissed;

  /// No description provided for @moderationFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get moderationFilterAll;

  /// No description provided for @moderationForbidden.
  ///
  /// In es, this message translates to:
  /// **'Acceso reservado al equipo de moderación.'**
  String get moderationForbidden;

  /// No description provided for @moderationLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los reportes. Inténtalo de nuevo.'**
  String get moderationLoadFailed;

  /// No description provided for @moderationDateUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Fecha no disponible'**
  String get moderationDateUnavailable;

  /// No description provided for @moderationPending.
  ///
  /// In es, this message translates to:
  /// **'Casos pendientes'**
  String get moderationPending;

  /// No description provided for @moderationHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de reportes'**
  String get moderationHistory;

  /// No description provided for @moderationIntro.
  ///
  /// In es, this message translates to:
  /// **'Consulta el estado y las fechas de cada reporte. Los casos donde participas quedan excluidos. El contenido de un caso abierto requiere una consulta justificada y registrada.'**
  String get moderationIntro;

  /// No description provided for @moderationOrder.
  ///
  /// In es, this message translates to:
  /// **'Ordenados por fecha del reporte, del más antiguo al más reciente.'**
  String get moderationOrder;

  /// No description provided for @moderationRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get moderationRetry;

  /// No description provided for @moderationEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes para este filtro en esta página.'**
  String get moderationEmpty;

  /// No description provided for @moderationStatusUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Estado no disponible'**
  String get moderationStatusUnavailable;

  /// No description provided for @moderationCaseRef.
  ///
  /// In es, this message translates to:
  /// **'Caso {caseId} · Reserva {booking}'**
  String moderationCaseRef(String caseId, String booking);

  /// No description provided for @moderationReported.
  ///
  /// In es, this message translates to:
  /// **'Reportado: {date}'**
  String moderationReported(String date);

  /// No description provided for @moderationClosedAt.
  ///
  /// In es, this message translates to:
  /// **'Cierre: {date}'**
  String moderationClosedAt(String date);

  /// No description provided for @moderationClosedNote.
  ///
  /// In es, this message translates to:
  /// **'Caso cerrado. La consulta del contenido está deshabilitada.'**
  String get moderationClosedNote;

  /// No description provided for @moderationPage.
  ///
  /// In es, this message translates to:
  /// **'Página {page}'**
  String moderationPage(int page);

  /// No description provided for @moderationPrevious.
  ///
  /// In es, this message translates to:
  /// **'Anteriores'**
  String get moderationPrevious;

  /// No description provided for @moderationNext.
  ///
  /// In es, this message translates to:
  /// **'Siguientes'**
  String get moderationNext;

  /// No description provided for @moderationAccessFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos autorizar la consulta. El caso puede estar cerrado o fuera de tu acceso.'**
  String get moderationAccessFailed;

  /// No description provided for @moderationCloseTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar este caso?'**
  String get moderationCloseTitle;

  /// No description provided for @moderationCloseHandled.
  ///
  /// In es, this message translates to:
  /// **'Se registrará como atendido junto a tu justificación. El cierre no aplica sanciones ni retira bloqueos.'**
  String get moderationCloseHandled;

  /// No description provided for @moderationCloseDismissed.
  ///
  /// In es, this message translates to:
  /// **'Se registrará como desestimado junto a tu justificación. El cierre no aplica sanciones ni retira bloqueos.'**
  String get moderationCloseDismissed;

  /// No description provided for @moderationBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get moderationBack;

  /// No description provided for @moderationConfirmClose.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cierre'**
  String get moderationConfirmClose;

  /// No description provided for @moderationCloseFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el cierre. Actualiza la cola para comprobar su estado.'**
  String get moderationCloseFailed;

  /// No description provided for @moderationCaseTitle.
  ///
  /// In es, this message translates to:
  /// **'Caso {caseId}'**
  String moderationCaseTitle(String caseId);

  /// No description provided for @moderationHeadline.
  ///
  /// In es, this message translates to:
  /// **'Consulta con responsabilidad'**
  String get moderationHeadline;

  /// No description provided for @moderationCaseIntro.
  ///
  /// In es, this message translates to:
  /// **'Solo se permite revisar el historial existente al enviar este reporte. Cada consulta y cada cierre registran tu identidad, justificación y hora. No copies información fuera del proceso de moderación.'**
  String get moderationCaseIntro;

  /// No description provided for @moderationJustification.
  ///
  /// In es, this message translates to:
  /// **'Justificación de la consulta o resolución'**
  String get moderationJustification;

  /// No description provided for @moderationJustificationTooShort.
  ///
  /// In es, this message translates to:
  /// **'Escribe una justificación de al menos 10 caracteres.'**
  String get moderationJustificationTooShort;

  /// No description provided for @moderationAccess.
  ///
  /// In es, this message translates to:
  /// **'Consultar y registrar acceso'**
  String get moderationAccess;

  /// No description provided for @moderationLinkedHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial asociado al reporte'**
  String get moderationLinkedHistory;

  /// No description provided for @moderationReporter.
  ///
  /// In es, this message translates to:
  /// **'Quien reportó'**
  String get moderationReporter;

  /// No description provided for @moderationOtherPerson.
  ///
  /// In es, this message translates to:
  /// **'Otra persona'**
  String get moderationOtherPerson;

  /// No description provided for @moderationOlder.
  ///
  /// In es, this message translates to:
  /// **'Consultar mensajes anteriores y registrar acceso'**
  String get moderationOlder;

  /// No description provided for @moderationResolveHint.
  ///
  /// In es, this message translates to:
  /// **'Describe la gestión realizada en la justificación antes de cerrar el caso.'**
  String get moderationResolveHint;

  /// No description provided for @moderationMarkHandled.
  ///
  /// In es, this message translates to:
  /// **'Marcar atendido'**
  String get moderationMarkHandled;

  /// No description provided for @moderationDismiss.
  ///
  /// In es, this message translates to:
  /// **'Desestimar reporte'**
  String get moderationDismiss;
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
