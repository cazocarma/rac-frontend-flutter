import 'package:oidc/oidc.dart';
import 'package:oidc_web_core/oidc_web_core.dart';

// Full-page OIDC needs transaction state and PKCE to survive navigation.
// Fail closed if browser encryption is unavailable; never persist plaintext tokens.
OidcStore createAuthStore() =>
    const OidcWebStore(encryption: OidcWebStoreEncryption.required);
