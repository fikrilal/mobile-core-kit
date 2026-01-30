import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'register_state.freezed.dart';

enum RegisterStatus { initial, submitting, success, failure }

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String email,
    @Default('') String password,
    ValidationError? emailError,
    ValidationError? passwordError,
    AuthFailure? failure,
    @Default(RegisterStatus.initial) RegisterStatus status,
  }) = _RegisterState;

  const RegisterState._();

  bool get isSubmitting => status == RegisterStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  factory RegisterState.initial() => const RegisterState();
}
