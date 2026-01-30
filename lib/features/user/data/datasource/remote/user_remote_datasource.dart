import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/user/model/remote/me_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/patch_me_request_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._apiHelper);
  final String _tag = 'UserRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<MeModel>> getMe() async {
    Log.info('Fetching current user', name: _tag);

    final response = await _apiHelper.getOne<MeModel>(
      UserEndpoint.me,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      parser: MeModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Fetching current user failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<MeModel>> patchMe({
    required PatchMeRequestModel request,
    String? idempotencyKey,
  }) async {
    Log.info('Patching current user profile', name: _tag);

    final response = await _apiHelper.patch<MeModel>(
      UserEndpoint.me,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
      data: request.toJson(),
      parser: MeModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Patching current user failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }
}
