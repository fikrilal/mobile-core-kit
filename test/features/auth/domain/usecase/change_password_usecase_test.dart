import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ChangePasswordRequestEntity(
        currentPassword: 'old-password',
        newPassword: 'new-password',
      ),
    );
  });

  group('ChangePasswordUseCase', () {
    test('returns validation failure and does not call repo when invalid', () async {
      final repo = _MockAuthRepository();
      final usecase = ChangePasswordUseCase(repo);

      final result = await usecase(
        const ChangePasswordRequestEntity(
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
    });

    test('returns validation failure when new password equals current password', () async {
      final repo = _MockAuthRepository();
      final usecase = ChangePasswordUseCase(repo);

      const password = 'samepassword';
      final result = await usecase(
        const ChangePasswordRequestEntity(
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
    });

    test('calls repo when valid', () async {
      final repo = _MockAuthRepository();
      when(() => repo.changePassword(any())).thenAnswer((_) async => right(unit));

      final usecase = ChangePasswordUseCase(repo);

      const request = ChangePasswordRequestEntity(
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      );

      final result = await usecase(request);
      expect(result.isRight(), true);

      final captured = verify(() => repo.changePassword(captureAny())).captured;
      expect(captured.length, 1);
      expect(captured.single, request);
    });
  });
}

