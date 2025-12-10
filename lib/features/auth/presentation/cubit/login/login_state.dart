import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

enum LoginStatus {
  initial,
  submitting,
  success,
  failure,
}

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    @Default(LoginStatus.initial) LoginStatus status,
  }) = _LoginState;

  const LoginState._();

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  factory LoginState.initial() => const LoginState();
}

