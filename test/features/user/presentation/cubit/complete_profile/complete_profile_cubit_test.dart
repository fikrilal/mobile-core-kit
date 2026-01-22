import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/validation/validation_error_codes.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockPatchMeProfileUseCase extends Mock
    implements PatchMeProfileUseCase {}

class _MockSessionManager extends Mock implements SessionManager {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PatchMeProfileRequestEntity(givenName: 'x'));
    registerFallbackValue(
      const UserEntity(id: 'u1', email: 'user@example.com'),
    );
  });

  group('CompleteProfileCubit', () {
    late _MockPatchMeProfileUseCase patchMeProfile;
    late _MockSessionManager sessionManager;

    setUp(() {
      patchMeProfile = _MockPatchMeProfileUseCase();
      sessionManager = _MockSessionManager();

      when(() => sessionManager.setUser(any())).thenAnswer((_) async {});
    });

    test('emits field errors and does not call usecase when invalid', () async {
      final cubit = CompleteProfileCubit(patchMeProfile, sessionManager);
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

      final cubit = CompleteProfileCubit(patchMeProfile, sessionManager);
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
