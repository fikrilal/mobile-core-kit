import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/api/no_data.dart';
import 'package:mobile_core_kit/core/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/services/push/push_platform.dart';
import 'package:mobile_core_kit/core/services/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/me_push_token_upsert_request_model.dart';

class MePushTokenRemoteDataSource implements PushTokenRegistrar {
  MePushTokenRemoteDataSource(this._apiHelper);

  final String _tag = 'MePushTokenRemoteDataSource';
  final ApiHelper _apiHelper;

  @override
  Future<ApiResponse<ApiNoData>> upsert({
    required PushPlatform platform,
    required String token,
  }) async {
    final tokenLen = token.length;
    Log.info(
      'Upserting push token (platform=${platform.apiValue}, len=$tokenLen)',
      name: _tag,
    );

    final response = await _apiHelper.put<ApiNoData>(
      UserEndpoint.mePushToken,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': IdempotencyKeyUtils.generate(),
      },
      data: MePushTokenUpsertRequestModel(
        platform: platform.apiValue,
        token: token,
      ).toJson(),
    );

    if (response.isError) {
      Log.warning(
        'Upserting push token failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  @override
  Future<ApiResponse<ApiNoData>> revoke() async {
    Log.info('Revoking push token', name: _tag);

    final response = await _apiHelper.delete<ApiNoData>(
      UserEndpoint.mePushToken,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': IdempotencyKeyUtils.generate(),
      },
    );

    if (response.isError) {
      Log.warning(
        'Revoking push token failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }
}
