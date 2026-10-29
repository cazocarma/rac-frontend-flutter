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
