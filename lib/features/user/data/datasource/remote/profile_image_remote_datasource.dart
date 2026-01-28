import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/api/no_data.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/complete_profile_image_upload_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/create_profile_image_upload_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_upload_plan_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/profile_image_url_model.dart';

class ProfileImageRemoteDataSource {
  ProfileImageRemoteDataSource(this._apiHelper);

  final String _tag = 'ProfileImageRemoteDataSource';
  final ApiHelper _apiHelper;

  Future<ApiResponse<ProfileImageUploadPlanModel>> createUploadPlan({
    required String contentType,
    required int sizeBytes,
    String? idempotencyKey,
  }) async {
    Log.info(
      'Creating profile image upload plan (contentType=$contentType, sizeBytes=$sizeBytes)',
      name: _tag,
    );

    final response = await _apiHelper.post<ProfileImageUploadPlanModel>(
      UserEndpoint.meProfileImageUpload,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
      data: CreateProfileImageUploadRequestModel(
        contentType: contentType,
        sizeBytes: sizeBytes,
      ).toJson(),
      parser: ProfileImageUploadPlanModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Creating profile image upload plan failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  /// Completes an upload and attaches it to the current user profile.
  ///
  /// Note:
  /// - The backend contract does not define idempotency keys for this endpoint.
  /// - Auth-refresh retry is disabled by default (writes require idempotency).
  Future<ApiResponse<ApiNoData>> completeUpload({
    required String fileId,
  }) async {
    Log.info('Completing profile image upload (fileId=$fileId)', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      UserEndpoint.meProfileImageComplete,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      data: CompleteProfileImageUploadRequestModel(fileId: fileId).toJson(),
    );

    if (response.isError) {
      Log.warning(
        'Completing profile image upload failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  Future<ApiResponse<ApiNoData>> clearProfileImage({
    String? idempotencyKey,
  }) async {
    Log.info('Clearing profile image', name: _tag);

    final response = await _apiHelper.delete<ApiNoData>(
      UserEndpoint.meProfileImage,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );

    if (response.isError) {
      Log.warning(
        'Clearing profile image failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  /// Returns a short-lived render URL for the current profile image.
  ///
  /// Backend behavior:
  /// - `200` returns `{ data: { url, expiresAt } }`
  /// - `204` indicates no profile image is set (this is NOT an error)
  Future<ApiResponse<ProfileImageUrlModel?>> getProfileImageUrl() async {
    Log.info('Fetching profile image URL', name: _tag);

    final response = await _apiHelper.getOne<ProfileImageUrlModel?>(
      UserEndpoint.meProfileImageUrl,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      parser: ProfileImageUrlModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Fetching profile image URL failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }
}
