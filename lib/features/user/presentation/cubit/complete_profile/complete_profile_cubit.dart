import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/validation/validation_error.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/value/value_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/value/family_name.dart';
import 'package:mobile_core_kit/features/user/domain/value/given_name.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  CompleteProfileCubit(
    this._getDraft,
    this._saveDraft,
    this._clearDraft,
    this._patchMeProfile,
    this._sessionManager,
  ) : super(CompleteProfileState.initial());

  final GetProfileDraftUseCase _getDraft;
  final SaveProfileDraftUseCase _saveDraft;
  final ClearProfileDraftUseCase _clearDraft;
  final PatchMeProfileUseCase _patchMeProfile;
  final SessionManager _sessionManager;

  Timer? _draftSaveTimer;
  static const Duration _draftSaveDebounce = MotionDurations.long;

  String? get _currentUserId =>
      _sessionManager.sessionNotifier.value?.user?.id.trim();

  Future<void> loadDraft() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    final draft = await _getDraft(userId: userId);

    // Guard against applying stale drafts after logout/login.
    if (_currentUserId != userId) return;
    if (draft == null) return;

    // Avoid overriding what the user has already typed if they start typing
    // before the async draft load completes.
    final givenName = state.givenName.trim().isEmpty
        ? draft.givenName
        : state.givenName;
    final familyName = state.familyName.trim().isEmpty
        ? (draft.familyName ?? '')
        : state.familyName;

    emit(
      state.copyWith(
        givenName: givenName,
        familyName: familyName,
        givenNameError: _validateGivenName(givenName),
        familyNameError: _validateFamilyName(familyName),
        failure: null,
        status: state.status == CompleteProfileStatus.failure
            ? CompleteProfileStatus.initial
            : state.status,
      ),
    );
  }

  void givenNameChanged(String value) {
    final error = _validateGivenName(value);
    emit(
      state.copyWith(
        givenName: value,
        givenNameError: error,
        failure: null,
        status: state.status == CompleteProfileStatus.failure
            ? CompleteProfileStatus.initial
            : state.status,
      ),
    );
    _scheduleDraftSave();
  }

  void familyNameChanged(String value) {
    final error = _validateFamilyName(value);
    emit(
      state.copyWith(
        familyName: value,
        familyNameError: error,
        failure: null,
        status: state.status == CompleteProfileStatus.failure
            ? CompleteProfileStatus.initial
            : state.status,
      ),
    );
    _scheduleDraftSave();
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;
    if (state.status == CompleteProfileStatus.success) return;

    final givenError = _validateGivenName(state.givenName);
    final familyError = _validateFamilyName(state.familyName);

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

    final userId = _currentUserId;

    final result = await _patchMeProfile(
      PatchMeProfileRequestEntity(
        givenName: state.givenName,
        familyName: state.familyName,
      ),
    );

    await result.match(
      (failure) async {
        failure.maybeWhen(
          validation: (errors) {
            emit(
              state.copyWith(
                givenNameError: _firstFieldError(errors, [
                  'givenName',
                  'profile.givenName',
                ]),
                familyNameError: _firstFieldError(errors, [
                  'familyName',
                  'profile.familyName',
                ]),
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
        if (userId != null && userId.isNotEmpty) {
          await _clearDraft(userId: userId);
        }
        emit(state.copyWith(status: CompleteProfileStatus.success));
      },
    );
  }

  ValidationError? _validateGivenName(String input) {
    final result = GivenName.create(input);
    return result.fold(
      (f) => ValidationError(field: 'givenName', message: '', code: f.code),
      (_) => null,
    );
  }

  ValidationError? _validateFamilyName(String input) {
    final result = FamilyName.createOptional(input);
    return result.fold(
      (f) => ValidationError(field: 'familyName', message: '', code: f.code),
      (_) => null,
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

  void _scheduleDraftSave() {
    if (state.status == CompleteProfileStatus.success) return;
    if (state.isSubmitting) return;

    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(_draftSaveDebounce, () {
      if (_currentUserId != userId) return;

      final draft = ProfileDraftEntity(
        givenName: state.givenName,
        familyName: state.familyName.trim().isEmpty ? null : state.familyName,
        displayName: null,
        updatedAt: DateTime.now(),
      );
      unawaited(_saveDraft(userId: userId, draft: draft));
    });
  }

  @override
  Future<void> close() async {
    _draftSaveTimer?.cancel();
    _draftSaveTimer = null;
    await super.close();
  }
}
