import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  CompleteProfileCubit(this._patchMeProfile, this._sessionManager)
    : super(CompleteProfileState.initial());

  final PatchMeProfileUseCase _patchMeProfile;
  final SessionManager _sessionManager;

  static const int _minNameLength = 2;
  static const int _maxNameLength = 50;

  void givenNameChanged(String value) {
    emit(
      state.copyWith(
        givenName: value,
        givenNameError: _validateRequiredName(value, field: 'givenName'),
        failure: null,
        status: state.status == CompleteProfileStatus.failure
            ? CompleteProfileStatus.initial
            : state.status,
      ),
    );
  }

  void familyNameChanged(String value) {
    emit(
      state.copyWith(
        familyName: value,
        familyNameError: _validateOptionalName(value, field: 'familyName'),
        failure: null,
        status: state.status == CompleteProfileStatus.failure
            ? CompleteProfileStatus.initial
            : state.status,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final givenError = _validateRequiredName(state.givenName, field: 'givenName');
    final familyError = _validateOptionalName(
      state.familyName,
      field: 'familyName',
    );

    if (givenError != null || familyError != null) {
      emit(
        state.copyWith(
          givenNameError: givenError,
          familyNameError: familyError,
          failure: null,
          status: CompleteProfileStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: CompleteProfileStatus.submitting, failure: null),
    );

    final given = state.givenName.trim();
    final familyTrimmed = state.familyName.trim();
    final family = familyTrimmed.isEmpty ? null : familyTrimmed;
    final displayName = family == null ? given : '$given $family';

    final result = await _patchMeProfile(
      PatchMeProfileRequestEntity(
        givenName: given,
        familyName: family,
        displayName: displayName,
      ),
    );

    await result.match(
      (failure) async {
        failure.maybeWhen(
          validation: (errors) {
            emit(
              state.copyWith(
                givenNameError:
                    _firstFieldError(errors, ['givenName', 'profile.givenName']),
                familyNameError: _firstFieldError(
                  errors,
                  ['familyName', 'profile.familyName'],
                ),
                status: CompleteProfileStatus.failure,
                failure: failure,
              ),
            );
          },
          orElse: () {
            emit(
              state.copyWith(
                status: CompleteProfileStatus.failure,
                failure: failure,
              ),
            );
          },
        );
      },
      (user) async {
        await _sessionManager.setUser(user);
        emit(state.copyWith(status: CompleteProfileStatus.success));
      },
    );
  }

  ValidationError? _validateRequiredName(String value, {required String field}) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return ValidationError(
        field: field,
        message: '',
        code: ValidationErrorCodes.required,
      );
    }
    if (normalized.length < _minNameLength) {
      return ValidationError(
        field: field,
        message: '',
        code: ValidationErrorCodes.nameTooShort,
      );
    }
    if (normalized.length > _maxNameLength) {
      return ValidationError(
        field: field,
        message: '',
        code: ValidationErrorCodes.nameTooLong,
      );
    }
    return null;
  }

  ValidationError? _validateOptionalName(String value, {required String field}) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    if (normalized.length < _minNameLength) {
      return ValidationError(
        field: field,
        message: '',
        code: ValidationErrorCodes.nameTooShort,
      );
    }
    if (normalized.length > _maxNameLength) {
      return ValidationError(
        field: field,
        message: '',
        code: ValidationErrorCodes.nameTooLong,
      );
    }
    return null;
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
