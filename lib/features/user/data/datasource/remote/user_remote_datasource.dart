import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/core/infra/network/model/remote/me_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/cancel_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/request_account_deletion_request_model.dart';

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

  Future<ApiResponse<ApiNoData>> requestAccountDeletion({
    required RequestAccountDeletionRequestModel request,
  }) async {
    Log.info('Requesting account deletion', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      UserEndpoint.meAccountDeletionRequest,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key':
            request.idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );

    if (response.isError) {
      Log.warning(
        'Requesting account deletion failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  Future<ApiResponse<ApiNoData>> cancelAccountDeletion({
    required CancelAccountDeletionRequestModel request,
  }) async {
    Log.info('Canceling account deletion', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      UserEndpoint.meAccountDeletionCancel,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key':
            request.idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );

    if (response.isError) {
      Log.warning(
        'Canceling account deletion failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }
}
