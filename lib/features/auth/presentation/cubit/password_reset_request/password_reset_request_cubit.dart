import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_state.dart';

class PasswordResetRequestCubit extends Cubit<PasswordResetRequestState> {
  PasswordResetRequestCubit(this._requestPasswordReset)
    : super(PasswordResetRequestState.initial());

  final RequestPasswordResetUseCase _requestPasswordReset;

  void emailChanged(String value) {
    final result = EmailAddress.create(value);
    final error = result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'email', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        email: value,
        emailTouched: true,
        emailError: error,
        failure: null,
        status: state.status == PasswordResetRequestStatus.failure
            ? PasswordResetRequestStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final result = EmailAddress.create(state.email);
    final emailError = result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'email', message: '', code: f.code),
      (_) => null,
    );

    if (emailError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          status: PasswordResetRequestStatus.initial,
          failure: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PasswordResetRequestStatus.submitting,
        failure: null,
      ),
    );

    final response = await _requestPasswordReset(
      PasswordResetRequestEntity(email: state.email.trim()),
    );

    response.match(
      (failure) => _handleFailure(failure),
      (_) => emit(
        state.copyWith(
          status: PasswordResetRequestStatus.success,
          failure: null,
          emailError: null,
        ),
      ),
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            emailError: _firstFieldError(errors, ['email']),
            status: PasswordResetRequestStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        emit(
          state.copyWith(
            status: PasswordResetRequestStatus.failure,
            failure: failure,
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
