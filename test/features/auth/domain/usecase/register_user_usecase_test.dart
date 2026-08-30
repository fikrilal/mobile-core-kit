import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/input/register_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/registration_credentials.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(_validCredentials());
  });

  group('RegisterUserUseCase', () {
    test(
      'returns validation failure and does not call repo when invalid',
      () async {
        final repo = _MockAuthRepository();
        final usecase = RegisterUserUseCase(repo);

        final result = await usecase(
          const RegisterInput(email: 'not-an-email', password: 'short'),
        );

        expect(result.isLeft(), true);
        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'email',
                message: '',
                code: ValidationErrorCodes.invalidEmail,
              ),
              ValidationError(
                field: 'password',
                message: '',
                code: ValidationErrorCodes.passwordTooShort,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.register(any()));
      },
    );

    test('normalizes fields before calling repo', () async {
      final repo = _MockAuthRepository();
      const session = AuthSessionEntity(
        tokens: AuthTokensEntity(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 900,
        ),
        user: UserEntity(
          id: 'u1',
          email: 'user@example.com',
          profile: UserProfileEntity(givenName: 'John', familyName: 'Doe'),
          emailVerified: false,
        ),
      );

      when(() => repo.register(any())).thenAnswer((_) async => right(session));

      final usecase = RegisterUserUseCase(repo);

      final result = await usecase(
        const RegisterInput(
          email: ' user@example.com ',
          password: ' stringstring ',
        ),
      );

      expect(result.isRight(), true);

      final captured = verify(() => repo.register(captureAny())).captured;
      expect(captured.length, 1);
      final credentials = captured.single as RegistrationCredentials;
      expect(credentials.email.value, 'user@example.com');
      expect(credentials.password.value, ' stringstring ');
    });
  });
}

RegistrationCredentials _validCredentials() {
  return RegistrationCredentials.create(
    email: 'user@example.com',
    password: 'password123',
  ).match(
    (_) => throw StateError('Expected valid test credentials.'),
    (credentials) => credentials,
  );
}
