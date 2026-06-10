import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/find_first_validation_error_for_fields.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/family_name.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/given_name.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  ProfileFormCubit(this._patchMeProfile, this._sessionManager)
    : super(ProfileFormState.initial());

  final PatchMeProfileUseCase _patchMeProfile;
  final SessionManager _sessionManager;
  final _effects = StreamController<ProfileFormEffect>.broadcast();

  Stream<ProfileFormEffect> get effects => _effects.stream;

  @protected
  String? get currentUserId =>
      _sessionManager.sessionNotifier.value?.user?.id.trim();

  @protected
  UserProfileEntity? get currentProfile =>
      _sessionManager.sessionNotifier.value?.user?.profile;

  void setInitialValues({
    required String givenName,
    required String familyName,
  }) {
    emit(
      state.copyWith(
        givenName: givenName,
        familyName: familyName,
        givenNameError: _validateGivenName(givenName),
        familyNameError: _validateFamilyName(familyName),
      ),
    );
  }

  void givenNameChanged(String value) {
    emit(
      state.copyWith(
        givenName: value,
        givenNameError: _validateGivenName(value),
        failure: null,
        status: _statusAfterInput(),
      ),
    );
    onFieldChanged();
  }

  void familyNameChanged(String value) {
    emit(
      state.copyWith(
        familyName: value,
        familyNameError: _validateFamilyName(value),
        failure: null,
        status: _statusAfterInput(),
      ),
    );
    onFieldChanged();
  }

  Future<void> submit() async {
    if (state.isSubmitting || state.status == ProfileFormStatus.success) return;

    final givenError = _validateGivenName(state.givenName);
    final familyError = _validateFamilyName(state.familyName);
    if (givenError != null || familyError != null) {
      emit(
        state.copyWith(
          givenNameError: givenError,
          familyNameError: familyError,
          failure: null,
          status: ProfileFormStatus.initial,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileFormStatus.submitting, failure: null));
    final userId = currentUserId;
    final result = await _patchMeProfile(
      PatchMeProfileRequestEntity(
        givenName: state.givenName,
        familyName: state.familyName,
        displayName: [
          state.givenName.trim(),
          state.familyName.trim(),
        ].where((part) => part.isNotEmpty).join(' '),
      ),
    );

    await result.match(_handleFailure, (user) async {
      await _sessionManager.setUser(user);
      await onSubmitSuccess(userId);
      emit(state.copyWith(status: ProfileFormStatus.success));
    });
  }

  @protected
  void onFieldChanged() {}

  @protected
  Future<void> onSubmitSuccess(String? userId) async {}

  ProfileFormStatus _statusAfterInput() {
    return state.status == ProfileFormStatus.failure
        ? ProfileFormStatus.initial
        : state.status;
  }

  Future<void> _handleFailure(AuthFailure failure) async {
    failure.maybeWhen(
      validation: (errors) {
        emit(
          state.copyWith(
            givenNameError: findFirstValidationErrorForFields(errors, [
              'givenName',
              'profile.givenName',
            ]),
            familyNameError: findFirstValidationErrorForFields(errors, [
              'familyName',
              'profile.familyName',
            ]),
            status: ProfileFormStatus.failure,
            failure: failure,
          ),
        );
      },
      orElse: () {
        emit(
          state.copyWith(status: ProfileFormStatus.failure, failure: failure),
        );
      },
    );
    _effects.add(ProfileFormFailureEffect(failure));
  }

  ValidationError? _validateGivenName(String input) {
    return GivenName.create(input).fold(
      (failure) =>
          ValidationError(field: 'givenName', message: '', code: failure.code),
      (_) => null,
    );
  }

  ValidationError? _validateFamilyName(String input) {
    return FamilyName.createOptional(input).fold(
      (failure) =>
          ValidationError(field: 'familyName', message: '', code: failure.code),
      (_) => null,
    );
  }

  @override
  Future<void> close() async {
    unawaited(_effects.close());
    await super.close();
  }
}
