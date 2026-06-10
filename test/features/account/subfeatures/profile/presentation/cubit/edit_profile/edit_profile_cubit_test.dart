import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPatchMeProfileUseCase extends Mock
    implements PatchMeProfileUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

void main() {
  test('loadCurrentProfile pre-fills the authenticated user profile', () async {
    final patchMeProfile = _MockPatchMeProfileUseCase();
    final sessionManager = _MockSessionManager();
    when(() => sessionManager.sessionNotifier).thenReturn(
      ValueNotifier<AuthSessionEntity?>(
        const AuthSessionEntity(
          tokens: AuthTokensEntity(
            accessToken: 'at',
            refreshToken: 'rt',
            tokenType: 'Bearer',
            expiresIn: 3600,
          ),
          user: UserEntity(
            id: 'u1',
            email: 'user@example.com',
            profile: UserProfileEntity(
              givenName: 'Maestro',
              familyName: 'Fixture',
            ),
          ),
        ),
      ),
    );
    final cubit = EditProfileCubit(patchMeProfile, sessionManager);

    cubit.loadCurrentProfile();

    expect(cubit.state.givenName, 'Maestro');
    expect(cubit.state.familyName, 'Fixture');
    expect(cubit.state.canSubmit, isTrue);

    await cubit.close();
  });
}
