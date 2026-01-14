/// Abstraction for Google-based federated authentication.
///
/// This service encapsulates platform SDK interactions (Google Sign-In +
/// FirebaseAuth) and exposes a minimal API to the rest of the app.
abstract class GoogleFederatedAuthService {
  /// Starts Google sign-in and returns a Firebase ID token for the signed-in user.
  ///
  /// Returns null when the user cancels the sign-in flow.
  Future<String?> signInAndGetFirebaseIdToken();
}
