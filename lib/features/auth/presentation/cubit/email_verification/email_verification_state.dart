import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'email_verification_state.freezed.dart';

enum EmailVerificationStatus { initial, submitting, success, failure }

enum EmailVerificationAction { verify, resend }

@freezed
abstract class EmailVerificationState with _$EmailVerificationState {
  const factory EmailVerificationState({
    @Default('') String token,
    ValidationError? tokenError,
    AuthFailure? failure,
    @Default(EmailVerificationStatus.initial) EmailVerificationStatus status,
    EmailVerificationAction? lastAction,
  }) = _EmailVerificationState;

  const EmailVerificationState._();

  bool get isSubmitting => status == EmailVerificationStatus.submitting;

  bool get isVerifying =>
      isSubmitting && lastAction == EmailVerificationAction.verify;

  bool get isResending =>
      isSubmitting && lastAction == EmailVerificationAction.resend;

  bool get canVerify => !isSubmitting && token.trim().isNotEmpty && tokenError == null;

  bool get canResend => !isSubmitting;

  factory EmailVerificationState.initial() => const EmailVerificationState();
}

