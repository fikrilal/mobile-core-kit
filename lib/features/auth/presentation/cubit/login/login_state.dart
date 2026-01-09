import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

enum LoginStatus {
  initial,
  submitting,
  success,
  failure,
}

enum LoginSubmitMethod { emailPassword, google }

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    @Default(LoginStatus.initial) LoginStatus status,
    LoginSubmitMethod? submittingMethod,
  }) = _LoginState;

  const LoginState._();

  bool get isSubmitting => status == LoginStatus.submitting;

  bool get isSubmittingEmailPassword =>
      isSubmitting && submittingMethod == LoginSubmitMethod.emailPassword;

  bool get isSubmittingGoogle =>
      isSubmitting && submittingMethod == LoginSubmitMethod.google;

  bool get canSubmit =>
      !isSubmitting &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  factory LoginState.initial() => const LoginState();
}
