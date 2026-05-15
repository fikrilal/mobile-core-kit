import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockChangePasswordUseCase extends Mock
    implements ChangePasswordUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ChangePasswordRequestEntity(
        currentPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      ),
    );
  });

  group('ChangePasswordCubit', () {
    late _MockChangePasswordUseCase changePassword;

    setUp(() {
      changePassword = _MockChangePasswordUseCase();
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = ChangePasswordCubit(changePassword);
      final emitted = <ChangePasswordState>[];
      final effects = <ChangePasswordEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, ChangePasswordStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.currentPasswordError?.code,
        ValidationErrorCodes.required,
      );
      expect(
        emitted.single.newPasswordError?.code,
        ValidationErrorCodes.required,
      );
      expect(emitted.single.confirmNewPasswordError, isNull);
      expect(effects, isEmpty);

      verifyNever(() => changePassword(any()));

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test('changes password and emits submitting -> success', () async {
      when(() => changePassword(any())).thenAnswer((_) async => right(unit));

      final cubit = ChangePasswordCubit(changePassword);
      final emitted = <ChangePasswordState>[];
      final effects = <ChangePasswordEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      cubit.currentPasswordChanged('oldpassword123');
      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('newpassword123');
      await cubit.submit();
      await pumpEventQueue();

      expect(
        emitted.any((s) => s.status == ChangePasswordStatus.submitting),
        true,
      );
      expect(emitted.last.status, ChangePasswordStatus.success);
      expect(effects, hasLength(1));
      expect(effects.single, isA<ChangePasswordSuccessEffect>());

      final captured = verify(() => changePassword(captureAny())).captured;
      expect(captured.length, 1);
      expect(
        captured.single,
        const ChangePasswordRequestEntity(
          currentPassword: 'oldpassword123',
          newPassword: 'newpassword123',
        ),
      );

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test('enforces newPassword != currentPassword client-side', () async {
      final cubit = ChangePasswordCubit(changePassword);
      final emitted = <ChangePasswordState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.currentPasswordChanged('samepassword');
      cubit.newPasswordChanged('samepassword');
      cubit.confirmNewPasswordChanged('samepassword');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, ChangePasswordStatus.initial);
      expect(
        emitted.last.newPasswordError?.code,
        ValidationErrorCodes.passwordSameAsCurrent,
      );

      verifyNever(() => changePassword(any()));

      await sub.cancel();
      await cubit.close();
    });

    test('maps validation failure fields returned from usecase', () async {
      when(() => changePassword(any())).thenAnswer(
        (_) async => left(
          const AuthFailure.validation([
            ValidationError(
              field: 'currentPassword',
              message: '',
              code: ValidationErrorCodes.currentPasswordInvalid,
            ),
          ]),
        ),
      );

      final cubit = ChangePasswordCubit(changePassword);
      final emitted = <ChangePasswordState>[];
      final effects = <ChangePasswordEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      cubit.currentPasswordChanged('oldpassword123');
      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('newpassword123');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, ChangePasswordStatus.failure);
      expect(
        emitted.last.currentPasswordError?.code,
        ValidationErrorCodes.currentPasswordInvalid,
      );
      expect(effects, hasLength(1));
      expect(effects.single, isA<ChangePasswordFailureEffect>());

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });

    test('emits failure for passwordNotSet', () async {
      when(
        () => changePassword(any()),
      ).thenAnswer((_) async => left(const AuthFailure.passwordNotSet()));

      final cubit = ChangePasswordCubit(changePassword);
      final emitted = <ChangePasswordState>[];
      final effects = <ChangePasswordEffect>[];
      final sub = cubit.stream.listen(emitted.add);
      final effectSub = cubit.effects.listen(effects.add);

      cubit.currentPasswordChanged('oldpassword123');
      cubit.newPasswordChanged('newpassword123');
      cubit.confirmNewPasswordChanged('newpassword123');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.last.status, ChangePasswordStatus.failure);
      expect(emitted.last.failure, const AuthFailure.passwordNotSet());
      expect(effects, hasLength(1));
      expect(effects.single, isA<ChangePasswordFailureEffect>());

      await sub.cancel();
      await effectSub.cancel();
      await cubit.close();
    });
  });
}
