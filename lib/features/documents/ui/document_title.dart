import '../../../l10n/generated/app_localizations.dart';
import '../data/documents_api.dart';

// Labels belong to presentation. Legal content/version/hash remain untouched.
extension LocalizedDocumentTitle on LegalDocument {
  String localizedTitle(AppLocalizations strings) => switch (kind) {
    'terms_client' => strings.documentTermsClient,
    'terms_compa' => strings.documentTermsCompa,
    'community_rules' => strings.documentCommunity,
    'privacy' => strings.documentPrivacy,
    'safety_rules' => strings.documentSafety,
    _ => strings.documentGeneric,
  };
}
