import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/find_first_validation_error_for_fields.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_state.dart';

class PasswordResetRequestCubit extends Cubit<PasswordResetRequestState> {
  PasswordResetRequestCubit(this._requestPasswordReset)
    : super(PasswordResetRequestState.initial());

  final RequestPasswordResetUseCase _requestPasswordReset;
  final _effects = StreamController<PasswordResetRequestEffect>.broadcast();

  Stream<PasswordResetRequestEffect> get effects => _effects.stream;

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

    final response = await _requestPasswordReset(state.email);

    response.match((failure) => _handleFailure(failure), (_) {
      _effects.add(const PasswordResetRequestSuccessEffect());
      emit(
        state.copyWith(
          status: PasswordResetRequestStatus.success,
          failure: null,
          emailError: null,
        ),
      );
    });
  }

  void _handleFailure(AuthFailure failure) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            emailError: findFirstValidationErrorForFields(errors, ['email']),
            status: PasswordResetRequestStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        _effects.add(PasswordResetRequestFailureEffect(failure));
        emit(
          state.copyWith(
            status: PasswordResetRequestStatus.failure,
            failure: failure,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    return super.close();
  }
}
