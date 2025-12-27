import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';

import '../../../analytics/auth_analytics_screens.dart';
import '../../../analytics/auth_analytics_targets.dart';
import '../../../domain/entity/auth_session_entity.dart';
import '../../../domain/entity/register_request_entity.dart';
import '../../../domain/failure/auth_failure.dart';
import '../../../domain/usecase/register_user_usecase.dart';
import '../../../domain/value/email_address.dart';
import '../../../domain/value/password.dart';
import '../../../domain/value/person_name.dart';
import '../../../domain/value/value_failure.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerUser, this._sessionManager, this._analytics)
    : super(RegisterState.initial());

  final RegisterUserUseCase _registerUser;
  final SessionManager _sessionManager;
  final AnalyticsTracker _analytics;

  void firstNameChanged(String value) {
    final result = PersonName.create(value);
    final error = result.fold((f) => f.userMessage, (_) => null);

    emit(
      state.copyWith(
        firstName: value,
        firstNameError: error,
        errorMessage: null,
        status: state.status == RegisterStatus.failure
            ? RegisterStatus.initial
            : state.status,
      ),
    );
  }

  void lastNameChanged(String value) {
    final result = PersonName.create(value);
    final error = result.fold((f) => f.userMessage, (_) => null);

    emit(
      state.copyWith(
        lastName: value,
        lastNameError: error,
        errorMessage: null,
        status: state.status == RegisterStatus.failure
            ? RegisterStatus.initial
            : state.status,
      ),
    );
  }

  void emailChanged(String value) {
    final result = EmailAddress.create(value);
    final error = result.fold((f) => f.userMessage, (_) => null);

    emit(
      state.copyWith(
        email: value,
        emailError: error,
        errorMessage: null,
        status: state.status == RegisterStatus.failure
            ? RegisterStatus.initial
            : state.status,
      ),
    );
  }

  void passwordChanged(String value) {
    final result = Password.create(value);
    final error = result.fold((f) => f.userMessage, (_) => null);

    emit(
      state.copyWith(
        password: value,
        passwordError: error,
        errorMessage: null,
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
    final firstNameResult = PersonName.create(state.firstName);
    final lastNameResult = PersonName.create(state.lastName);
    final emailResult = EmailAddress.create(state.email);
    final passwordResult = Password.create(state.password);

    final firstNameError = firstNameResult.fold(
      (f) => f.userMessage,
      (_) => null,
    );
    final lastNameError = lastNameResult.fold(
      (f) => f.userMessage,
      (_) => null,
    );
    final emailError = emailResult.fold((f) => f.userMessage, (_) => null);
    final passwordError = passwordResult.fold(
      (f) => f.userMessage,
      (_) => null,
    );

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        passwordError != null) {
      emit(
        state.copyWith(
          firstNameError: firstNameError,
          lastNameError: lastNameError,
          emailError: emailError,
          passwordError: passwordError,
          status: RegisterStatus.initial,
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.submitting, errorMessage: null));

    final result = await _registerUser(
      RegisterRequestEntity(
        email: state.email.trim(),
        password: state.password,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
      ),
    );

    result.match(
      (failure) => _handleFailure(failure),
      (session) async => _handleSuccess(session),
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.map(
      network: (_) => _emitError(failure.userMessage),
      unauthenticated: (_) => _emitError(failure.userMessage),
      emailTaken: (_) {
        emit(
          state.copyWith(
            emailError: failure.userMessage,
            status: RegisterStatus.failure,
            errorMessage: failure.userMessage,
          ),
        );
      },
      emailNotVerified: (_) => _emitError(failure.userMessage),
      validation: (v) {
        String? firstNameError;
        String? lastNameError;
        String? emailError;
        String? passwordError;

        for (final ValidationError err in v.errors) {
          if (err.field == 'firstName' && firstNameError == null) {
            firstNameError = err.message;
          } else if (err.field == 'lastName' && lastNameError == null) {
            lastNameError = err.message;
          } else if (err.field == 'email' && emailError == null) {
            emailError = err.message;
          } else if (err.field == 'password' && passwordError == null) {
            passwordError = err.message;
          }
        }

        emit(
          state.copyWith(
            firstNameError: firstNameError ?? state.firstNameError,
            lastNameError: lastNameError ?? state.lastNameError,
            emailError: emailError ?? state.emailError,
            passwordError: passwordError ?? state.passwordError,
            status: RegisterStatus.failure,
            errorMessage: failure.userMessage,
          ),
        );
      },
      invalidCredentials: (_) => _emitError(failure.userMessage),
      tooManyRequests: (_) => _emitError(failure.userMessage),
      serverError: (_) => _emitError(failure.userMessage),
      unexpected: (_) => _emitError(failure.userMessage),
    );
  }

  Future<void> _handleSuccess(AuthSessionEntity session) async {
    await _sessionManager.login(session);
    emit(state.copyWith(status: RegisterStatus.success, errorMessage: null));
  }

  void _emitError(String message) {
    emit(state.copyWith(status: RegisterStatus.failure, errorMessage: message));
  }
}
