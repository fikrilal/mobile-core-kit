import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/confirm_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/reset_token.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_state.dart';

class PasswordResetConfirmCubit extends Cubit<PasswordResetConfirmState> {
  PasswordResetConfirmCubit(
    this._confirmPasswordReset,
    this._sessionManager, {
    String token = '',
  }) : super(PasswordResetConfirmState.initial(token: token));

  final ConfirmPasswordResetUseCase _confirmPasswordReset;
  final SessionManager _sessionManager;

  void tokenChanged(String value) {
    final result = ResetToken.create(value);
    final error = result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'token', message: '', code: f.code),
      (_) => null,
    );

    emit(
      state.copyWith(
        token: value,
        tokenError: error,
        failure: null,
        status: state.status == PasswordResetConfirmStatus.failure
            ? PasswordResetConfirmStatus.initial
            : state.status,
      ),
    );
  }

  void newPasswordChanged(String value) {
    final newPasswordError = _validateNewPassword(value);

    emit(
      state.copyWith(
        newPassword: value,
        newPasswordTouched: true,
        newPasswordError: newPasswordError,
        confirmNewPasswordError: _validateConfirmNewPassword(
          newPassword: value,
          confirmNewPassword: state.confirmNewPassword,
          newPasswordError: newPasswordError,
        ),
        failure: null,
        status: state.status == PasswordResetConfirmStatus.failure
            ? PasswordResetConfirmStatus.initial
            : state.status,
      ),
    );
  }

  void confirmNewPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmNewPassword: value,
        confirmNewPasswordTouched: true,
        confirmNewPasswordError: _validateConfirmNewPassword(
          newPassword: state.newPassword,
          confirmNewPassword: value,
          newPasswordError: state.newPasswordError,
        ),
        failure: null,
        status: state.status == PasswordResetConfirmStatus.failure
            ? PasswordResetConfirmStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final tokenError = _validateToken(state.token);
    final newPasswordError = _validateNewPassword(state.newPassword);
    final confirmNewPasswordError = _validateConfirmNewPassword(
      newPassword: state.newPassword,
      confirmNewPassword: state.confirmNewPassword,
      newPasswordError: newPasswordError,
    );

    if (tokenError != null ||
        newPasswordError != null ||
        confirmNewPasswordError != null) {
      emit(
        state.copyWith(
          tokenError: tokenError,
          newPasswordError: newPasswordError,
          confirmNewPasswordError: confirmNewPasswordError,
          status: PasswordResetConfirmStatus.initial,
          failure: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PasswordResetConfirmStatus.submitting,
        failure: null,
      ),
    );

    final result = await _confirmPasswordReset(
      PasswordResetConfirmRequestEntity(
        token: state.token.trim(),
        newPassword: state.newPassword,
      ),
    );

    await result.match((failure) async => _handleFailure(failure), (_) async {
      // Backend revokes all sessions/refresh tokens on success.
      await _sessionManager.logout(reason: 'password_reset');

      emit(
        state.copyWith(
          status: PasswordResetConfirmStatus.success,
          failure: null,
          tokenError: null,
          newPasswordError: null,
          confirmNewPasswordError: null,
        ),
      );
    });
  }

  ValidationError? _validateToken(String value) {
    final result = ResetToken.create(value);
    return result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'token', message: '', code: f.code),
      (_) => null,
    );
  }

  ValidationError? _validateNewPassword(String value) {
    final result = Password.create(value);
    return result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'newPassword', message: '', code: f.code),
      (_) => null,
    );
  }

  ValidationError? _validateConfirmNewPassword({
    required String newPassword,
    required String confirmNewPassword,
    required ValidationError? newPasswordError,
  }) {
    // Avoid noisy "does not match" while the new password itself is invalid.
    if (newPasswordError != null) return null;

    final result = ConfirmPassword.create(newPassword, confirmNewPassword);
    return result.fold(
      (ValueFailure f) => ValidationError(
        field: 'confirmNewPassword',
        message: '',
        code: f.code,
      ),
      (_) => null,
    );
  }

  void _handleFailure(AuthFailure failure) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            tokenError: _firstFieldError(errors, ['token']),
            newPasswordError: _firstFieldError(errors, ['newPassword']),
            confirmNewPasswordError: _firstFieldError(errors, [
              'confirmNewPassword',
            ]),
            status: PasswordResetConfirmStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        emit(
          state.copyWith(
            status: PasswordResetConfirmStatus.failure,
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
