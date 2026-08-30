import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/validation/find_first_validation_error_for_fields.dart';
import 'package:mobile_core_kit/features/auth/domain/input/change_password_input.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/validation/password_field_validator.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePassword)
    : super(ChangePasswordState.initial());

  final ChangePasswordUseCase _changePassword;
  final _effects = StreamController<ChangePasswordEffect>.broadcast();

  Stream<ChangePasswordEffect> get effects => _effects.stream;

  void currentPasswordChanged(String value) {
    final currentError = PasswordFieldValidator.validateCurrentPassword(value);

    // Re-validate "new != current" when current password changes.
    final newPasswordError = PasswordFieldValidator.validateNewPassword(
      state.newPassword,
      currentPassword: value,
    );

    emit(
      state.copyWith(
        currentPassword: value,
        currentPasswordTouched: true,
        currentPasswordError: currentError,
        newPasswordError: newPasswordError,
        confirmNewPasswordError: PasswordFieldValidator.validateConfirmPassword(
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
    final newPasswordError = PasswordFieldValidator.validateNewPassword(
      value,
      currentPassword: state.currentPassword,
    );

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
        confirmNewPasswordError: PasswordFieldValidator.validateConfirmPassword(
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

    final currentPasswordError = PasswordFieldValidator.validateCurrentPassword(
      state.currentPassword,
    );
    final newPasswordError = PasswordFieldValidator.validateNewPassword(
      state.newPassword,
      currentPassword: state.currentPassword,
    );
    final confirmNewPasswordError =
        PasswordFieldValidator.validateConfirmPassword(
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
      state.copyWith(status: ChangePasswordStatus.submitting, failure: null),
    );

    final result = await _changePassword(
      ChangePasswordInput(
        currentPassword: state.currentPassword,
        newPassword: state.newPassword,
      ),
    );

    result.match((failure) => _handleFailure(failure), (_) {
      _effects.add(const ChangePasswordSuccessEffect());
      emit(
        state.copyWith(
          status: ChangePasswordStatus.success,
          failure: null,
          currentPasswordError: null,
          newPasswordError: null,
          confirmNewPasswordError: null,
        ),
      );
    });
  }

  void _handleFailure(AuthFailure failure) {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            currentPasswordError: findFirstValidationErrorForFields(errors, [
              'currentPassword',
            ]),
            newPasswordError: findFirstValidationErrorForFields(errors, [
              'newPassword',
            ]),
            confirmNewPasswordError: findFirstValidationErrorForFields(errors, [
              'confirmNewPassword',
            ]),
            status: ChangePasswordStatus.failure,
            failure: failure,
          ),
        );
        _effects.add(ChangePasswordFailureEffect(failure));
      },
      orElse: () {
        _effects.add(ChangePasswordFailureEffect(failure));
        emit(
          state.copyWith(
            status: ChangePasswordStatus.failure,
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
