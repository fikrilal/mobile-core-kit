import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_avatar_cache_entry_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/input/profile_image_upload_input.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_avatar_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserContextService extends Mock implements UserContextService {}

class _MockUploadProfileImageUseCase extends Mock
    implements UploadProfileImageUseCase {}

class _MockClearProfileImageUseCase extends Mock
    implements ClearProfileImageUseCase {}

class _MockProfileAvatarRepository extends Mock
    implements ProfileAvatarRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ProfileImageUploadInput(bytes: Uint8List(0), contentType: 'image/png'),
    );
    registerFallbackValue(const ClearProfileImageRequestEntity());
  });

  late _MockUploadProfileImageUseCase uploadProfileImage;
  late _MockClearProfileImageUseCase clearProfileImage;
  late _MockUserContextService userContext;
  late _MockProfileAvatarRepository avatarRepository;
  late List<ProfileImageEffect> effects;
  late StreamSubscription<ProfileImageEffect> effectSubscription;

  setUp(() {
    uploadProfileImage = _MockUploadProfileImageUseCase();
    clearProfileImage = _MockClearProfileImageUseCase();
    userContext = _MockUserContextService();
    avatarRepository = _MockProfileAvatarRepository();
    effects = [];
  });

  const user = UserEntity(id: 'user-1', email: 'user@example.com');

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then initial and updated effect when upload succeeds',
    build: () {
      when(
        () => uploadProfileImage(any()),
      ).thenAnswer((_) async => right(user));
      final cubit = ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.upload(
      bytes: Uint8List.fromList([1, 2, 3]),
      contentType: 'image/png',
    ),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.upload,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowProfileImageUpdated>()]);
      await effectSubscription.cancel();
    },
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then initial and failure effect when upload fails',
    build: () {
      when(
        () => uploadProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      final cubit = ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.upload(
      bytes: Uint8List.fromList([1, 2, 3]),
      contentType: 'image/png',
    ),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.upload,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowProfileImageFailure>()]);
      expect(
        (effects.single as ShowProfileImageFailure).failure,
        const AuthFailure.network(),
      );
      await effectSubscription.cancel();
    },
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then initial and removed effect when clear succeeds',
    build: () {
      when(() => clearProfileImage(any())).thenAnswer((_) async => right(user));
      final cubit = ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.clear(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowProfileImageRemoved>()]);
      await effectSubscription.cancel();
    },
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then initial and failure effect when clear fails',
    build: () {
      when(
        () => clearProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.serverError()));
      final cubit = ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
      effectSubscription = cubit.effects.listen(effects.add);
      return cubit;
    },
    act: (cubit) async => cubit.clear(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
      ),
    ],
    verify: (_) async {
      await Future<void>.delayed(Duration.zero);
      expect(effects, [isA<ShowProfileImageFailure>()]);
      expect(
        (effects.single as ShowProfileImageFailure).failure,
        const AuthFailure.serverError(),
      );
      await effectSubscription.cancel();
    },
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then initial (with cached path) when loadAvatar hits cache',
    build: () {
      when(() => userContext.user).thenReturn(
        user.copyWith(
          profile: const UserProfileEntity(profileImageFileId: 'file-1'),
        ),
      );
      when(
        () => avatarRepository.getCachedAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      ).thenAnswer(
        (_) async => right(
          ProfileAvatarCacheEntryEntity(
            filePath: '/tmp/avatar.bin',
            cachedAt: DateTime(2026, 1, 1),
            isExpired: false,
          ),
        ),
      );
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
    },
    act: (cubit) async => cubit.loadAvatar(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadAvatar,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        cachedFilePath: '/tmp/avatar.bin',
      ),
    ],
    verify: (_) {
      verifyNever(
        () => avatarRepository.refreshAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      );
    },
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'expired cache emits cached path then refreshes in background',
    build: () {
      when(() => userContext.user).thenReturn(
        user.copyWith(
          profile: const UserProfileEntity(profileImageFileId: 'file-1'),
        ),
      );
      when(
        () => avatarRepository.getCachedAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      ).thenAnswer(
        (_) async => right(
          ProfileAvatarCacheEntryEntity(
            filePath: '/tmp/avatar_stale.bin',
            cachedAt: DateTime(2026, 1, 1),
            isExpired: true,
          ),
        ),
      );
      when(
        () => avatarRepository.refreshAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      ).thenAnswer(
        (_) async => right(
          ProfileAvatarCacheEntryEntity(
            filePath: '/tmp/avatar_fresh.bin',
            cachedAt: DateTime(2026, 1, 2),
            isExpired: false,
          ),
        ),
      );
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
    },
    act: (cubit) async => cubit.loadAvatar(),
    wait: const Duration(milliseconds: 10),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadAvatar,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        cachedFilePath: '/tmp/avatar_stale.bin',
      ),
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadAvatar,
        cachedFilePath: '/tmp/avatar_stale.bin',
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        cachedFilePath: '/tmp/avatar_fresh.bin',
      ),
    ],
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'cache miss refreshes and emits cached path',
    build: () {
      when(() => userContext.user).thenReturn(
        user.copyWith(
          profile: const UserProfileEntity(profileImageFileId: 'file-1'),
        ),
      );
      when(
        () => avatarRepository.getCachedAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      ).thenAnswer((_) async => right(null));
      when(
        () => avatarRepository.refreshAvatar(
          userId: any(named: 'userId'),
          profileImageFileId: any(named: 'profileImageFileId'),
        ),
      ).thenAnswer(
        (_) async => right(
          ProfileAvatarCacheEntryEntity(
            filePath: '/tmp/avatar.bin',
            cachedAt: DateTime(2026, 1, 1),
            isExpired: false,
          ),
        ),
      );
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        avatarRepository,
      );
    },
    act: (cubit) async => cubit.loadAvatar(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadAvatar,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        cachedFilePath: '/tmp/avatar.bin',
      ),
    ],
  );

  test('closes effects stream on close', () async {
    final cubit = ProfileImageCubit(
      userContext,
      uploadProfileImage,
      clearProfileImage,
      avatarRepository,
    );
    final done = expectLater(cubit.effects, emitsDone);

    await cubit.close();

    await done;
  });
}
