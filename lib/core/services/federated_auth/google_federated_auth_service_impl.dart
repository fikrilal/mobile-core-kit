import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';

class GoogleFederatedAuthServiceImpl implements GoogleFederatedAuthService {
  GoogleFederatedAuthServiceImpl({
    GoogleSignIn? googleSignIn,
    String? serverClientId,
  }) : _googleSignInOverride = googleSignIn,
       _serverClientIdOverride = serverClientId;

  final GoogleSignIn? _googleSignInOverride;
  final String? _serverClientIdOverride;

  late final GoogleSignIn _googleSignIn =
      _googleSignInOverride ?? GoogleSignIn.instance;

  String get _serverClientId =>
      _serverClientIdOverride ?? BuildConfig.googleOidcServerClientId;

  Future<void>? _googleInitFuture;

  Future<void> _ensureGoogleInitialized() {
    final existing = _googleInitFuture;
    if (existing != null) return existing;

    final serverClientId = _serverClientId.trim();
    if (serverClientId.isEmpty) {
      Log.warning(
        'Google OIDC server client id is empty; Google Sign-In may fail to return an idToken.',
        name: 'GoogleFederatedAuthService',
      );
    }

    final future = _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
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
      if (isCancelled) {
        Log.debug(
          'Google sign-in cancelled (code=${e.code}, description=${e.description})',
          name: 'GoogleFederatedAuthService',
        );
        return null;
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in did not return tokens.');
    }

    return idToken;
  }
}
