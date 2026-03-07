import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/infra/network/model/remote/me_model.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiHelper);

  final String _tag = 'ProfileRemoteDataSource';
  final ApiHelper _apiHelper;

  Future<ApiResponse<MeModel>> patchMeProfile({
    required PatchMeRequestModel request,
    String? idempotencyKey,
  }) async {
    Log.info('Patching current user profile', name: _tag);

    return _apiHelper.patch<MeModel>(
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
  }
}
