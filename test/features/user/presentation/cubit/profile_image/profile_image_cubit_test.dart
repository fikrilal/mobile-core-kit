import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_image_url_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockUploadProfileImageUseCase extends Mock
    implements UploadProfileImageUseCase {}

class _MockClearProfileImageUseCase extends Mock
    implements ClearProfileImageUseCase {}

class _MockGetProfileImageUrlUseCase extends Mock
    implements GetProfileImageUrlUseCase {}

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
  late _MockGetProfileImageUrlUseCase getProfileImageUrl;

  setUp(() {
    uploadProfileImage = _MockUploadProfileImageUseCase();
    clearProfileImage = _MockClearProfileImageUseCase();
    getProfileImageUrl = _MockGetProfileImageUrlUseCase();
  });

  const user = UserEntity(id: 'user-1', email: 'user@example.com');

  blocTest<ProfileImageCubit, ProfileImageState>(
    'emits loading then success when upload succeeds',
    build: () {
      when(
        () => uploadProfileImage(any()),
      ).thenAnswer((_) async => right(user));
      return ProfileImageCubit(
        uploadProfileImage,
        clearProfileImage,
        getProfileImageUrl,
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
        uploadProfileImage,
        clearProfileImage,
        getProfileImageUrl,
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
        uploadProfileImage,
        clearProfileImage,
        getProfileImageUrl,
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
        uploadProfileImage,
        clearProfileImage,
        getProfileImageUrl,
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
    'emits loading then initial (with url) when loadUrl succeeds',
    build: () {
      when(() => getProfileImageUrl()).thenAnswer(
        (_) async => right(
          ProfileImageUrlEntity(
            url: 'https://example.com/image.jpg',
            expiresAt: DateTime(2030, 1, 1),
          ),
        ),
      );
      return ProfileImageCubit(
        uploadProfileImage,
        clearProfileImage,
        getProfileImageUrl,
      );
    },
    act: (cubit) async => cubit.loadUrl(),
    expect: () => const [
      ProfileImageState(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadUrl,
      ),
      ProfileImageState(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        imageUrl: 'https://example.com/image.jpg',
      ),
    ],
  );
}
