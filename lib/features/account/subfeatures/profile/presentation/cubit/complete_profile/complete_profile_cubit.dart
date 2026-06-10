import 'dart:async';

import 'package:mobile_core_kit/core/design_system/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_state.dart';

class CompleteProfileCubit extends ProfileFormCubit {
  CompleteProfileCubit(
    this._getDraft,
    this._saveDraft,
    this._clearDraft,
    PatchMeProfileUseCase patchMeProfile,
    SessionManager sessionManager,
  ) : super(patchMeProfile, sessionManager);

  final GetProfileDraftUseCase _getDraft;
  final SaveProfileDraftUseCase _saveDraft;
  final ClearProfileDraftUseCase _clearDraft;

  Timer? _draftSaveTimer;
  static const Duration _draftSaveDebounce = MotionDurations.long;

  Future<void> loadDraft() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return;

    final draft = await _getDraft(userId: userId);
    if (currentUserId != userId || draft == null) return;

    final givenName = state.givenName.trim().isEmpty
        ? draft.givenName
        : state.givenName;
    final familyName = state.familyName.trim().isEmpty
        ? (draft.familyName ?? '')
        : state.familyName;
    setInitialValues(givenName: givenName, familyName: familyName);
  }

  @override
  void onFieldChanged() {
    if (state.status == ProfileFormStatus.success || state.isSubmitting) return;

    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return;

    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(_draftSaveDebounce, () {
      if (currentUserId != userId) return;

      unawaited(
        _saveDraft(
          userId: userId,
          draft: ProfileDraftEntity(
            givenName: state.givenName,
            familyName: state.familyName.trim().isEmpty
                ? null
                : state.familyName,
            displayName: null,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    });
  }

  @override
  Future<void> onSubmitSuccess(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      await _clearDraft(userId: userId);
    }
  }

  @override
  Future<void> close() async {
    _draftSaveTimer?.cancel();
    _draftSaveTimer = null;
    await super.close();
  }
}
