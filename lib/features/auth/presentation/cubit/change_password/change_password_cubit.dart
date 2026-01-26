import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/value/confirm_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/login_password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/change_password/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePassword)
    : super(ChangePasswordState.initial());

  final ChangePasswordUseCase _changePassword;

  void currentPasswordChanged(String value) {
    final currentResult = LoginPassword.create(value);
    final currentError = currentResult.fold(
      (ValueFailure f) =>
          ValidationError(field: 'currentPassword', message: '', code: f.code),
      (_) => null,
    );

    // Re-validate "new != current" when current password changes.
    final newPasswordError = _validateNewPassword(
      newPassword: state.newPassword,
      currentPassword: value,
    );

    emit(
      state.copyWith(
        currentPassword: value,
        currentPasswordTouched: true,
        currentPasswordError: currentError,
        newPasswordError: newPasswordError,
        confirmNewPasswordError: _validateConfirmNewPassword(
          newPassword: state.newPassword,
          confirmNewPassword: state.confirmNewPassword,
          newPasswordError: newPasswordError,
        ),
        failure: null,
        status: state.status == ChangePasswordStatus.failure
            ? ChangePasswordStatus.initial
            : state.status,
      ),
    );
  }

  void newPasswordChanged(String value) {
    final newPasswordError = _validateNewPassword(
      newPassword: value,
      currentPassword: state.currentPassword,
    );

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
        status: state.status == ChangePasswordStatus.failure
            ? ChangePasswordStatus.initial
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
        status: state.status == ChangePasswordStatus.failure
            ? ChangePasswordStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final currentPasswordError = _validateCurrentPassword(state.currentPassword);
    final newPasswordError = _validateNewPassword(
      newPassword: state.newPassword,
      currentPassword: state.currentPassword,
    );
    final confirmNewPasswordError = _validateConfirmNewPassword(
      newPassword: state.newPassword,
      confirmNewPassword: state.confirmNewPassword,
      newPasswordError: newPasswordError,
    );

    if (currentPasswordError != null ||
        newPasswordError != null ||
        confirmNewPasswordError != null) {
      emit(
        state.copyWith(
          currentPasswordError: currentPasswordError,
          newPasswordError: newPasswordError,
          confirmNewPasswordError: confirmNewPasswordError,
          status: ChangePasswordStatus.initial,
          failure: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        failure: null,
      ),
    );

    final result = await _changePassword(
      ChangePasswordRequestEntity(
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
      ),
    );

    result.match(
      (failure) => _handleFailure(failure),
      (_) => emit(
        state.copyWith(
          status: ChangePasswordStatus.success,
          failure: null,
          currentPasswordError: null,
          newPasswordError: null,
          confirmNewPasswordError: null,
        ),
      ),
    );
  }

  ValidationError? _validateCurrentPassword(String value) {
    final result = LoginPassword.create(value);
    return result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'currentPassword', message: '', code: f.code),
      (_) => null,
    );
  }

  ValidationError? _validateNewPassword({
    required String newPassword,
    required String currentPassword,
  }) {
    final result = Password.create(newPassword);
    final baseError = result.fold(
      (ValueFailure f) =>
          ValidationError(field: 'newPassword', message: '', code: f.code),
      (_) => null,
    );

    if (baseError != null) return baseError;

    final canCheckSameAsCurrent =
        newPassword.isNotEmpty && currentPassword.isNotEmpty;
    if (canCheckSameAsCurrent && newPassword == currentPassword) {
      return const ValidationError(
        field: 'newPassword',
        message: '',
        code: ValidationErrorCodes.passwordSameAsCurrent,
      );
    }

    return null;
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
            currentPasswordError: _firstFieldError(
              errors,
              ['currentPassword'],
            ),
            newPasswordError: _firstFieldError(errors, ['newPassword']),
            confirmNewPasswordError: _firstFieldError(
              errors,
              ['confirmNewPassword'],
            ),
            status: ChangePasswordStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        emit(
          state.copyWith(
            status: ChangePasswordStatus.failure,
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
