import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_cubit.dart';

class EditProfileCubit extends ProfileFormCubit {
  EditProfileCubit(
    PatchMeProfileUseCase patchMeProfile,
    SessionManager sessionManager,
  ) : super(patchMeProfile, sessionManager);

  void loadCurrentProfile() {
    final profile = currentProfile;
    if (profile == null) return;

    setInitialValues(
      givenName: profile.givenName ?? '',
      familyName: profile.familyName ?? '',
    );
  }
}
