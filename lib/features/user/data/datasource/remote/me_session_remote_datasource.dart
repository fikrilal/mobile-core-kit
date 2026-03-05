import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_paginated_result.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/user_endpoint.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/list_me_sessions_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/me_session_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/revoke_me_session_request_model.dart';

class MeSessionRemoteDataSource {
  MeSessionRemoteDataSource(this._apiHelper);

  final String _tag = 'MeSessionRemoteDataSource';
  final ApiHelper _apiHelper;

  Future<ApiResponse<ApiPaginatedResult<MeSessionModel>>> listSessions({
    required ListMeSessionsRequestModel request,
  }) async {
    Log.info('Fetching current user sessions', name: _tag);

    final response = await _apiHelper.getPaginated<MeSessionModel>(
      UserEndpoint.meSessions,
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
      queryParameters: request.toQueryParameters(),
      itemParser: MeSessionModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Fetching sessions failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }

  Future<ApiResponse<ApiNoData>> revokeSession({
    required RevokeMeSessionRequestModel request,
  }) async {
    Log.info('Revoking session (sessionId=${request.sessionId})', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      UserEndpoint.meSessionRevoke(request.sessionId),
      host: ApiHost.profile,
      requiresAuth: true,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Revoking session failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }

    return response;
  }
}
