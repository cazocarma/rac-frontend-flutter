import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

OidcStore createAuthStore() => OidcDefaultStore(
  secureStorageInstance: OidcDefaultStore.createHardenedSecureStorage(),
);
