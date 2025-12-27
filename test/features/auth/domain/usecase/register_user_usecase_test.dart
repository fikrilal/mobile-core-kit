import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RegisterRequestEntity(
        email: 'e',
        password: 'password123',
        firstName: 'First',
        lastName: 'Last',
      ),
    );
  });

  group('RegisterUserUseCase', () {
    test('returns validation failure and does not call repo when invalid',
        () async {
      final repo = _MockAuthRepository();
      final usecase = RegisterUserUseCase(repo);

      final result = await usecase(
        const RegisterRequestEntity(
          email: 'not-an-email',
          password: 'short',
          firstName: ' ',
          lastName: 'A',
        ),
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'email',
                message: 'Please enter a valid email address',
                code: 'invalid_email',
              ),
              ValidationError(
                field: 'password',
                message: 'Password must be at least 8 characters',
                code: 'weak_password',
              ),
              ValidationError(
                field: 'firstName',
                message: 'This field cannot be empty',
                code: 'invalid_first_name',
              ),
              ValidationError(
                field: 'lastName',
                message: 'Must be at least 2 characters',
                code: 'invalid_last_name',
              ),
            ]),
          );
        },
        (_) => fail('Expected Left'),
      );

      verifyNever(() => repo.register(any()));
    });

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
          firstName: 'John',
          lastName: 'Doe',
          emailVerified: false,
        ),
      );

      when(() => repo.register(any())).thenAnswer((_) async => right(session));

      final usecase = RegisterUserUseCase(repo);

      final result = await usecase(
        const RegisterRequestEntity(
          email: ' user@example.com ',
          password: ' stringstring ',
          firstName: ' John ',
          lastName: ' Doe ',
        ),
      );

      expect(result.isRight(), true);

      final captured = verify(() => repo.register(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured.single as RegisterRequestEntity;
      expect(request.email, 'user@example.com');
      expect(request.password, 'stringstring');
      expect(request.firstName, 'John');
      expect(request.lastName, 'Doe');
    });
  });
}

