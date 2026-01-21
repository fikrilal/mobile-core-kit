import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_screens.dart';
import 'package:mobile_core_kit/features/auth/analytics/auth_analytics_targets.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/sign_in_with_google_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(
    this._loginUser,
    this._googleSignIn,
    this._sessionManager,
    this._analytics,
  ) : super(LoginState.initial());

  final LoginUserUseCase _loginUser;
  final SignInWithGoogleUseCase _googleSignIn;
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
        // clear generic error when user edits
        failure: null,
        status: state.status == LoginStatus.failure
            ? LoginStatus.initial
            : state.status,
      ),
    );
  }

  void passwordChanged(String value) {
    final result = LoginPassword.create(value);
    final error = result.fold(
      (f) => ValidationError(field: 'password', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        password: value,
        passwordError: error,
        failure: null,
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
          status: LoginStatus.initial,
          failure: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        submittingMethod: LoginSubmitMethod.emailPassword,
        failure: null,
      ),
    );

    final result = await _loginUser(
      LoginRequestEntity(email: state.email.trim(), password: state.password),
    );

    result.match(
      (failure) {
        _handleFailure(failure);
      },
      (user) async {
        await _handleSuccess(user, method: 'email_password');
      },
    );
  }

  Future<void> signInWithGoogle() async {
    if (state.isSubmitting) return;

    unawaited(
      _analytics.trackButtonClick(
        id: AuthAnalyticsTargets.signInWithGoogle,
        screen: AuthAnalyticsScreens.signIn,
      ),
    );

    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        submittingMethod: LoginSubmitMethod.google,
        failure: null,
      ),
    );

    final result = await _googleSignIn();
    result.match(
      (failure) {
        final isCancelled = failure.maybeWhen(
          cancelled: () => true,
          orElse: () => false,
        );

        if (isCancelled) {
          emit(
            state.copyWith(
              status: LoginStatus.initial,
              submittingMethod: null,
              failure: null,
            ),
          );
          return;
        }

        _handleFailure(failure);
      },
      (session) async {
        await _handleSuccess(session, method: 'google');
      },
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.map(
      network: (_) => _emitFailure(failure),
      cancelled: (_) => _emitFailure(failure),
      unauthenticated: (_) => _emitFailure(failure),
      emailTaken: (_) => _emitFailure(failure),
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
            status: LoginStatus.failure,
            failure: failure,
            submittingMethod: null,
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

  Future<void> _handleSuccess(
    AuthSessionEntity session, {
    required String method,
  }) async {
    await _sessionManager.login(session);

    /// EXAMPLE: login success event with a generic method label.
    /// Do not pass user identifiers or tokens here; use `setUserId`
    /// / `setUserProperty` in a privacy-aware place if needed.
    unawaited(_analytics.trackLogin(method: method));

    emit(
      state.copyWith(
        status: LoginStatus.success,
        failure: null,
        submittingMethod: null,
      ),
    );
  }

  void _emitFailure(AuthFailure failure) {
    emit(
      state.copyWith(
        status: LoginStatus.failure,
        failure: failure,
        submittingMethod: null,
      ),
    );
  }
}
