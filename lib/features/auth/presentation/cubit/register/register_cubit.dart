import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_screens.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_targets.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerUser, this._sessionManager, this._analytics)
    : super(RegisterState.initial());

  final RegisterUserUseCase _registerUser;
  final SessionManager _sessionManager;
  final AnalyticsTracker _analytics;

  void emailChanged(String value) {
    final result = EmailAddress.create(value);
    final error = result.fold(
      (f) => ValidationError(field: 'email', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        email: value,
        emailError: error,
        failure: null,
        status: state.status == RegisterStatus.failure
            ? RegisterStatus.initial
            : state.status,
      ),
    );
  }

  void passwordChanged(String value) {
    final result = Password.create(value);
    final error = result.fold(
      (f) => ValidationError(field: 'password', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        password: value,
        passwordError: error,
        failure: null,
        status: state.status == RegisterStatus.failure
            ? RegisterStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    unawaited(
      _analytics.trackButtonClick(
        id: AuthAnalyticsTargets.registerSubmit,
        screen: AuthAnalyticsScreens.register,
      ),
    );

    // Re-run validation as a pre-flight check.
    final emailResult = EmailAddress.create(state.email);
    final passwordResult = Password.create(state.password);

    final emailError = emailResult.fold(
      (f) => ValidationError(field: 'email', message: '', code: f.code),
      (_) => null,
    );
    final passwordError = passwordResult.fold(
      (f) => ValidationError(field: 'password', message: '', code: f.code),
      (_) => null,
    );

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          status: RegisterStatus.initial,
          failure: null,
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.submitting, failure: null));

    final result = await _registerUser(
      RegisterRequestEntity(
        email: state.email.trim(),
        password: state.password,
      ),
    );

    result.match(
      (failure) => _handleFailure(failure),
      (session) async => _handleSuccess(session),
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.map(
      network: (_) => _emitFailure(failure),
      cancelled: (_) => _emitFailure(failure),
      unauthenticated: (_) => _emitFailure(failure),
      passwordNotSet: (_) => _emitFailure(failure),
      emailTaken: (_) {
        final emailTakenError = ValidationError(
          field: 'email',
          message: '',
          code: 'email_taken',
        );

        emit(
          state.copyWith(
            emailError: emailTakenError,
            status: RegisterStatus.failure,
            failure: failure,
          ),
        );
      },
      emailNotVerified: (_) => _emitFailure(failure),
      validation: (v) {
        ValidationError? emailError;
        ValidationError? passwordError;

        for (final ValidationError err in v.errors) {
          if (err.field == 'email' && emailError == null) {
            emailError = err;
          } else if (err.field == 'password' && passwordError == null) {
            passwordError = err;
          }
        }

        emit(
          state.copyWith(
            emailError: emailError ?? state.emailError,
            passwordError: passwordError ?? state.passwordError,
            status: RegisterStatus.failure,
            failure: failure,
          ),
        );
      },
      invalidCredentials: (_) => _emitFailure(failure),
      tooManyRequests: (_) => _emitFailure(failure),
      userSuspended: (_) => _emitFailure(failure),
      serverError: (_) => _emitFailure(failure),
      unexpected: (_) => _emitFailure(failure),
    );
  }

  Future<void> _handleSuccess(AuthSessionEntity session) async {
    await _sessionManager.login(session);
    emit(state.copyWith(status: RegisterStatus.success, failure: null));
  }

  void _emitFailure(AuthFailure failure) {
    emit(state.copyWith(status: RegisterStatus.failure, failure: failure));
  }
}
