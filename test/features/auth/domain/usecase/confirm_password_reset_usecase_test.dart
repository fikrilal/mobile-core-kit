import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const PasswordResetConfirmRequestEntity(
        token: 't',
        newPassword: '1234567890',
      ),
    );
  });

  group('ConfirmPasswordResetUseCase', () {
    test(
      'returns validation failure and does not call repo when token empty',
      () async {
        final repo = _MockAuthRepository();
        final usecase = ConfirmPasswordResetUseCase(repo);

        final result = await usecase(
          const PasswordResetConfirmRequestEntity(
            token: ' ',
            newPassword: '1234567890',
          ),
        );

        expect(result.isLeft(), true);
        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'token',
                message: '',
                code: ValidationErrorCodes.required,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.confirmPasswordReset(any()));
      },
    );

    test(
      'returns validation failure and does not call repo when new password too short',
      () async {
        final repo = _MockAuthRepository();
        final usecase = ConfirmPasswordResetUseCase(repo);

        final result = await usecase(
          const PasswordResetConfirmRequestEntity(
            token: 'token',
            newPassword: 'short',
          ),
        );

        expect(result.isLeft(), true);
        result.match((failure) {
          expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'newPassword',
                message: '',
                code: ValidationErrorCodes.passwordTooShort,
              ),
            ]),
          );
        }, (_) => fail('Expected Left'));

        verifyNever(() => repo.confirmPasswordReset(any()));
      },
    );

    test('normalizes token before calling repo', () async {
      final repo = _MockAuthRepository();
      when(
        () => repo.confirmPasswordReset(any()),
      ).thenAnswer((_) async => right(unit));

      final usecase = ConfirmPasswordResetUseCase(repo);

      final result = await usecase(
        const PasswordResetConfirmRequestEntity(
          token: ' token ',
          newPassword: '1234567890',
        ),
      );

      expect(result.isRight(), true);

      final captured = verify(
        () => repo.confirmPasswordReset(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final request = captured.single as PasswordResetConfirmRequestEntity;
      expect(request.token, 'token');
    });
  });
}
