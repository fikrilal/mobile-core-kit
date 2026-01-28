import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/upload_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_image_url_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_state.dart';

class ProfileImageCubit extends Cubit<ProfileImageState> {
  ProfileImageCubit(
    this._uploadProfileImage,
    this._clearProfileImage,
    this._getProfileImageUrl,
  ) : super(ProfileImageState.initial());

  final UploadProfileImageUseCase _uploadProfileImage;
  final ClearProfileImageUseCase _clearProfileImage;
  final GetProfileImageUrlUseCase _getProfileImageUrl;

  Future<void> upload({
    required Uint8List bytes,
    required String contentType,
    String? idempotencyKey,
  }) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.upload,
        failure: null,
      ),
    );

    final result = await _uploadProfileImage(
      UploadProfileImageRequestEntity(
        bytes: bytes,
        contentType: contentType,
        idempotencyKey: idempotencyKey,
      ),
    );

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileImageStatus.failure,
          action: ProfileImageAction.upload,
          failure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ProfileImageStatus.success,
          action: ProfileImageAction.upload,
          failure: null,
        ),
      ),
    );
  }

  Future<void> clear({String? idempotencyKey}) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.clear,
        failure: null,
      ),
    );

    final result = await _clearProfileImage(
      ClearProfileImageRequestEntity(idempotencyKey: idempotencyKey),
    );

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileImageStatus.failure,
          action: ProfileImageAction.clear,
          failure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: ProfileImageStatus.success,
          action: ProfileImageAction.clear,
          failure: null,
        ),
      ),
    );
  }

  Future<void> loadUrl() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.loading,
        action: ProfileImageAction.loadUrl,
        failure: null,
      ),
    );

    final result = await _getProfileImageUrl();

    result.match(
      (failure) => emit(
        state.copyWith(
          status: ProfileImageStatus.failure,
          action: ProfileImageAction.loadUrl,
          failure: failure,
        ),
      ),
      (url) => emit(
        state.copyWith(
          status: ProfileImageStatus.initial,
          action: ProfileImageAction.none,
          imageUrl: url?.url,
          failure: null,
        ),
      ),
    );
  }

  void resetStatus() {
    if (state.status == ProfileImageStatus.initial) return;

    emit(
      state.copyWith(
        status: ProfileImageStatus.initial,
        action: ProfileImageAction.none,
        failure: null,
      ),
    );
  }
}
