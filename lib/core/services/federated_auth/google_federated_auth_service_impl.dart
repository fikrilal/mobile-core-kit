import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../firebase_options.dart';
import 'google_federated_auth_service.dart';

class GoogleFederatedAuthServiceImpl implements GoogleFederatedAuthService {
  GoogleFederatedAuthServiceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuthOverride = firebaseAuth,
       _googleSignInOverride = googleSignIn;

  final FirebaseAuth? _firebaseAuthOverride;
  final GoogleSignIn? _googleSignInOverride;

  late final FirebaseAuth _firebaseAuth =
      _firebaseAuthOverride ?? FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn =
      _googleSignInOverride ?? GoogleSignIn.instance;

  Future<void>? _firebaseInitFuture;
  Future<void>? _googleInitFuture;

  Future<void> _ensureFirebaseInitialized() {
    if (Firebase.apps.isNotEmpty) return Future.value();

    final existing = _firebaseInitFuture;
    if (existing != null) return existing;

    final future = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {});
    _firebaseInitFuture = future;
    return future;
  }

  Future<void> _ensureGoogleInitialized() {
    final existing = _googleInitFuture;
    if (existing != null) return existing;

    final future = _googleSignIn.initialize();
    _googleInitFuture = future;
    return future;
  }

  @override
  Future<String?> signInAndGetFirebaseIdToken() async {
    await _ensureFirebaseInitialized();
    await _ensureGoogleInitialized();

    final lightweightAttempt = _googleSignIn.attemptLightweightAuthentication();
    final GoogleSignInAccount? lightweightAccount =
        lightweightAttempt == null ? null : await lightweightAttempt;

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

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseIdToken = await userCredential.user?.getIdToken(true);

    // This template treats the backend as the source of truth for auth state.
    // Avoid persisting a second session in FirebaseAuth.
    await _firebaseAuth.signOut();

    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw StateError('Firebase user did not return an ID token.');
    }

    return firebaseIdToken;
  }
}
