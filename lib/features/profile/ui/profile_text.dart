import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/user_api.dart';

extension ProfilePhotoFailureText on ProfilePhotoFailure {
  String localized(AppLocalizations t) => switch (this) {
    ProfilePhotoFailure.load => t.profilePhotoLoadFailed,
    ProfilePhotoFailure.tooLarge => t.profilePhotoTooLarge,
    ProfilePhotoFailure.unsupportedFormat => t.profilePhotoFormat,
    ProfilePhotoFailure.invalidImage => t.profilePhotoInvalid,
    ProfilePhotoFailure.busy => t.profilePhotoBusy,
    ProfilePhotoFailure.save => t.profilePhotoSaveFailed,
    ProfilePhotoFailure.remove => t.profilePhotoRemoveFailed,
    ProfilePhotoFailure.process => t.profilePhotoProcessFailed,
  };
}
