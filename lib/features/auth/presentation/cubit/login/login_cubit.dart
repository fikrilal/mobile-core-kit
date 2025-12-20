import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';

import '../../../analytics/auth_analytics_screens.dart';
import '../../../analytics/auth_analytics_targets.dart';
import '../../../domain/entity/login_request_entity.dart';
import '../../../domain/entity/auth_session_entity.dart';
import '../../../domain/failure/auth_failure.dart';
import '../../../domain/usecase/login_user_usecase.dart';
import '../../../domain/value/email_address.dart';
import '../../../domain/value/login_password.dart';
import '../../../domain/value/value_failure.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._loginUser,
    this._sessionManager,
    this._analytics,
  ) : super(LoginState.initial());

  final LoginUserUseCase _loginUser;
  final SessionManager _sessionManager;
  final AnalyticsTracker _analytics;

  void emailChanged(String value) {
    final result = EmailAddress.create(value);
    final error = result.fold(
      (f) => f.userMessage,
      (_) => null,
    );

    emit(
      state.copyWith(
        email: value,
        emailError: error,
        // clear generic error when user edits
        errorMessage: null,
        status: state.status == LoginStatus.failure
            ? LoginStatus.initial
            : state.status,
      ),
    );
  }

  void passwordChanged(String value) {
    final result = LoginPassword.create(value);
    final error = result.fold(
      (f) => f.userMessage,
      (_) => null,
    );

    emit(
      state.copyWith(
        password: value,
        passwordError: error,
        errorMessage: null,
        status: state.status == LoginStatus.failure
            ? LoginStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    /// EXAMPLE: feature-level analytics hook for a primary CTA.
    /// In real projects, keep the `id` stable (e.g. for A/B tests)
    /// and avoid passing any PII (emails, names, etc.).
    unawaited(
      _analytics.trackButtonClick(
        id: AuthAnalyticsTargets.signInSubmit,
        screen: AuthAnalyticsScreens.signIn,
      ),
    );

    // Re-run validation as a pre-flight check.
    final emailResult = EmailAddress.create(state.email);
    final passwordResult = LoginPassword.create(state.password);

    final emailError = emailResult.fold(
      (f) => f.userMessage,
      (_) => null,
    );
    final passwordError = passwordResult.fold(
      (f) => f.userMessage,
      (_) => null,
    );

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
          status: LoginStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        errorMessage: null,
      ),
    );

    final result = await _loginUser(
      LoginRequestEntity(
        email: state.email.trim(),
        password: state.password,
      ),
    );

    result.match(
      (failure) {
        _handleFailure(failure);
      },
      (user) async {
        await _handleSuccess(user);
      },
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.map(
      network: (_) => _emitError(failure.userMessage),
      emailTaken: (_) => _emitError(failure.userMessage),
      validation: (v) {
        String? emailError;
        String? passwordError;

        for (final ValidationError err in v.errors) {
          if (err.field == 'email' && emailError == null) {
            emailError = err.message;
          } else if (err.field == 'password' && passwordError == null) {
            passwordError = err.message;
          }
        }

        emit(
          state.copyWith(
            emailError: emailError ?? state.emailError,
            passwordError: passwordError ?? state.passwordError,
            status: LoginStatus.failure,
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

    /// EXAMPLE: login success event with a generic method label.
    /// Do not pass user identifiers or tokens here; use `setUserId`
    /// / `setUserProperty` in a privacy-aware place if needed.
    unawaited(
      _analytics.trackLogin(
        method: 'email_password',
      ),
    );

    emit(
      state.copyWith(
        status: LoginStatus.success,
        errorMessage: null,
      ),
    );
  }

  void _emitError(String message) {
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        errorMessage: message,
      ),
    );
  }
}
