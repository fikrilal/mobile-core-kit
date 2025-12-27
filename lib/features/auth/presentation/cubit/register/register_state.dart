import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

enum RegisterStatus { initial, submitting, success, failure }

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String email,
    @Default('') String password,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    @Default(RegisterStatus.initial) RegisterStatus status,
  }) = _RegisterState;

  const RegisterState._();

  bool get isSubmitting => status == RegisterStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      password.isNotEmpty &&
      firstNameError == null &&
      lastNameError == null &&
      emailError == null &&
      passwordError == null;

  factory RegisterState.initial() => const RegisterState();
}
