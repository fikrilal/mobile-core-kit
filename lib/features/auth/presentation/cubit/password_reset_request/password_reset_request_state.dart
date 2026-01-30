import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'password_reset_request_state.freezed.dart';

enum PasswordResetRequestStatus { initial, submitting, success, failure }

@freezed
abstract class PasswordResetRequestState with _$PasswordResetRequestState {
  const factory PasswordResetRequestState({
    @Default('') String email,
    @Default(false) bool emailTouched,
    ValidationError? emailError,
    AuthFailure? failure,
    @Default(PasswordResetRequestStatus.initial)
    PasswordResetRequestStatus status,
  }) = _PasswordResetRequestState;

  const PasswordResetRequestState._();

  bool get isSubmitting => status == PasswordResetRequestStatus.submitting;

  bool get canSubmit =>
      !isSubmitting && email.trim().isNotEmpty && emailError == null;

  factory PasswordResetRequestState.initial() =>
      const PasswordResetRequestState();
}
