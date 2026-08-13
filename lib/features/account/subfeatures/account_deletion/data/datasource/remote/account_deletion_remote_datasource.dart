import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';

class AccountDeletionRemoteDataSource {
  AccountDeletionRemoteDataSource(this._apiHelper);

  final ApiHelper _apiHelper;

  Future<ApiResponse<ApiNoData>> requestDeletion(AccountDeletionAction action) {
    final endpoint = switch (action) {
      AccountDeletionAction.request => UserEndpoint.meAccountDeletionRequest,
      AccountDeletionAction.cancel => UserEndpoint.meAccountDeletionCancel,
    };

    return _apiHelper.post<ApiNoData>(
      endpoint,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': IdempotencyKeyUtils.generate(),
      },
    );
  }
}
