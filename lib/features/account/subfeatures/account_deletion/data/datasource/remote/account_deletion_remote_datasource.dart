import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/model/remote/cancel_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/model/remote/request_account_deletion_request_model.dart';

class AccountDeletionRemoteDataSource {
  AccountDeletionRemoteDataSource(this._apiHelper);

  final ApiHelper _apiHelper;

  Future<ApiResponse<ApiNoData>> requestAccountDeletion({
    required RequestAccountDeletionRequestModel request,
  }) {
    return _apiHelper.post<ApiNoData>(
      UserEndpoint.meAccountDeletionRequest,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key':
            request.idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );
  }

  Future<ApiResponse<ApiNoData>> cancelAccountDeletion({
    required CancelAccountDeletionRequestModel request,
  }) {
    return _apiHelper.post<ApiNoData>(
      UserEndpoint.meAccountDeletionCancel,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key':
            request.idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );
  }
}
