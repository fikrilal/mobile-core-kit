import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockConfirmPasswordResetUseCase extends Mock
    implements ConfirmPasswordResetUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const PasswordResetConfirmRequestEntity(
        token: 't',
        newPassword: '1234567890',
      ),
    );
  });

  group('PasswordResetConfirmCubit', () {
    late _MockConfirmPasswordResetUseCase confirmPasswordReset;
    late _MockSessionManager sessionManager;

    setUp(() {
      confirmPasswordReset = _MockConfirmPasswordResetUseCase();
      sessionManager = _MockSessionManager();
      when(
        () => sessionManager.logout(reason: any(named: 'reason')),
      ).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = PasswordResetConfirmCubit(
        confirmPasswordReset,
        sessionManager,
      );
      final emitted = <PasswordResetConfirmState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, PasswordResetConfirmStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(emitted.single.tokenError?.code, ValidationErrorCodes.required);
      expect(
        emitted.single.newPasswordError?.code,
        ValidationErrorCodes.required,
      );
      expect(emitted.single.confirmNewPasswordError, isNull);

      verifyNever(() => confirmPasswordReset(any()));
      verifyNever(() => sessionManager.logout(reason: any(named: 'reason')));

      await sub.cancel();
      await cubit.close();
    });

    test('confirms reset and emits submitting -> success', () async {
      when(
        () => confirmPasswordReset(any()),
      ).thenAnswer((_) async => right(unit));

      final cubit = PasswordResetConfirmCubit(
        confirmPasswordReset,
        sessionManager,
        token: ' token ',
      );
      final emitted = <PasswordResetConfirmState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('newpassword123');
      await cubit.submit();
      await pumpEventQueue();

      expect(
        emitted.any((s) => s.status == PasswordResetConfirmStatus.submitting),
        true,
      );
      expect(emitted.last.status, PasswordResetConfirmStatus.success);

      final captured = verify(
        () => confirmPasswordReset(captureAny()),
      ).captured;
      expect(captured.length, 1);
      expect(
        captured.single,
        const PasswordResetConfirmRequestEntity(
          token: 'token',
          newPassword: 'newpassword123',
        ),
      );

      verify(() => sessionManager.logout(reason: 'password_reset')).called(1);

      await sub.cancel();
      await cubit.close();
    });

    test('enforces confirm password mismatch client-side', () async {
      final cubit = PasswordResetConfirmCubit(
        confirmPasswordReset,
        sessionManager,
        token: 'token',
      );
      final emitted = <PasswordResetConfirmState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('differentpassword');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, PasswordResetConfirmStatus.initial);
      expect(
        emitted.last.confirmNewPasswordError?.code,
        ValidationErrorCodes.passwordsDoNotMatch,
      );

      verifyNever(() => confirmPasswordReset(any()));

      await sub.cancel();
      await cubit.close();
    });

    test('maps validation failure fields returned from usecase', () async {
      when(() => confirmPasswordReset(any())).thenAnswer(
        (_) async => left(
          const AuthFailure.validation([
            ValidationError(
              field: 'token',
              message: '',
              code: ValidationErrorCodes.passwordResetTokenExpired,
            ),
          ]),
        ),
      );

      final cubit = PasswordResetConfirmCubit(
        confirmPasswordReset,
        sessionManager,
      );
      final emitted = <PasswordResetConfirmState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.tokenChanged('token');
      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('newpassword123');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, PasswordResetConfirmStatus.failure);
      expect(
        emitted.last.tokenError?.code,
        ValidationErrorCodes.passwordResetTokenExpired,
      );

      await sub.cancel();
      await cubit.close();
    });
  });
}
