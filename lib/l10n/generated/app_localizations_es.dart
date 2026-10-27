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
}
