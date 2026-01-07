import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_core_kit/firebase_options.dart';

class GoogleFirebaseAuthDataSource {
  GoogleFirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitFuture;

  Future<void> _ensureGoogleInitialized() {
    final existing = _googleInitFuture;
    if (existing != null) return existing;
    final future = _googleSignIn.initialize();
    _googleInitFuture = future;
    return future;
  }

  Future<String?> signInAndGetFirebaseIdToken() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

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

    final auth = account.authentication;
    final idToken = auth.idToken;
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
