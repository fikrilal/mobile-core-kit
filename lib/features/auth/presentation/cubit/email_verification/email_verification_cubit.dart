import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/resend_email_verification_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/verify_email_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_verification_token.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_state.dart';

class EmailVerificationCubit extends Cubit<EmailVerificationState> {
  EmailVerificationCubit(this._verifyEmail, this._resendEmailVerification)
    : super(EmailVerificationState.initial());

  final VerifyEmailUseCase _verifyEmail;
  final ResendEmailVerificationUseCase _resendEmailVerification;

  void tokenChanged(String value) {
    final result = EmailVerificationToken.create(value);
    final error = result.fold(
      (f) => ValidationError(field: 'token', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        token: value,
        tokenError: error,
        failure: null,
        status: state.status == EmailVerificationStatus.failure
            ? EmailVerificationStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> verify() async {
    if (state.isSubmitting) return;
    if (state.status == EmailVerificationStatus.success &&
        state.lastAction == EmailVerificationAction.verify) {
      return;
    }

    final result = EmailVerificationToken.create(state.token);
    final tokenError = result.fold(
      (f) => ValidationError(field: 'token', message: '', code: f.code),
      (_) => null,
    );

    if (tokenError != null) {
      emit(
        state.copyWith(
          tokenError: tokenError,
          failure: null,
          status: EmailVerificationStatus.initial,
          lastAction: EmailVerificationAction.verify,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: EmailVerificationStatus.submitting,
        lastAction: EmailVerificationAction.verify,
        failure: null,
      ),
    );

    final response = await _verifyEmail(
      VerifyEmailRequestEntity(token: state.token.trim()),
    );

    response.match(
      (failure) => _handleFailure(failure, EmailVerificationAction.verify),
      (_) => emit(
        state.copyWith(
          status: EmailVerificationStatus.success,
          lastAction: EmailVerificationAction.verify,
          failure: null,
          tokenError: null,
        ),
      ),
    );
  }

  Future<void> resendVerificationEmail() async {
    if (state.isSubmitting) return;
    if (state.status == EmailVerificationStatus.success &&
        state.lastAction == EmailVerificationAction.resend) {
      return;
    }

    emit(
      state.copyWith(
        status: EmailVerificationStatus.submitting,
        lastAction: EmailVerificationAction.resend,
        failure: null,
      ),
    );

    final response = await _resendEmailVerification();

    response.match(
      (failure) => _handleFailure(failure, EmailVerificationAction.resend),
      (_) => emit(
        state.copyWith(
          status: EmailVerificationStatus.success,
          lastAction: EmailVerificationAction.resend,
          failure: null,
        ),
      ),
    );
  }

  void _handleFailure(AuthFailure failure, EmailVerificationAction action) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            tokenError: _firstFieldError(errors, ['token']),
            status: EmailVerificationStatus.failure,
            failure: failure,
            lastAction: action,
          ),
        );
      },
      orElse: () {
        emit(
          state.copyWith(
            status: EmailVerificationStatus.failure,
            failure: failure,
            lastAction: action,
          ),
        );
      },
    );
  }

  ValidationError? _firstFieldError(
    List<ValidationError> errors,
    List<String> fieldCandidates,
  ) {
    for (final err in errors) {
      final field = err.field;
      if (field == null || field.isEmpty) continue;

      for (final candidate in fieldCandidates) {
        if (field == candidate || field.endsWith(candidate)) return err;
      }
    }
    return null;
  }
}
