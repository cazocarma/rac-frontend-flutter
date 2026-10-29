// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get updatedRules => 'Actualizamos nuestras reglas';

  @override
  String get readDocuments =>
      'Revisa las versiones pendientes antes de continuar. La operación original no se repetirá automáticamente.';

  @override
  String get acceptContinue => 'Aceptar y continuar';

  @override
  String get explicitConsent => 'He leído y acepto las versiones indicadas.';

  @override
  String get readFullText => 'Leer texto completo';

  @override
  String get readDone => 'He leído esta versión';

  @override
  String get savingConsent => 'Guardando…';

  @override
  String get documentsUnavailable =>
      'No pudimos cargar las versiones pendientes. Vuelve a la acción original para actualizarlas.';

  @override
  String get consentFailed =>
      'No pudimos guardar la aceptación. Puedes reintentar.';

  @override
  String get documentsChanged =>
      'Los documentos cambiaron. Vuelve a la acción original para revisar las versiones vigentes.';

  @override
  String get backToAction => 'Volver a la acción';

  @override
  String get privacyEscape => 'Ver mis datos o eliminar mi cuenta';

  @override
  String get privacyTitle => 'Tus datos y derechos';

  @override
  String get privacyPending =>
      'En construcción: las solicitudes de exportación y eliminación aún no están disponibles. No hemos enviado ninguna solicitud. Puedes consultar tu perfil sin aceptar documentos.';

  @override
  String get viewProfile => 'Ver mis datos de perfil';

  @override
  String pendingVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get documentReadFailed =>
      'No pudimos abrir esta versión exacta. Inténtalo nuevamente.';

  @override
  String get compaRulesTitle => 'Reglas para ser compa';

  @override
  String get compaRulesIntro =>
      'Revisa cada declaración y responde las tres situaciones. Aprobar este paso no publica tu perfil ni verifica tu identidad.';

  @override
  String get compaRulesReview => 'Revisar reglas y cuestionario';

  @override
  String get compaRulesSubmit => 'Confirmar declaraciones y respuestas';

  @override
  String get compaRulesPassed =>
      'Ya completaste esta versión del cuestionario.';

  @override
  String get compaRulesUnavailable =>
      'En construcción: todavía no hay un cuestionario revisado disponible para tu cuenta o no pudimos cargarlo.';

  @override
  String get compaRulesRetry => 'Volver a cargar';

  @override
  String get compaRulesWrong =>
      'Revisa las tres situaciones. Todas deben responderse correctamente.';

  @override
  String get compaRulesDeclarations =>
      'Marca cada declaración por separado antes de continuar.';

  @override
  String get compaRulesChanged =>
      'La versión cambió. Vuelve a cargar el cuestionario y revisa todas las declaraciones nuevamente.';

  @override
  String get compaRulesFailed =>
      'No pudimos guardar tus respuestas. Se conservan para que puedas reintentar.';

  @override
  String get compaRulesContinue => 'Continuar';

  @override
  String get compaRulesSaving => 'Guardando…';

  @override
  String get documentHistoryTitle => 'Historial de aceptaciones';

  @override
  String get documentHistoryEmpty => 'Aún no has registrado aceptaciones.';

  @override
  String get documentHistoryFailed =>
      'No pudimos cargar el historial. Puedes reintentar.';

  @override
  String get documentHistoryMore => 'Cargar más';

  @override
  String get documentHistoryRetry => 'Reintentar';

  @override
  String get documentHistoryAccount => 'Cuenta';

  @override
  String get documentHistoryOnboarding => 'Registro como compa';

  @override
  String get documentHistoryBooking => 'Reserva';

  @override
  String documentHistoryAt(String date, String context) {
    return 'Aceptado: $date · $context';
  }

  @override
  String get compaPrerequisitesPending =>
      'Completa los documentos y reglas pendientes. Luego vuelve a activar tu perfil; conservamos lo que escribiste.';

  @override
  String get staffTitle => 'Consola de gestión';

  @override
  String get staffAccess => 'Acceso del equipo';

  @override
  String get staffAccessHelp =>
      'Usa tu cuenta del equipo y el segundo factor de autenticación.';

  @override
  String get staffSignIn => 'Ingresar con MFA';

  @override
  String get staffSignOut => 'Cerrar sesión del equipo';

  @override
  String get staffUnavailable =>
      'No pudimos validar el acceso. Reintenta o inicia sesión nuevamente.';

  @override
  String get staffDenied => 'Esta cuenta no tiene acceso a la consola.';

  @override
  String get staffReady => 'Sesión del equipo validada';

  @override
  String get staffRetry => 'Reintentar';

  @override
  String get staffPending =>
      'Las herramientas editoriales están en construcción.';

  @override
  String get staffReadRevision => 'Consultar revisión exacta';

  @override
  String get staffResource => 'Tipo de recurso';

  @override
  String get staffDocument => 'Documento';

  @override
  String get staffAssessment => 'Cuestionario privado';

  @override
  String get staffReference => 'Identificador de revisión (UUID)';

  @override
  String get staffRevisionUnavailable =>
      'No pudimos consultar esta revisión. Comprueba el identificador y tu acceso.';

  @override
  String get staffConfirmDecision => 'Confirmar decisión';

  @override
  String get staffCancel => 'Cancelar';

  @override
  String get staffApprove => 'Aprobar revisión';

  @override
  String get staffReject => 'Rechazar revisión';

  @override
  String get staffPublish => 'Publicar revisión';

  @override
  String get staffReadAcknowledgement =>
      'He revisado el contenido completo y su versión exacta.';

  @override
  String get staffDecisionFailed =>
      'No pudimos completar la operación. Revisa tu acceso o vuelve a intentarlo.';

  @override
  String get staffDecisionCompleted =>
      'Operación confirmada. Consulta la revisión para ver su estado actualizado.';

  @override
  String get staffPendingRecovery =>
      'Hay comandos pendientes de confirmar. Reintenta el mismo comando o vuelve a autenticarte.';

  @override
  String get staffRetrySameCommand => 'Reintentar el mismo comando';

  @override
  String get staffCreateDraft => 'Crear borrador de documento';

  @override
  String get staffConfirmDraft => 'Confirmar borrador';

  @override
  String get staffDraftHelp =>
      'El borrador es inmutable. Requiere revisión de otra persona antes de publicarse; crearlo no activa nuevas obligaciones.';

  @override
  String get staffDocumentKind => 'Documento';

  @override
  String get staffClientTerms => 'Términos para clientes';

  @override
  String get staffCompaTerms => 'Términos para Compas';

  @override
  String get staffCommunityRules => 'Normas de comunidad';

  @override
  String get staffPrivacy => 'Privacidad';

  @override
  String get staffSafetyRules => 'Normas de seguridad';

  @override
  String get staffVersion => 'Versión';

  @override
  String get staffLocale => 'Idioma';

  @override
  String get staffMaterialChange => '¿Requiere renovar la aceptación?';

  @override
  String get staffMaterialYes => 'Sí, cambio material';

  @override
  String get staffMaterialNo => 'No, cambio no material';

  @override
  String get staffDocumentContent => 'Texto completo';

  @override
  String get staffDraftInvalid =>
      'Revisa las selecciones, la versión y el texto. El máximo es 128 KiB de texto UTF-8.';

  @override
  String get staffCreateAssessment => 'Crear cuestionario privado';

  @override
  String get staffConfirmAssessment => 'Confirmar cuestionario';

  @override
  String get staffPrivateAssessmentHelp =>
      'Incluye cinco compromisos y tres preguntas. Selecciona explícitamente las respuestas correctas. La clave es privada y el servidor calcula el hash de la revisión.';

  @override
  String get staffNoSubstances => 'Compromiso sobre sustancias ilícitas';

  @override
  String get staffNoSexualServices => 'Compromiso sobre servicios sexuales';

  @override
  String get staffCatalogOnly => 'Compromiso sobre actividades permitidas';

  @override
  String get staffAdultsOnly => 'Compromiso de mayoría de edad';

  @override
  String get staffEnforcement => 'Compromiso sobre medidas y apelación';

  @override
  String get staffQuestion => 'Pregunta';

  @override
  String get staffOption => 'Alternativa';

  @override
  String get staffCorrectOption => 'Respuesta correcta';

  @override
  String get staffAddOption => 'Agregar alternativa';

  @override
  String get staffRemoveOption => 'Quitar última alternativa';

  @override
  String get staffAssessmentInvalid =>
      'Completa los compromisos, preguntas, alternativas y respuestas correctas. Revisa también versión e idioma.';

  @override
  String get staffActivateBundle => 'Activar conjunto de documentos';

  @override
  String get staffPrepareActivation => 'Consultar y preparar activación';

  @override
  String get staffConfirmActivation => 'Confirmar activación del conjunto';

  @override
  String get staffRegistryVersion => 'Versión del conjunto';

  @override
  String get staffActivationHelp =>
      'Se activarán cinco documentos y un cuestionario ya revisados y publicados. La versión se consulta al servidor; si cambia antes de confirmar, debes revisar y preparar nuevamente el conjunto.';

  @override
  String get staffActivationSummary =>
      'Resumen de cambios (hasta tres líneas, opcional)';

  @override
  String get staffActivationInvalid =>
      'No pudimos preparar este conjunto. Revisa referencias, idioma, publicaciones y resumen; vuelve a consultar antes de confirmar.';

  @override
  String get staffStepUpRequired =>
      'Tu verificación de seguridad venció. Ingresa nuevamente con MFA para continuar con el mismo comando.';

  @override
  String get compaTitle => 'Sé Compa';

  @override
  String get compaAddAvailability =>
      'Agrega al menos un horario para recibir reservas.';

  @override
  String get compaPublished => 'Tu perfil compa se guardó correctamente.';

  @override
  String get compaSessionPending =>
      'Tu perfil se guardó, pero no pudimos actualizar los permisos de tu sesión. Pulsa Actualizar sesión para continuar.';

  @override
  String get compaSaveFailed =>
      'No pudimos guardar tu perfil. Revisa tu conexión e inténtalo nuevamente. Tus cambios anteriores se conservan.';

  @override
  String get compaWindowsLimit => 'Hasta 3 franjas por día.';

  @override
  String get compaWindowFormat => 'Usa HH:mm-HH:mm, por ejemplo 18:00-22:00.';

  @override
  String get compaWindowsOverlap =>
      'Revisa el orden y evita horarios superpuestos.';

  @override
  String get compaLoadFailed => 'No pudimos cargar tu perfil';

  @override
  String get compaConnectionRetry =>
      'Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get compaRetry => 'Reintentar';

  @override
  String get compaProfileHeading => 'Tu perfil como compa';

  @override
  String get compaStartHeading => 'Comparte lo que te gusta hacer';

  @override
  String get compaPublishingInfo =>
      'Configura las actividades que ofreces y tus horarios. Revisa las reglas y los documentos antes de continuar.';

  @override
  String get compaAboutLabel => 'Cuéntanos sobre ti';

  @override
  String get compaAboutHint =>
      'Qué actividades ofreces y cómo será compartir contigo';

  @override
  String get compaAboutShort =>
      'Cuéntanos un poco más: al menos 20 caracteres.';

  @override
  String get compaRateLabel => 'Tarifa por hora (CLP)';

  @override
  String get compaRateHelp =>
      'Valor referencial. Los cobros están en construcción.';

  @override
  String get compaRateInvalid =>
      'Ingresa un monto válido, con hasta 2 decimales.';

  @override
  String get compaSkillsLabel => 'Habilidades';

  @override
  String get compaSkillsHint => 'asado, cine, running';

  @override
  String get compaSkillsHelp => 'Separa con comas. Entre 1 y 8 habilidades.';

  @override
  String get compaSkillsInvalid =>
      'Agrega de 1 a 8 habilidades, de 2 a 40 caracteres cada una.';

  @override
  String get compaAvailabilityHeading => 'Tu disponibilidad semanal';

  @override
  String get compaAvailabilityHelp =>
      'Escribe las horas de tu zona. Deja vacío un día si no estás disponible. Puedes agregar hasta 3 franjas separadas por comas; por ejemplo 15:00-18:00, 20:00-23:00. Las reservas existentes mantienen su fecha y hora.';

  @override
  String get compaTimeZone => 'Zona horaria';

  @override
  String get compaSaving => 'Guardando…';

  @override
  String get compaSaveChanges => 'Guardar cambios';

  @override
  String get compaActivateProfile => 'Publicar mi perfil';

  @override
  String get compaLoginFailed =>
      'No pudimos abrir el acceso. Inténtalo otra vez.';

  @override
  String get compaRefreshSession => 'Actualizar sesión';

  @override
  String get compaOpenAgenda => 'Ir a mi agenda';

  @override
  String get compaMonday => 'Lunes';

  @override
  String get compaTuesday => 'Martes';

  @override
  String get compaWednesday => 'Miércoles';

  @override
  String get compaThursday => 'Jueves';

  @override
  String get compaFriday => 'Viernes';

  @override
  String get compaSaturday => 'Sábado';

  @override
  String get compaSunday => 'Domingo';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsPreferences => 'Preferencias';

  @override
  String get settingsHeading => 'A tu manera';

  @override
  String get settingsDescription =>
      'Personaliza cómo se ve RAC en este dispositivo.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsSystem => 'Usar configuración del dispositivo';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsDocuments => 'Documentos y acuerdos';

  @override
  String get settingsDocumentsHelp =>
      'Consulta las versiones y tus aceptaciones.';

  @override
  String get commonConstruction => 'En construcción';

  @override
  String get settingsPending =>
      'Preferencias de notificaciones, privacidad e idioma.';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navBookings => 'Mis reservas';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get navPayments => 'Planes y pagos';

  @override
  String get navNotifications => 'Notificaciones';

  @override
  String get navProfile => 'Mi perfil';

  @override
  String get navTagline => 'Tiempo para compartir.';

  @override
  String get navSpace => 'TU ESPACIO';

  @override
  String get navAdmin => 'Administración';

  @override
  String get navShare => 'Comparte lo que te gusta';

  @override
  String get navProfileInfo =>
      'Configura tu perfil y disponibilidad para compartir actividades.';

  @override
  String get navLogout => 'Salir';

  @override
  String get navExploreTitle => 'Explorar compas';

  @override
  String get navOpenNotifications => 'Ver notificaciones';

  @override
  String get navBookingsShort => 'Reservas';

  @override
  String get navProfileShort => 'Perfil';

  @override
  String get accessFailed => 'No pudimos iniciar sesión. Inténtalo nuevamente.';

  @override
  String get accessStory => 'Los mejores planes\nse comparten.';

  @override
  String get accessStoryHelp =>
      'Una caminata, un café o algo nuevo.\nEncuentra con quién disfrutarlo.';

  @override
  String get accessBrandLine => 'RENT-A-COMPA · BUENA COMPAÑÍA';

  @override
  String get accessHeading => 'Tu próximo plan\nempieza aquí.';

  @override
  String get accessDescription =>
      'Conoce compas, encuentra intereses en común y organiza tiempo para compartir.';

  @override
  String get accessMovies => 'Cine';

  @override
  String get accessRunning => 'Running';

  @override
  String get accessKaraoke => 'Karaoke';

  @override
  String get accessOpening => 'Abriendo inicio de sesión…';

  @override
  String get accessContinue => 'Ingresar o crear cuenta';

  @override
  String get accessReturn => 'Al ingresar, volverás automáticamente a RAC.';
}
