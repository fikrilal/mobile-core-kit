import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginRequestEntity(email: 'e', password: 'p'));
  });

  group('LoginUserUseCase', () {
    test(
      'returns validation failure and does not call repo when invalid',
      () async {
        final repo = _MockAuthRepository();
        final usecase = LoginUserUseCase(repo);

        final result = await usecase(
          const LoginRequestEntity(email: 'not-an-email', password: '   '),
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
                code: ValidationErrorCodes.required,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.login(any()));
      },
    );

    test(
      'normalizes email but preserves password before calling repo',
      () async {
        final repo = _MockAuthRepository();
        const session = AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'access',
            refreshToken: 'refresh',
            tokenType: 'Bearer',
            expiresIn: 900,
          ),
          user: UserEntity(id: 'u1', email: 'user@example.com'),
        );
        when(() => repo.login(any())).thenAnswer((_) async => right(session));

        final usecase = LoginUserUseCase(repo);

        final result = await usecase(
          const LoginRequestEntity(
            email: ' user@example.com ',
            password: ' password ',
          ),
        );

        expect(result.isRight(), true);
        final captured = verify(() => repo.login(captureAny())).captured;
        expect(captured.length, 1);
        final request = captured.single as LoginRequestEntity;
        expect(request.email, 'user@example.com');
        expect(request.password, ' password ');
      },
    );

    test(
      'returns email-only validation failure when password is valid',
      () async {
        final repo = _MockAuthRepository();
        final usecase = LoginUserUseCase(repo);

        final result = await usecase(
          const LoginRequestEntity(email: 'not-an-email', password: 'password'),
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
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.login(any()));
      },
    );
  });
}
