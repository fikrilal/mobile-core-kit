import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_draft_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPatchMeProfileUseCase extends Mock
    implements PatchMeProfileUseCase {}

class _MockProfileDraftRepository extends Mock
    implements ProfileDraftRepository {}

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
    late _MockProfileDraftRepository draftRepository;
    late _MockPatchMeProfileUseCase patchMeProfile;
    late _MockSessionManager sessionManager;

    setUp(() {
      draftRepository = _MockProfileDraftRepository();
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
        () => draftRepository.getDraft(userId: any(named: 'userId')),
      ).thenAnswer((_) async => null);
      when(
        () => draftRepository.saveDraft(
          userId: any(named: 'userId'),
          draft: any(named: 'draft'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => draftRepository.clearDraft(userId: any(named: 'userId')),
      ).thenAnswer((_) async {});
      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = CompleteProfileCubit(
        draftRepository,
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
        draftRepository,
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

    test('loadDraft populates fields when draft exists', () async {
      final now = DateTime(2026, 1, 1);
      when(
        () => draftRepository.getDraft(userId: any(named: 'userId')),
      ).thenAnswer(
        (_) async => ProfileDraftEntity(
          givenName: 'John',
          familyName: 'Doe',
          displayName: null,
          updatedAt: now,
        ),
      );

      final cubit = CompleteProfileCubit(
        draftRepository,
        patchMeProfile,
        sessionManager,
      );

      await cubit.loadDraft();

      expect(cubit.state.givenName, 'John');
      expect(cubit.state.familyName, 'Doe');
      expect(cubit.state.givenNameError, isNull);
      expect(cubit.state.familyNameError, isNull);
      verify(() => draftRepository.getDraft(userId: 'u1')).called(1);

      await cubit.close();
    });

    test('emits failure effect for submit failure', () async {
      when(
        () => patchMeProfile(any()),
      ).thenAnswer((_) async => left(const AuthFailure.serverError()));

      final cubit = CompleteProfileCubit(
        draftRepository,
        patchMeProfile,
        sessionManager,
      );
      final effects = <CompleteProfileEffect>[];
      final effectSub = cubit.effects.listen(effects.add);

      cubit.givenNameChanged('John');
      await cubit.submit();
      await pumpEventQueue();

      expect(cubit.state.status, CompleteProfileStatus.failure);
      expect(cubit.state.failure, const AuthFailure.serverError());
      expect(effects, hasLength(1));
      expect(effects.single, isA<CompleteProfileFailureEffect>());

      await effectSub.cancel();
      await cubit.close();
    });
  });
}
