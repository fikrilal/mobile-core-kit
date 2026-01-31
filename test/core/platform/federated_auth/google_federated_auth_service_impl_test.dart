import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

void main() {
  group('GoogleFederatedAuthServiceImpl', () {
    test('returns null when the user cancels sign-in', () async {
      final googleSignIn = _MockGoogleSignIn();

      when(
        () => googleSignIn.initialize(
          serverClientId: any<String?>(named: 'serverClientId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => googleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) => Future.value(null));
      when(() => googleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      final service = GoogleFederatedAuthServiceImpl(
        googleSignIn: googleSignIn,
      );

      final result = await service.signInAndGetOidcIdToken();

      expect(result, isNull);
    });

    test('returns OIDC id_token on success', () async {
      final googleSignIn = _MockGoogleSignIn();
      final account = _MockGoogleSignInAccount();

      when(
        () => googleSignIn.initialize(
          serverClientId: any<String?>(named: 'serverClientId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => googleSignIn.attemptLightweightAuthentication(),
      ).thenAnswer((_) => Future.value(null));
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);
      when(
        () => account.authentication,
      ).thenReturn(const GoogleSignInAuthentication(idToken: 'oidc-id-token'));

      final service = GoogleFederatedAuthServiceImpl(
        googleSignIn: googleSignIn,
      );

      final result = await service.signInAndGetOidcIdToken();

      expect(result, 'oidc-id-token');
    });
  });
}
