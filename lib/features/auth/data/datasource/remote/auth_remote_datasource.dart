import 'package:mobile_core_kit/core/configs/api_host.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/network/api/api_response.dart';
import 'package:mobile_core_kit/core/network/api/no_data.dart';
import 'package:mobile_core_kit/core/network/endpoints/auth_endpoint.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/logout_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/refresh_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiHelper);
  final String _tag = 'AuthRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<AuthResponseModel>> register(
    RegisterRequestModel requestModel,
  ) async {
    Log.info('Starting user registration', name: _tag);

    final response = await _apiHelper.post<AuthResponseModel>(
      AuthEndpoint.register,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthResponseModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'User registration failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthResponseModel>> login(
    LoginRequestModel requestModel,
  ) async {
    Log.info('Starting user login', name: _tag);

    final response = await _apiHelper.post<AuthResponseModel>(
      AuthEndpoint.login,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthResponseModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'User login failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthResultModel>> refreshToken(
    RefreshRequestModel requestModel,
  ) async {
    Log.info('Refreshing token', name: _tag);

    final response = await _apiHelper.post<AuthResultModel>(
      AuthEndpoint.refreshToken,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthResultModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Token refresh failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> logout(LogoutRequestModel requestModel) async {
    Log.info('Logging out (remote)', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.logout,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Remote logout failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthResponseModel>> oidcExchange(
    OidcExchangeRequestModel requestModel,
  ) async {
    final len = requestModel.idToken.length;
    Log.info(
      'OIDC exchange (provider=${requestModel.provider}, len=$len)',
      name: _tag,
    );

    final response = await _apiHelper.post<AuthResponseModel>(
      AuthEndpoint.oidcExchange,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthResponseModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'OIDC exchange failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }
}
