import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'change_password_state.freezed.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

@freezed
abstract class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState({
    @Default('') String currentPassword,
    @Default('') String newPassword,
    @Default('') String confirmNewPassword,
    ValidationError? currentPasswordError,
    ValidationError? newPasswordError,
    ValidationError? confirmNewPasswordError,
    AuthFailure? failure,
    @Default(ChangePasswordStatus.initial) ChangePasswordStatus status,
  }) = _ChangePasswordState;

  const ChangePasswordState._();

  bool get isSubmitting => status == ChangePasswordStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      currentPassword.isNotEmpty &&
      newPassword.isNotEmpty &&
      confirmNewPassword.isNotEmpty &&
      currentPasswordError == null &&
      newPasswordError == null &&
      confirmNewPasswordError == null;

  factory ChangePasswordState.initial() => const ChangePasswordState();
}

