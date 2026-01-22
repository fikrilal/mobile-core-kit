import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';

class GoogleFederatedAuthServiceImpl implements GoogleFederatedAuthService {
  GoogleFederatedAuthServiceImpl({GoogleSignIn? googleSignIn})
    : _googleSignInOverride = googleSignIn;

  final GoogleSignIn? _googleSignInOverride;

  late final GoogleSignIn _googleSignIn =
      _googleSignInOverride ?? GoogleSignIn.instance;

  Future<void>? _googleInitFuture;

  Future<void> _ensureGoogleInitialized() {
    final existing = _googleInitFuture;
    if (existing != null) return existing;

    final future = _googleSignIn.initialize();
    _googleInitFuture = future;
    return future;
  }

  @override
  Future<String?> signInAndGetOidcIdToken() async {
    await _ensureGoogleInitialized();

    final lightweightAttempt = _googleSignIn.attemptLightweightAuthentication();
    final GoogleSignInAccount? lightweightAccount = lightweightAttempt == null
        ? null
        : await lightweightAttempt;

    GoogleSignInAccount account;
    try {
      account = lightweightAccount ?? await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      final isCancelled = e.code == GoogleSignInExceptionCode.canceled;
      if (isCancelled) return null;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in did not return tokens.');
    }

    return idToken;
  }
}
