import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPatchMeProfileUseCase extends Mock
    implements PatchMeProfileUseCase {}

class _MockGetProfileDraftUseCase extends Mock
    implements GetProfileDraftUseCase {}

class _MockSaveProfileDraftUseCase extends Mock
    implements SaveProfileDraftUseCase {}

class _MockClearProfileDraftUseCase extends Mock
    implements ClearProfileDraftUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PatchMeProfileRequestEntity(givenName: 'x'));
    registerFallbackValue(
      ProfileDraftEntity(givenName: 'x', updatedAt: DateTime(2026)),
    );
    registerFallbackValue(
      const UserEntity(id: 'u1', email: 'user@example.com'),
    );
  });

  group('CompleteProfileCubit', () {
    late _MockGetProfileDraftUseCase getDraft;
    late _MockSaveProfileDraftUseCase saveDraft;
    late _MockClearProfileDraftUseCase clearDraft;
    late _MockPatchMeProfileUseCase patchMeProfile;
    late _MockSessionManager sessionManager;

    setUp(() {
      getDraft = _MockGetProfileDraftUseCase();
      saveDraft = _MockSaveProfileDraftUseCase();
      clearDraft = _MockClearProfileDraftUseCase();
      patchMeProfile = _MockPatchMeProfileUseCase();
      sessionManager = _MockSessionManager();

      when(() => sessionManager.sessionNotifier).thenReturn(
        ValueNotifier<AuthSessionEntity?>(
          const AuthSessionEntity(
            tokens: AuthTokensEntity(
              accessToken: 'at',
              refreshToken: 'rt',
              tokenType: 'Bearer',
              expiresIn: 3600,
            ),
            user: UserEntity(id: 'u1', email: 'user@example.com'),
          ),
        ),
      );
      when(
        () => getDraft(userId: any(named: 'userId')),
      ).thenAnswer((_) async => null);
      when(
        () => saveDraft(
          userId: any(named: 'userId'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => clearDraft(userId: any(named: 'userId')),
      ).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = CompleteProfileCubit(
        getDraft,
        saveDraft,
        clearDraft,
        patchMeProfile,
        sessionManager,
      );
      final emitted = <CompleteProfileState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 1);
      expect(emitted.single.status, CompleteProfileStatus.initial);
      expect(emitted.single.failure, isNull);
      expect(
        emitted.single.givenNameError?.code,
        ValidationErrorCodes.required,
      );
      expect(emitted.single.familyNameError, isNull);

      verifyNever(() => patchMeProfile(any()));

      await sub.cancel();
      await cubit.close();
    });

    test('submits and emits submitting -> success', () async {
      const user = UserEntity(id: 'u1', email: 'user@example.com');
      when(() => patchMeProfile(any())).thenAnswer((_) async => right(user));

      final cubit = CompleteProfileCubit(
        getDraft,
        saveDraft,
        clearDraft,
        patchMeProfile,
        sessionManager,
      );
      final emitted = <CompleteProfileState>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit.givenNameChanged('John');
      cubit.familyNameChanged('Doe');
      await cubit.submit();
      await pumpEventQueue();

      expect(emitted.length, 4);
      expect(emitted[2].status, CompleteProfileStatus.submitting);
      expect(emitted[3].status, CompleteProfileStatus.success);

      final captured = verify(() => patchMeProfile(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured.single as PatchMeProfileRequestEntity;
      expect(request.givenName, 'John');
      expect(request.familyName, 'Doe');

      verify(() => sessionManager.setUser(user)).called(1);

      await sub.cancel();
      await cubit.close();
    });
  });
}
