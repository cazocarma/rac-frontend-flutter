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

  @override
  String get documentTermsClient => 'Términos para clientes';

  @override
  String get documentTermsCompa => 'Términos para compas';

  @override
  String get documentCommunity => 'Reglas de la comunidad';

  @override
  String get documentPrivacy => 'Privacidad';

  @override
  String get documentSafety => 'Reglas de seguridad';

  @override
  String get documentGeneric => 'Documento';

  @override
  String get documentsLoadFailed => 'No pudimos cargar los documentos';

  @override
  String get documentsRetryLater => 'Inténtalo otra vez en unos momentos.';

  @override
  String get documentsRetry => 'Reintentar';

  @override
  String get documentsPendingReview =>
      'Los documentos estarán disponibles cuando termine su revisión.';

  @override
  String get documentsAccount => 'Tu cuenta';

  @override
  String get documentsHeading => 'Información y acuerdos';

  @override
  String get documentsDescription =>
      'Consulta cada versión y revisa cuáles has aceptado.';

  @override
  String get documentsNotAccepted => 'Sin aceptar';

  @override
  String get documentsAccepted => 'Aceptada';

  @override
  String get readerDocumentsChanged =>
      'Los documentos cambiaron. Vuelve a la lista para actualizarlos.';

  @override
  String get documentsAcceptFailed =>
      'No pudimos confirmar la aceptación. Puedes reintentar.';

  @override
  String get documentsOpenFailed => 'No pudimos abrir esta versión';

  @override
  String get documentsReturnRefresh =>
      'Vuelve a intentarlo o regresa a la lista para actualizarla.';

  @override
  String get documentsAlreadyAccepted => 'Ya aceptaste esta versión.';

  @override
  String get documentsConsent => 'Acepto esta versión del documento.';

  @override
  String get documentsConfirm => 'Confirmar aceptación';

  @override
  String documentVersion(String version) {
    return 'Versión $version';
  }

  @override
  String documentsVersionStatus(String version, String status) {
    return 'Versión $version · $status';
  }

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsUpdateFailed =>
      'No pudimos actualizar la notificación. Inténtalo otra vez.';

  @override
  String get notificationsAllFailed =>
      'No pudimos marcar tus avisos. Actualiza para comprobar su estado.';

  @override
  String get notificationsAccount => 'Cuenta';

  @override
  String get notificationsBooking => 'Reserva';

  @override
  String notificationsBookingReference(String reference) {
    return 'Reserva $reference';
  }

  @override
  String get notificationsRefresh => 'Actualizar notificaciones';

  @override
  String get notificationsLoadFailed => 'No pudimos cargar tus notificaciones';

  @override
  String get notificationsRetryMessage =>
      'Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get notificationsRetry => 'Reintentar';

  @override
  String get notificationsHeading => 'Novedades de tu cuenta y reservas';

  @override
  String get notificationsDescription =>
      'Aquí verás cambios de tu cuenta y tus reservas. Avisos por correo y al teléfono: en construcción.';

  @override
  String notificationsUnread(int count) {
    return '$count sin leer en tu bandeja';
  }

  @override
  String get notificationsUpdating => 'Actualizando…';

  @override
  String get notificationsMarkAll => 'Marcar todas como leídas';

  @override
  String get notificationsCaughtUp => 'Estás al día';

  @override
  String get notificationsEmptyMessage =>
      'Los próximos cambios de tu cuenta y tus reservas aparecerán aquí.';

  @override
  String get notificationsNew => 'Nueva';

  @override
  String get notificationsMarkRead => 'Marcar como leída';

  @override
  String get notificationsViewAccount => 'Ver estado de mi cuenta';

  @override
  String get notificationsViewBookings => 'Ver mis reservas';

  @override
  String get notificationsNewer => 'Más recientes';

  @override
  String get notificationsOlder => 'Anteriores';

  @override
  String get plansTitle => 'Planes y suscripción';

  @override
  String get plansEyebrow => 'A tu ritmo';

  @override
  String get plansHeading => 'Empieza gratis. Crece a tu ritmo.';

  @override
  String get plansDescription =>
      'La suscripción amplía tu capacidad para aceptar reservas como compa.';

  @override
  String get plansPending =>
      'Las solicitudes que superen tu cupo permanecen pendientes. Tú decides cuáles confirmar cuando tengas capacidad disponible.';

  @override
  String get plansPaidTitle => 'Más espacio para crecer';

  @override
  String get plansFreeTitle => 'Plan gratuito';

  @override
  String get plansPreparing => 'Estamos preparando la suscripción.';

  @override
  String get plansWeekly => '3 reservas por semana';

  @override
  String get plansRequests => 'Recibe solicitudes sin límite de cupos.';

  @override
  String get plansConfirm => 'Confirma hasta 3 reservas cada semana.';

  @override
  String get plansProfile => 'Publica tu perfil y administra tu agenda.';

  @override
  String get plansWeekRules =>
      'El cupo se calcula de lunes a domingo, según la fecha de la actividad y la zona horaria de Chile. Si cancelas antes del inicio, recuperas el cupo; después del inicio, se mantiene consumido.';

  @override
  String get plansAcceptMore =>
      'Acepta más reservas con una suscripción activa.';

  @override
  String get plansControl =>
      'Conserva el control de tus solicitudes pendientes.';

  @override
  String get plansPaymentDetails =>
      'Estamos definiendo el precio, la renovación y el proveedor de pago. No se realizarán cobros ni se simularán suscripciones. Tus solicitudes no se aceptarán automáticamente.';

  @override
  String get plansPaymentsConstruction => 'Pagos en construcción';

  @override
  String get allowanceLoadFailed => 'No pudimos consultar tus cupos';

  @override
  String get allowanceRetry => 'Reintentar cupos';

  @override
  String get allowanceRefresh => 'Actualizar cupos';

  @override
  String get allowanceActive => 'Suscripción activa';

  @override
  String allowanceAvailable(int available, int limit) {
    return '$available de $limit cupos gratuitos disponibles';
  }

  @override
  String allowanceWeek(String date, int used) {
    return 'Semana del $date · Chile · $used reservas confirmadas';
  }

  @override
  String get allowanceSelectWeek => 'Consultar otra semana';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileLoadFailed => 'No pudimos cargar tu perfil.';

  @override
  String get profileSaved => 'Tu perfil se guardó correctamente';

  @override
  String get profileSaveFailed =>
      'No pudimos guardar tus cambios. Se conservan en el formulario; vuelve a intentarlo.';

  @override
  String get profilePhotoLoadFailed =>
      'No pudimos cargar tu foto. Puedes volver a intentarlo.';

  @override
  String get profilePhotoTooLarge => 'La imagen debe pesar como máximo 5 MB.';

  @override
  String get profilePhotoFormat => 'Elige una foto JPG o PNG.';

  @override
  String get profilePhotoInvalid =>
      'Elige una imagen JPG o PNG válida, entre 32 y 4096 píxeles por lado y hasta 12 megapíxeles.';

  @override
  String get profilePhotoBusy =>
      'Estamos procesando otras fotos. Inténtalo en unos segundos.';

  @override
  String get profilePhotoSaveFailed =>
      'No pudimos confirmar el guardado de tu foto. Inténtalo nuevamente.';

  @override
  String get profilePhotoConfirm => 'Confirma tu foto';

  @override
  String get profilePhotoPreviewNote =>
      'Se recortará al centro en formato cuadrado. Será pública al activar tu perfil compa.';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profilePhotoSave => 'Guardar foto';

  @override
  String get profilePhotoSaved => 'Tu foto se guardó correctamente';

  @override
  String get profilePhotoProcessFailed =>
      'No pudimos procesar la foto. Inténtalo nuevamente.';

  @override
  String get profilePhotoRemoveTitle => '¿Quitar tu foto?';

  @override
  String get profilePhotoRemoveNote =>
      'Tu perfil volverá a mostrar tu inicial.';

  @override
  String get profilePhotoKeep => 'Conservar';

  @override
  String get profilePhotoRemove => 'Quitar foto';

  @override
  String get profilePhotoRemoveFailed =>
      'No pudimos quitar tu foto. Inténtalo nuevamente.';

  @override
  String get profilePublicPreview => 'Vista previa pública';

  @override
  String get profilePreviewTitle => 'Así se verá tu presentación';

  @override
  String get profilePreviewNote =>
      'Esta vista incluye tus cambios sin guardar. No publica ni activa tu perfil compa.';

  @override
  String get profileNameValidation => 'Ingresa al menos dos caracteres';

  @override
  String get profilePhoneValidation => 'Ingresa un teléfono válido';

  @override
  String get profileInterestsValidation =>
      'Máximo 15 intereses de 40 caracteres';

  @override
  String get profileRetryMessage => 'Inténtalo nuevamente.';

  @override
  String get profileRetry => 'Reintentar';

  @override
  String get profileAccount => 'Tu cuenta';

  @override
  String get profileHeading => 'Hagamos tu perfil más tuyo';

  @override
  String get profileDescription =>
      'Cuéntanos cómo te llamas y qué te gusta hacer.';

  @override
  String get profileBaseRole => 'Usuario base';

  @override
  String get profileCompaRole => 'Compa';

  @override
  String get profileAdminRole => 'Administrador';

  @override
  String get profilePhotoProcessing => 'Procesando foto…';

  @override
  String get profilePhotoChange => 'Cambiar foto';

  @override
  String get profilePhotoHelp =>
      'Foto y biografía serán públicas al activar tu perfil compa. JPG o PNG, máximo 5 MB. La foto se guarda por separado.';

  @override
  String get profileName => 'Nombre visible';

  @override
  String get profileNameHelp =>
      'Este nombre aparece en tu perfil compa y tus reservas.';

  @override
  String get profileBiography => 'Biografía pública (opcional)';

  @override
  String get profileBiographyHelp =>
      'Cuenta qué te gusta compartir. Evita incluir datos de contacto privados.';

  @override
  String get profileEmail => 'Correo de acceso';

  @override
  String get profileEmailHelp => 'Gestionado por tu cuenta de acceso.';

  @override
  String get profileContact => 'Datos de contacto';

  @override
  String get profileContactHelp =>
      'Son opcionales. Tu teléfono y ubicación general no se muestran en el catálogo público.';

  @override
  String get profilePhone => 'Teléfono (opcional)';

  @override
  String get profileCountry => 'País (opcional)';

  @override
  String get profileRegion => 'Región (opcional)';

  @override
  String get profileCity => 'Ciudad (opcional)';

  @override
  String get profileInterests => 'Tus intereses (opcionales)';

  @override
  String get profileInterestsHelp =>
      'Sepáralos con comas. Por ejemplo: cine, trekking, videojuegos.';

  @override
  String get profileSaving => 'Guardando…';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileDiscard => 'Descartar cambios';

  @override
  String get profileUnsaved => 'Tienes cambios sin guardar.';

  @override
  String get profileBookings => 'Ver mis reservas';

  @override
  String get publicProfileName => 'Tu nombre visible';

  @override
  String get publicProfileTagline =>
      'Un interés en común. Un plan para compartir.';

  @override
  String get publicProfileAbout => 'Sobre mí';

  @override
  String get publicProfileEmptyBiography => 'Todavía no hay una biografía.';

  @override
  String get publicProfileInterests => 'Me gusta';

  @override
  String publicProfilePhotoLabel(String name) {
    return 'Foto de $name';
  }

  @override
  String get timeOffTitle => 'Mis días libres';

  @override
  String get timeOffRefresh => 'Actualizar días libres';

  @override
  String get timeOffHeading => 'Una pausa en tu agenda';

  @override
  String get timeOffDescription =>
      'Bloquea días completos para vacaciones u otros compromisos. Las fechas usan la zona de tu agenda. El último día también queda bloqueado.';

  @override
  String timeOffDescriptionWithZone(String zone) {
    return 'Bloquea días completos para vacaciones u otros compromisos. Las fechas usan la zona de tu agenda: $zone. El último día también queda bloqueado.';
  }

  @override
  String get timeOffReservationsHelp =>
      'No se cancelan reservas existentes. Si hay una pendiente o confirmada, resuélvela antes de bloquear ese período.';

  @override
  String get timeOffForbidden => 'Solo puedes gestionar tu propia agenda.';

  @override
  String get timeOffLoadFailed =>
      'No pudimos cargar los días libres. Inténtalo nuevamente.';

  @override
  String get timeOffConflict =>
      'El período se cruza con una reserva o con otro bloqueo. Tus reservas se conservan.';

  @override
  String get timeOffSaveFailed =>
      'No pudimos guardar el cambio. Revisa las fechas e inténtalo nuevamente.';

  @override
  String get timeOffTooLong => 'Puedes bloquear hasta 366 días por período.';

  @override
  String get timeOffPickerHelp => 'Días sin disponibilidad';

  @override
  String get timeOffPickerSave => 'Bloquear días';

  @override
  String get timeOffRemoveTitle => '¿Volver a ofrecer estos días?';

  @override
  String timeOffRemoveMessage(String start, String end) {
    return 'Se quitará el bloqueo del $start al $end. Se conserva tu horario semanal.';
  }

  @override
  String get timeOffKeep => 'Conservar';

  @override
  String get timeOffRemove => 'Quitar bloqueo';

  @override
  String get timeOffRetry => 'Reintentar';

  @override
  String get timeOffSaving => 'Guardando…';

  @override
  String get timeOffAdd => 'Agregar días libres';

  @override
  String get timeOffEmpty =>
      'No tienes bloqueos vigentes. Se aplica tu disponibilidad semanal.';

  @override
  String timeOffFullDays(String zone) {
    return 'Días completos · $zone';
  }

  @override
  String get standingLoadFailed =>
      'No pudimos consultar el estado de tu cuenta';

  @override
  String get standingSuspended => 'Tu cuenta tiene actividades suspendidas';

  @override
  String get standingRestricted => 'Tu cuenta tiene restricciones';

  @override
  String get standingUnavailableHelp =>
      'Algunas operaciones pueden no estar disponibles. Puedes seguir consultando tus reservas y las herramientas de seguridad.';

  @override
  String get standingRestrictedHelp =>
      'Algunas acciones están limitadas. Conservas el acceso a tus reservas y a las herramientas de protección disponibles.';

  @override
  String get standingRetry => 'Reintentar';

  @override
  String get constructionDescription =>
      'Esta sección todavía no está disponible.';

  @override
  String get constructionBack => 'Volver';

  @override
  String get exploreHeroEyebrow => 'HAZ ESPACIO PARA UN BUEN PLAN';

  @override
  String get exploreHeroTitle => 'Un buen plan empieza\ncon buena compañía.';

  @override
  String get exploreHeroBody =>
      'Descubre personas con quienes compartir lo que te gusta.';

  @override
  String get exploreHeroHint => 'Tú eliges el plan. Encuentra tu compa.';

  @override
  String get exploreQuestion => '¿Qué te gustaría hacer?';

  @override
  String get exploreQuestionHelp =>
      'Busca por habilidad o explora algo diferente.';

  @override
  String get exploreSearchHintCompact => 'Cine, running, café…';

  @override
  String get exploreSearchHint => 'Busca una habilidad: cine, running, café…';

  @override
  String get exploreClearSearch => 'Limpiar búsqueda';

  @override
  String get exploreSearch => 'Buscar';

  @override
  String get exploreAllSkills => 'Todos';

  @override
  String get exploreTitle => 'Encuentra tu compa';

  @override
  String get exploreRefresh => 'Actualizar';

  @override
  String exploreCount(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$amount compas para conocer',
      one: '$amount compa para conocer',
    );
    return '$_temp0';
  }

  @override
  String get exploreLoadFailed =>
      'No pudimos cargar los compas. Inténtalo otra vez.';

  @override
  String get exploreRetry => 'Reintentar';

  @override
  String get exploreEmptyTitle => 'No encontramos compas';

  @override
  String get exploreEmptyMessage => 'Prueba otra habilidad o selecciona Todos.';

  @override
  String get exploreShowAll => 'Ver todos los compas';

  @override
  String get exploreShowMore => 'Ver más compas';

  @override
  String get exploreFooter =>
      'Encuentra un interés en común. Revisa el perfil y acuerda tu próxima experiencia.';

  @override
  String exploreCardSemantics(
    String name,
    String skills,
    String rate,
    String rating,
  ) {
    return 'Ver perfil de $name. $skills. $rate CLP por hora. $rating.';
  }

  @override
  String exploreCardRating(String rating) {
    return 'Calificación $rating';
  }

  @override
  String get exploreNewInRac => 'Nuevo en RAC';

  @override
  String get exploreNoSkills => 'Conoce sus intereses';

  @override
  String get exploreNoDescription => 'Comparte una nueva experiencia.';

  @override
  String get explorePerHour => '/ hora';

  @override
  String get compaDetailTitle => 'Conoce a tu compa';

  @override
  String get compaDetailLoadFailed => 'No pudimos cargar el perfil';

  @override
  String get compaDetailLoadHelp =>
      'Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get compaDetailRetry => 'Reintentar';

  @override
  String compaDetailRating(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas verificadas',
      one: '$count reseña verificada',
    );
    return '★ $rating · $_temp0';
  }

  @override
  String get compaDetailUnrated => 'Nuevo en RAC · Aún sin calificaciones';

  @override
  String get compaDetailActivities => 'Lo que podemos hacer';

  @override
  String get compaDetailNoDescription =>
      'Este compa todavía no agregó una descripción.';

  @override
  String compaDetailRate(String amount) {
    return '$amount CLP / hora';
  }

  @override
  String get compaDetailBookingHelp =>
      'Consulta horarios y envía una solicitud. Sin cobro por ahora.';

  @override
  String get compaDetailBook => 'Reservar';

  @override
  String get bookingTitle => 'Tu próxima experiencia';

  @override
  String bookingWith(String name) {
    return 'Reserva con $name';
  }

  @override
  String get bookingIntro =>
      'Elige cuándo y por cuánto tiempo. El compa debe aceptar tu solicitud.';

  @override
  String get bookingStepDate => '1. Fecha y duración';

  @override
  String bookingHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '$count hora',
    );
    return '$_temp0';
  }

  @override
  String get bookingStepTime => '2. Hora de inicio';

  @override
  String bookingZones(String local, String zone) {
    return 'Horarios en tu zona local ($local). Agenda del compa: $zone. Se confirma disponibilidad al enviar.';
  }

  @override
  String get bookingNoSchedule =>
      'Este compa aún no publicó horarios. Puedes explorar otros compas.';

  @override
  String get bookingNoSlots =>
      'No hay horarios disponibles para esta fecha y duración. Prueba otro día o una duración menor.';

  @override
  String get bookingStepReview => '3. Revisa tu solicitud';

  @override
  String get bookingSelectSlot => 'Selecciona un horario para continuar.';

  @override
  String bookingReferenceValue(String amount) {
    return 'Valor referencial: $amount CLP';
  }

  @override
  String get bookingNoCharge =>
      'No se realizará ningún cobro. Pagos en construcción.';

  @override
  String get bookingSending => 'Enviando…';

  @override
  String get bookingSubmit => 'Solicitar reserva';

  @override
  String get bookingRefresh => 'Actualizar disponibilidad';

  @override
  String get bookingSent =>
      'Solicitud enviada. Puedes seguir su estado en Mis reservas.';

  @override
  String get bookingLoadFailed =>
      'No pudimos consultar la disponibilidad. Vuelve a intentarlo.';

  @override
  String get bookingSlotPast =>
      'Ese horario ya pasó. Selecciona otro horario disponible.';

  @override
  String get bookingSlotTaken =>
      'Ese horario acaba de ocuparse. Elige otro e inténtalo nuevamente.';

  @override
  String get bookingAvailabilityChanged =>
      'La disponibilidad cambió. Selecciona otro horario.';

  @override
  String get bookingSubmitFailed =>
      'No pudimos enviar la solicitud. Inténtalo nuevamente.';

  @override
  String get bookingsTitle => 'Mis reservas';

  @override
  String get bookingsRefresh => 'Actualizar reservas';

  @override
  String get bookingsHeadline => 'Tus planes, en un solo lugar.';

  @override
  String get bookingsIntro =>
      'Sigue tus solicitudes y gestiona las experiencias confirmadas.';

  @override
  String get bookingsLoadFailed => 'No pudimos cargar tus reservas';

  @override
  String get bookingsLoadHelp => 'Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get bookingsRetry => 'Reintentar';

  @override
  String get bookingsTabHired => 'Mis contrataciones';

  @override
  String get bookingsTabReceived => 'Solicitudes recibidas';

  @override
  String get bookingsEmptyReceivedTitle => 'Tu agenda está libre';

  @override
  String get bookingsEmptyReceivedMessage =>
      'Las solicitudes que recibas aparecerán aquí.';

  @override
  String get bookingsEmptyTitle => 'Tu próximo plan te espera';

  @override
  String get bookingsEmptyMessage =>
      'Explora los compas y encuentra una experiencia para compartir.';

  @override
  String get bookingsExplore => 'Explorar compas';

  @override
  String get bookingsStatusPending => 'Pendiente de aceptación';

  @override
  String get bookingsStatusActive => 'Confirmada';

  @override
  String get bookingsStatusCancelled => 'Cancelada';

  @override
  String get bookingsStatusExpired => 'Vencida sin aceptación';

  @override
  String get bookingsStatusFinished => 'Finalizada';

  @override
  String get bookingsStatusUnknown => 'Estado no reconocido';

  @override
  String get bookingsNoCharge => 'Pagos en construcción · Sin cobro';

  @override
  String bookingsReference(String id, String role) {
    return 'Reserva $id · $role';
  }

  @override
  String get bookingsRoleReceived => 'Solicitud recibida';

  @override
  String get bookingsRoleHired => 'Tu contratación';

  @override
  String get bookingsOpenChat => 'Abrir conversación';

  @override
  String get bookingsReviewLater =>
      'Podrás dejar una reseña cuando termine el horario reservado.';

  @override
  String get bookingsAccept => 'Aceptar';

  @override
  String get bookingsFinish => 'Finalizar';

  @override
  String get bookingsCancel => 'Cancelar';

  @override
  String get bookingsUpdating => 'Actualizando…';

  @override
  String get bookingsUpdateFailed =>
      'No se pudo actualizar la reserva. Revisa su estado e inténtalo nuevamente.';

  @override
  String get bookingsCancelTitle => '¿Cancelar esta reserva?';

  @override
  String get bookingsCancelMessage =>
      'La solicitud quedará cancelada. Puedes crear otra reserva cuando quieras.';

  @override
  String get bookingsTimeOff => 'Mis días libres';

  @override
  String get bookingsKeep => 'Conservar';

  @override
  String get bookingsConfirmCancel => 'Cancelar reserva';

  @override
  String get bookingsLimitTitle => 'Alcanzaste tus 3 reservas gratis';

  @override
  String bookingsLimitMessage(String used, String weekStart) {
    return 'Ya utilizaste $used cupos en la semana que empieza el $weekStart (Chile).\n\nEsta solicitud sigue pendiente. Para aceptar más necesitarás una suscripción. Los pagos todavía están en construcción.';
  }

  @override
  String get bookingsLimitOk => 'Entendido';

  @override
  String get bookingsLimitPlans => 'Ver planes';

  @override
  String get reviewRetryLoad => 'Reintentar carga de reseña';

  @override
  String reviewVerified(String score) {
    return '★ $score/5 · Reseña verificada';
  }

  @override
  String get reviewWrite => 'Dejar una reseña';

  @override
  String get reviewDialogTitle => '¿Cómo estuvo la experiencia?';

  @override
  String get reviewDialogIntro =>
      'Tu reseña será pública y quedará vinculada a una reserva verificada. Se envía una sola vez y no se puede editar.';

  @override
  String reviewStars(int count) {
    return '$count de 5 estrellas';
  }

  @override
  String get reviewComment => 'Comentario (opcional)';

  @override
  String get reviewCommentHelp =>
      'Evita incluir datos de contacto o información privada.';

  @override
  String get reviewSendFailed =>
      'No pudimos confirmar el envío. Reintenta o vuelve a la reserva para comprobar si se guardó.';

  @override
  String get reviewConflict =>
      'Esta reserva todavía no permite reseñas o ya tiene una. Vuelve a la reserva para comprobar su estado.';

  @override
  String get reviewBack => 'Volver';

  @override
  String get reviewSending => 'Enviando…';

  @override
  String get reviewPublish => 'Publicar reseña';

  @override
  String get reviewsPublicTitle => 'Reseñas de reservas verificadas';

  @override
  String get reviewsPublicEmpty =>
      'Todavía no hay reseñas. Solo pueden valorar quienes completaron una reserva.';

  @override
  String reviewsPublicItem(String score) {
    return '★ $score/5 · Reserva verificada';
  }

  @override
  String get reviewsPublicLoadFailed =>
      'No pudimos cargar las reseñas. Reintentar';

  @override
  String get reviewsPublicMore => 'Ver más reseñas';

  @override
  String get chatStateActive => 'Confirmada';

  @override
  String get chatStateFinished => 'Finalizada · Solo lectura';

  @override
  String get chatStateClosed => 'Cancelada · Solo lectura';

  @override
  String get chatTitle => 'Mensajes';

  @override
  String get chatModeration => 'Moderación de reportes';

  @override
  String get chatRefreshList => 'Actualizar conversaciones';

  @override
  String get chatListLoadFailed => 'No pudimos cargar tus conversaciones';

  @override
  String get chatCheckConnection =>
      'Revisa tu conexión e inténtalo nuevamente.';

  @override
  String get chatRetry => 'Reintentar';

  @override
  String get chatListHeadline => 'Conversemos el próximo plan';

  @override
  String get chatListIntro =>
      'Cada conversación pertenece a una reserva confirmada. Solo sus dos participantes pueden acceder.';

  @override
  String get chatListEmptyTitle => 'Todavía no tienes conversaciones';

  @override
  String get chatListEmptyMessage =>
      'Al confirmar una reserva podrás coordinar los detalles con tu compa.';

  @override
  String get chatListBookings => 'Ver mis reservas';

  @override
  String chatListSubtitle(String state, String booking, String preview) {
    return '$state · Reserva $booking\n$preview';
  }

  @override
  String get chatListFirstHello => 'Sé el primero en saludar';

  @override
  String get chatListNewer => 'Más recientes';

  @override
  String get chatListOlder => 'Anteriores';

  @override
  String get chatDefaultName => 'Tu conversación';

  @override
  String get chatSafety => 'Seguridad de la conversación';

  @override
  String get chatRefresh => 'Actualizar conversación';

  @override
  String get chatPrivate => 'Conversación privada';

  @override
  String get chatLinkConnecting => 'Conectando…';

  @override
  String get chatLinkPaused => 'En pausa';

  @override
  String get chatLinkConnected => 'Conectado';

  @override
  String get chatLinkReadOnly => 'Solo lectura';

  @override
  String get chatLinkOffline => 'Sin conexión';

  @override
  String get chatLinkReconnecting => 'Reconectando…';

  @override
  String chatBookingWritable(String booking) {
    return 'Reserva $booking · Coordina los detalles de tu plan.';
  }

  @override
  String chatBookingReadOnly(String booking) {
    return 'Reserva $booking · El historial se conserva en solo lectura.';
  }

  @override
  String get chatRetryConnection => 'Reintentar conexión';

  @override
  String get chatEmptyTitle => 'Un saludo abre la conversación';

  @override
  String get chatEmptyMessage =>
      'Los mensajes de esta reserva aparecerán aquí.';

  @override
  String get chatLoading => 'Cargando…';

  @override
  String get chatLoadOlder => 'Cargar mensajes anteriores';

  @override
  String get chatYou => 'Tú';

  @override
  String get chatSaved => 'Guardado';

  @override
  String get chatMessage => 'Mensaje';

  @override
  String get chatMessageHint => 'Escribe un mensaje…';

  @override
  String get chatRetrySend => 'Reintentar envío';

  @override
  String get chatSend => 'Enviar mensaje';

  @override
  String get chatTooLong => 'Usa hasta 2000 caracteres por mensaje.';

  @override
  String get chatInterrupted =>
      'Se interrumpió la conexión. Reintentaremos sin perder el historial.';

  @override
  String get chatErrorInvalid =>
      'Revisa el motivo y la descripción antes de continuar.';

  @override
  String get chatErrorForbidden =>
      'Tu cuenta no tiene permiso para esta acción.';

  @override
  String get chatErrorSession =>
      'Tu sesión venció. Vuelve a ingresar para continuar.';

  @override
  String get chatErrorGone =>
      'Esta conversación ya no está disponible para tu cuenta.';

  @override
  String get chatErrorChanged =>
      'La reserva cambió de estado. Actualiza la conversación.';

  @override
  String get chatErrorBusy =>
      'Hay demasiadas conexiones. Reintentaremos en unos momentos.';

  @override
  String get chatErrorUnavailable =>
      'No pudimos conectar. Conservamos tu mensaje para reintentar aquí.';

  @override
  String get reportStatusOpen => 'Pendiente de revisión';

  @override
  String get reportStatusHandled => 'Reporte atendido';

  @override
  String get reportStatusDismissed => 'Reporte desestimado';

  @override
  String get reportStatusReceived => 'Reporte recibido';

  @override
  String get reportReasonHarassment => 'Acoso o amenazas';

  @override
  String get reportReasonSpam => 'Spam o publicidad';

  @override
  String get reportReasonInappropriate => 'Contenido inapropiado';

  @override
  String get reportReasonOther => 'Otro motivo';

  @override
  String get reportReasonGeneric => 'Reporte';

  @override
  String get safetyLoadFailed =>
      'No pudimos cargar las opciones de seguridad. Inténtalo de nuevo.';

  @override
  String get safetyChangeFailed =>
      'No pudimos confirmar el cambio. Actualiza para comprobar su estado antes de reintentar.';

  @override
  String get safetyUnblockTitle => '¿Retirar tu bloqueo?';

  @override
  String get safetyBlockTitle => '¿Bloquear esta conversación?';

  @override
  String get safetyUnblockMessage =>
      'Se podrá conversar si la otra persona tampoco mantiene un bloqueo y la reserva sigue activa.';

  @override
  String get safetyBlockMessage =>
      'Se detendrán los mensajes nuevos de ambos participantes. Conservarás el historial. La reserva y sus condiciones siguen vigentes.';

  @override
  String get safetyBack => 'Volver';

  @override
  String get safetyConfirmUnblock => 'Retirar bloqueo';

  @override
  String get safetyConfirmBlock => 'Confirmar bloqueo';

  @override
  String get safetyRefresh => 'Actualizar seguridad';

  @override
  String get safetyHeadline => 'Tu tranquilidad importa';

  @override
  String get safetyIntro =>
      'Estas opciones se aplican a esta conversación. Bloquear y reportar son decisiones independientes.';

  @override
  String get safetyRetry => 'Reintentar';

  @override
  String get safetyBlocked => 'Conversación bloqueada';

  @override
  String get safetyControl => 'Controla quién puede escribirte';

  @override
  String get safetyOwnBlock =>
      'Mantienes un bloqueo activo. Puedes retirarlo cuando quieras.';

  @override
  String get safetyOtherBlock =>
      'Hay un bloqueo activo de la otra persona. El historial sigue disponible.';

  @override
  String get safetyCanBlock =>
      'Puedes detener los mensajes nuevos sin borrar el historial.';

  @override
  String get safetyRemoveOwnBlock => 'Retirar mi bloqueo';

  @override
  String get safetyBlock => 'Bloquear conversación';

  @override
  String get safetyReportPending =>
      'Puedes actualizar esta pantalla para consultar el estado de tu reporte. No necesitas enviarlo otra vez.';

  @override
  String get safetyReportTitle => 'Reportar un problema';

  @override
  String get safetyReportNotice =>
      'El equipo de moderación podrá consultar tu descripción y el historial existente al enviar el reporte. Cada consulta requiere una justificación y queda registrada. No incluyas contraseñas ni información privada ajena al incidente.';

  @override
  String get safetyReason => 'Motivo del reporte';

  @override
  String get safetyDetail => 'Describe qué ocurrió';

  @override
  String get safetyDetailTooShort =>
      'Cuéntanos lo ocurrido en al menos 10 caracteres.';

  @override
  String get safetySendReport => 'Enviar reporte';

  @override
  String get safetyManualReview =>
      'Los reportes se revisan manualmente. Su envío no cancela la reserva ni modifica sus condiciones.';

  @override
  String get moderationRefresh => 'Actualizar reportes';

  @override
  String get moderationFilterOpen => 'Abiertos';

  @override
  String get moderationFilterHandled => 'Atendidos';

  @override
  String get moderationFilterDismissed => 'Desestimados';

  @override
  String get moderationFilterAll => 'Todos';

  @override
  String get moderationForbidden => 'Acceso reservado al equipo de moderación.';

  @override
  String get moderationLoadFailed =>
      'No pudimos cargar los reportes. Inténtalo de nuevo.';

  @override
  String get moderationDateUnavailable => 'Fecha no disponible';

  @override
  String get moderationPending => 'Casos pendientes';

  @override
  String get moderationHistory => 'Historial de reportes';

  @override
  String get moderationIntro =>
      'Consulta el estado y las fechas de cada reporte. Los casos donde participas quedan excluidos. El contenido de un caso abierto requiere una consulta justificada y registrada.';

  @override
  String get moderationOrder =>
      'Ordenados por fecha del reporte, del más antiguo al más reciente.';

  @override
  String get moderationRetry => 'Reintentar';

  @override
  String get moderationEmpty =>
      'No hay reportes para este filtro en esta página.';

  @override
  String get moderationStatusUnavailable => 'Estado no disponible';

  @override
  String moderationCaseRef(String caseId, String booking) {
    return 'Caso $caseId · Reserva $booking';
  }

  @override
  String moderationReported(String date) {
    return 'Reportado: $date';
  }

  @override
  String moderationClosedAt(String date) {
    return 'Cierre: $date';
  }

  @override
  String get moderationClosedNote =>
      'Caso cerrado. La consulta del contenido está deshabilitada.';

  @override
  String moderationPage(int page) {
    return 'Página $page';
  }

  @override
  String get moderationPrevious => 'Anteriores';

  @override
  String get moderationNext => 'Siguientes';

  @override
  String get moderationAccessFailed =>
      'No pudimos autorizar la consulta. El caso puede estar cerrado o fuera de tu acceso.';

  @override
  String get moderationCloseTitle => '¿Cerrar este caso?';

  @override
  String get moderationCloseHandled =>
      'Se registrará como atendido junto a tu justificación. El cierre no aplica sanciones ni retira bloqueos.';

  @override
  String get moderationCloseDismissed =>
      'Se registrará como desestimado junto a tu justificación. El cierre no aplica sanciones ni retira bloqueos.';

  @override
  String get moderationBack => 'Volver';

  @override
  String get moderationConfirmClose => 'Confirmar cierre';

  @override
  String get moderationCloseFailed =>
      'No pudimos confirmar el cierre. Actualiza la cola para comprobar su estado.';

  @override
  String moderationCaseTitle(String caseId) {
    return 'Caso $caseId';
  }

  @override
  String get moderationHeadline => 'Consulta con responsabilidad';

  @override
  String get moderationCaseIntro =>
      'Solo se permite revisar el historial existente al enviar este reporte. Cada consulta y cada cierre registran tu identidad, justificación y hora. No copies información fuera del proceso de moderación.';

  @override
  String get moderationJustification =>
      'Justificación de la consulta o resolución';

  @override
  String get moderationJustificationTooShort =>
      'Escribe una justificación de al menos 10 caracteres.';

  @override
  String get moderationAccess => 'Consultar y registrar acceso';

  @override
  String get moderationLinkedHistory => 'Historial asociado al reporte';

  @override
  String get moderationReporter => 'Quien reportó';

  @override
  String get moderationOtherPerson => 'Otra persona';

  @override
  String get moderationOlder =>
      'Consultar mensajes anteriores y registrar acceso';

  @override
  String get moderationResolveHint =>
      'Describe la gestión realizada en la justificación antes de cerrar el caso.';

  @override
  String get moderationMarkHandled => 'Marcar atendido';

  @override
  String get moderationDismiss => 'Desestimar reporte';

  @override
  String get adminTitle => 'Administración';

  @override
  String get adminRefresh => 'Actualizar resumen';

  @override
  String get adminForbiddenTitle => 'Acceso reservado a administradores';

  @override
  String get adminForbiddenMessage =>
      'Tu cuenta no tiene permiso para consultar este panel.';

  @override
  String get adminLoadFailed => 'No pudimos cargar el resumen';

  @override
  String get adminLoadHelp =>
      'No mostramos cifras parciales. Revisa la conexión e inténtalo nuevamente.';

  @override
  String get adminRetry => 'Reintentar';

  @override
  String get adminHeadline => 'El pulso de RAC';

  @override
  String get adminIntro =>
      'Resumen acumulado de la aplicación. Cada servicio conserva la propiedad de sus datos.';

  @override
  String adminQueriedAt(String date) {
    return 'Consulta: $date';
  }

  @override
  String get adminCommunity => 'Comunidad';

  @override
  String get adminUsers => 'Usuarios con perfil';

  @override
  String get adminCompas => 'Perfiles compa';

  @override
  String get adminBookings => 'Reservas';

  @override
  String get adminPending => 'Pendientes';

  @override
  String get adminConfirmed => 'Confirmadas';

  @override
  String get adminFinished => 'Finalizadas';

  @override
  String get adminCancelled => 'Canceladas';

  @override
  String get adminExpired => 'Vencidas';

  @override
  String get adminModeration => 'Moderación';

  @override
  String get adminModerationNote =>
      'Los conteos de moderación excluyen las reservas donde participas. Las cifras se consultan por servicio y pueden cambiar durante la consulta.';

  @override
  String get adminReviewReports => 'Revisar reportes';

  @override
  String get artworkCoffee => 'Un café y una charla';

  @override
  String get artworkRunning => 'Kilómetros en compañía';

  @override
  String get artworkMovie => 'Una buena película';
}
