/// Abstraction for Google-based federated authentication.
///
/// This service encapsulates platform SDK interactions (Google Sign-In +
/// Google Sign-In) and exposes a minimal API to the rest of the app.
abstract class GoogleFederatedAuthService {
  /// Starts Google sign-in and returns a Google OIDC `id_token`.
  ///
  /// Returns null when the user cancels the sign-in flow.
  Future<String?> signInAndGetOidcIdToken();
}
