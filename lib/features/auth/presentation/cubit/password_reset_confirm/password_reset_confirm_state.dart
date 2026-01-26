import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'password_reset_confirm_state.freezed.dart';

enum PasswordResetConfirmStatus { initial, submitting, success, failure }

@freezed
abstract class PasswordResetConfirmState with _$PasswordResetConfirmState {
  const factory PasswordResetConfirmState({
    @Default('') String token,
    @Default('') String newPassword,
    @Default('') String confirmNewPassword,
    @Default(false) bool newPasswordTouched,
    @Default(false) bool confirmNewPasswordTouched,
    ValidationError? tokenError,
    ValidationError? newPasswordError,
    ValidationError? confirmNewPasswordError,
    AuthFailure? failure,
    @Default(PasswordResetConfirmStatus.initial)
    PasswordResetConfirmStatus status,
  }) = _PasswordResetConfirmState;

  const PasswordResetConfirmState._();

  bool get isSubmitting => status == PasswordResetConfirmStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      token.trim().isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmNewPassword.isNotEmpty &&
      tokenError == null &&
      newPasswordError == null &&
      confirmNewPasswordError == null;

  factory PasswordResetConfirmState.initial({String token = ''}) =>
      PasswordResetConfirmState(token: token);
}
