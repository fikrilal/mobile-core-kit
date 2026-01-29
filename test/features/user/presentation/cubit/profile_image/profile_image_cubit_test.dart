import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/services/user_context/user_context_service.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_avatar_cache_entry_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_cached_profile_avatar_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/refresh_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserContextService extends Mock implements UserContextService {}

class _MockUploadProfileImageUseCase extends Mock
    implements UploadProfileImageUseCase {}

class _MockClearProfileImageUseCase extends Mock
    implements ClearProfileImageUseCase {}

class _MockGetCachedProfileAvatarUseCase extends Mock
    implements GetCachedProfileAvatarUseCase {}

class _MockRefreshProfileAvatarCacheUseCase extends Mock
    implements RefreshProfileAvatarCacheUseCase {}

class _MockSaveProfileAvatarCacheUseCase extends Mock
    implements SaveProfileAvatarCacheUseCase {}

class _MockClearProfileAvatarCacheUseCase extends Mock
    implements ClearProfileAvatarCacheUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      UploadProfileImageRequestEntity(
        bytes: Uint8List(0),
        contentType: 'image/png',
      ),
    );
    registerFallbackValue(const ClearProfileImageRequestEntity());
  });

  late _MockUploadProfileImageUseCase uploadProfileImage;
  late _MockClearProfileImageUseCase clearProfileImage;
  late _MockUserContextService userContext;
  late _MockGetCachedProfileAvatarUseCase getCachedProfileAvatar;
  late _MockRefreshProfileAvatarCacheUseCase refreshProfileAvatarCache;
  late _MockSaveProfileAvatarCacheUseCase saveProfileAvatarCache;
  late _MockClearProfileAvatarCacheUseCase clearProfileAvatarCache;

  setUp(() {
    uploadProfileImage = _MockUploadProfileImageUseCase();
    clearProfileImage = _MockClearProfileImageUseCase();
    userContext = _MockUserContextService();
    getCachedProfileAvatar = _MockGetCachedProfileAvatarUseCase();
    refreshProfileAvatarCache = _MockRefreshProfileAvatarCacheUseCase();
    saveProfileAvatarCache = _MockSaveProfileAvatarCacheUseCase();
    clearProfileAvatarCache = _MockClearProfileAvatarCacheUseCase();
  });

  const user = UserEntity(id: 'user-1', email: 'user@example.com');

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then success when upload succeeds',
    build: () {
      when(
        () => uploadProfileImage(any()),
      ).thenAnswer((_) async => right(user));
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        getCachedProfileAvatar,
        refreshProfileAvatarCache,
        saveProfileAvatarCache,
        clearProfileAvatarCache,
      );
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
        status: ProfileImageStatus.success,
        action: ProfileImageAction.upload,
      ),
    ],
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then failure when upload fails',
    build: () {
      when(
        () => uploadProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.network()));
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        getCachedProfileAvatar,
        refreshProfileAvatarCache,
        saveProfileAvatarCache,
        clearProfileAvatarCache,
      );
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
        status: ProfileImageStatus.failure,
        action: ProfileImageAction.upload,
        failure: AuthFailure.network(),
      ),
    ],
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then success when clear succeeds',
    build: () {
      when(() => clearProfileImage(any())).thenAnswer((_) async => right(user));
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        getCachedProfileAvatar,
        refreshProfileAvatarCache,
        saveProfileAvatarCache,
        clearProfileAvatarCache,
      );
    },
    act: (cubit) async => cubit.clear(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
      ),
      ProfileImageState(
        status: ProfileImageStatus.success,
        action: ProfileImageAction.clear,
      ),
    ],
  );

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then failure when clear fails',
    build: () {
      when(
        () => clearProfileImage(any()),
      ).thenAnswer((_) async => left(const AuthFailure.serverError()));
      return ProfileImageCubit(
        userContext,
        uploadProfileImage,
        clearProfileImage,
        getCachedProfileAvatar,
        refreshProfileAvatarCache,
        saveProfileAvatarCache,
        clearProfileAvatarCache,
      );
    },
    act: (cubit) async => cubit.clear(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
      ),
      ProfileImageState(
        status: ProfileImageStatus.failure,
        action: ProfileImageAction.clear,
        failure: AuthFailure.serverError(),
      ),
    ],
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
        () => getCachedProfileAvatar(
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
        getCachedProfileAvatar,
        refreshProfileAvatarCache,
        saveProfileAvatarCache,
        clearProfileAvatarCache,
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
}
