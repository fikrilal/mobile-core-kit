import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/find_first_validation_error_for_fields.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/domain/input/password_reset_confirmation_input.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/validation/password_field_validator.dart';
import 'package:mobile_core_kit/features/auth/domain/value/reset_token.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_confirm/password_reset_confirm_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_confirm/password_reset_confirm_state.dart';

class PasswordResetConfirmCubit extends Cubit<PasswordResetConfirmState> {
  PasswordResetConfirmCubit(
    this._confirmPasswordReset,
    this._sessionManager, {
    String token = '',
  }) : super(PasswordResetConfirmState.initial(token: token));

  final ConfirmPasswordResetUseCase _confirmPasswordReset;
  final SessionManager _sessionManager;
  final _effects = StreamController<PasswordResetConfirmEffect>.broadcast();

  Stream<PasswordResetConfirmEffect> get effects => _effects.stream;

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
    final newPasswordError = PasswordFieldValidator.validateNewPassword(value);

    emit(
      state.copyWith(
        newPassword: value,
        newPasswordTouched: true,
        newPasswordError: newPasswordError,
        confirmNewPasswordError: PasswordFieldValidator.validateConfirmPassword(
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
        confirmNewPasswordError: PasswordFieldValidator.validateConfirmPassword(
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
    final newPasswordError = PasswordFieldValidator.validateNewPassword(
      state.newPassword,
    );
    final confirmNewPasswordError =
        PasswordFieldValidator.validateConfirmPassword(
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
      PasswordResetConfirmationInput(
        token: state.token,
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

  void _handleFailure(AuthFailure failure) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            tokenError: findFirstValidationErrorForFields(errors, ['token']),
            newPasswordError: findFirstValidationErrorForFields(errors, [
              'newPassword',
            ]),
            confirmNewPasswordError: findFirstValidationErrorForFields(errors, [
              'confirmNewPassword',
            ]),
            status: PasswordResetConfirmStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        _effects.add(PasswordResetConfirmFailureEffect(failure));
        emit(
          state.copyWith(
            status: PasswordResetConfirmStatus.failure,
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
