import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_request.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/error/profile_image_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_upload_plan_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_url_model.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_upload_plan_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';

class ProfileImageRepositoryImpl implements ProfileImageRepository {
  ProfileImageRepositoryImpl(this._remote, this._upload);

  final ProfileImageRemoteDataSource _remote;
  final PresignedUploadClient _upload;

  @override
  Future<Either<AuthFailure, ProfileImageUploadPlanEntity>> createUploadPlan(
    CreateProfileImageUploadPlanRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.createUploadPlan(
        contentType: request.contentType,
        sizeBytes: request.sizeBytes,
        idempotencyKey: request.idempotencyKey,
      );

      return apiResponse
          .toEitherWithFallback('Failed to create profile image upload plan.')
          .mapLeft(mapProfileImageFailure)
          .map(_uploadPlanToEntity);
    } catch (e, st) {
      Log.error(
        'Create profile image upload plan unexpected error',
        e,
        st,
        true,
        'ProfileImageRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> uploadToPresignedUrl({
    required ProfileImageUploadPlanEntity plan,
    required Uint8List bytes,
  }) async {
    try {
      final request = PresignedUploadRequest(
        method: _parsePresignedMethod(plan.upload.method),
        url: plan.upload.url,
        headers: plan.upload.headers,
      );

      await _upload.uploadBytes(request, bytes: bytes);
      return right(unit);
    } on PresignedUploadFailure catch (e) {
      // Do not log the presigned URL / headers (may contain temporary creds).
      Log.warning(
        'Presigned upload failed (status=${e.statusCode})',
        name: 'ProfileImageRepository',
      );
      return left(mapProfileImageUploadFailure(e));
    } catch (e, st) {
      Log.error(
        'Presigned upload unexpected error',
        e,
        st,
        true,
        'ProfileImageRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> completeUpload(
    CompleteProfileImageUploadRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.completeUpload(fileId: request.fileId);

      return apiResponse
          .toEitherWithFallback('Failed to complete profile image upload.')
          .mapLeft(mapProfileImageFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Complete profile image upload unexpected error',
        e,
        st,
        true,
        'ProfileImageRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> clearProfileImage(
    ClearProfileImageRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.clearProfileImage(
        idempotencyKey: request.idempotencyKey,
      );

      return apiResponse
          .toEitherWithFallback('Failed to clear profile image.')
          .mapLeft(mapProfileImageFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Clear profile image unexpected error',
        e,
        st,
        true,
        'ProfileImageRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, ProfileImageUrlEntity?>>
  getProfileImageUrl() async {
    try {
      final apiResponse = await _remote.getProfileImageUrl();

      if (apiResponse.isError) {
        final failure = ApiFailure(
          message: apiResponse.message ?? 'Unknown error',
          statusCode: apiResponse.statusCode,
          code: apiResponse.code,
          traceId: apiResponse.traceId,
          validationErrors: apiResponse.errors,
        );
        return left(mapProfileImageFailure(failure));
      }

      final model = apiResponse.data;
      if (model == null) return right(null);

      return right(_profileImageUrlToEntity(model));
    } catch (e, st) {
      Log.error(
        'Get profile image URL unexpected error',
        e,
        st,
        true,
        'ProfileImageRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  static PresignedUploadMethod _parsePresignedMethod(String raw) {
    final normalized = raw.trim().toUpperCase();
    return switch (normalized) {
      'PUT' => PresignedUploadMethod.put,
      'POST' => PresignedUploadMethod.post,
      _ => throw ArgumentError.value(raw, 'method', 'Unsupported method'),
    };
  }

  static ProfileImageUploadPlanEntity _uploadPlanToEntity(
    ProfileImageUploadPlanModel model,
  ) {
    return ProfileImageUploadPlanEntity(
      fileId: model.fileId,
      upload: ProfileImagePresignedUploadEntity(
        method: model.upload.method,
        url: model.upload.url,
        headers: model.upload.headers,
      ),
      expiresAt: DateTime.parse(model.expiresAt),
    );
  }

  static ProfileImageUrlEntity _profileImageUrlToEntity(
    ProfileImageUrlModel model,
  ) {
    return ProfileImageUrlEntity(
      url: model.url,
      expiresAt: DateTime.parse(model.expiresAt),
    );
  }
}
