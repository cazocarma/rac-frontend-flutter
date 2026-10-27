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
}
