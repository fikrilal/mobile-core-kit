import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/input/change_password_input.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_change_credentials.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      PasswordChangeCredentials.create(
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      ).getOrElse((_) => throw StateError('')),
    );
  });

  group('ChangePasswordUseCase', () {
    test(
      'returns validation failure and does not call repo when invalid',
      () async {
        final repo = _MockAuthRepository();
        final usecase = ChangePasswordUseCase(repo);

        final result = await usecase(
          const ChangePasswordInput(
            currentPassword: '',
            newPassword: '123456789',
          ),
        );

        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'currentPassword',
                message: '',
                code: ValidationErrorCodes.required,
              ),
              ValidationError(
                field: 'newPassword',
                message: '',
                code: ValidationErrorCodes.passwordTooShort,
              ),
            ]),
          ),
          (_) => fail('Expected Left'),
        );

        verifyNever(() => repo.changePassword(any()));
      },
    );

    test(
      'returns validation failure when new password equals current password',
      () async {
        final repo = _MockAuthRepository();
        final usecase = ChangePasswordUseCase(repo);

        const password = 'samepassword';
        final result = await usecase(
          const ChangePasswordInput(
            currentPassword: password,
            newPassword: password,
          ),
        );

        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(
            failure,
            const AuthFailure.validation([
              ValidationError(
                field: 'newPassword',
                message: '',
                code: ValidationErrorCodes.passwordSameAsCurrent,
              ),
            ]),
          ),
          (_) => fail('Expected Left'),
        );

        verifyNever(() => repo.changePassword(any()));
      },
    );

    test('calls repo with validated credentials when valid', () async {
      final repo = _MockAuthRepository();
      when(
        () => repo.changePassword(any()),
      ).thenAnswer((_) async => right(unit));

      final usecase = ChangePasswordUseCase(repo);

      const input = ChangePasswordInput(
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      );

      final result = await usecase(input);
      expect(result.isRight(), true);

      final captured = verify(() => repo.changePassword(captureAny())).captured;
      expect(captured.length, 1);
      final credentials = captured.single as PasswordChangeCredentials;
      expect(credentials.currentPassword.value, 'oldpassword123');
      expect(credentials.newPassword.value, 'newpassword123');
    });
  });
}
