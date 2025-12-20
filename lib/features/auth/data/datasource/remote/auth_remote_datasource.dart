import '../../../../../core/configs/api_host.dart';
import '../../../../../core/network/api/api_helper.dart';
import '../../../../../core/network/api/api_response.dart';
import '../../../../../core/network/api/no_data.dart';
import '../../../../../core/network/endpoints/auth_endpoint.dart';
import '../../../../../core/utilities/log_utils.dart';
import '../../model/remote/login_request_model.dart';
import '../../model/remote/auth_session_model.dart';
import '../../model/remote/auth_tokens_model.dart';
import '../../model/remote/refresh_request_model.dart';
import '../../model/remote/register_request_model.dart';
import '../../model/remote/google_mobile_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiHelper);
  final String _tag = 'AuthRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<AuthSessionModel>> register(
    RegisterRequestModel requestModel,
  ) async {
    Log.info('Starting user registration', name: _tag);

    final response = await _apiHelper.post<AuthSessionModel>(
      AuthEndpoint.register,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthSessionModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'User registration failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthSessionModel>> login(
    LoginRequestModel requestModel,
  ) async {
    Log.info('Starting user login', name: _tag);

    final response = await _apiHelper.post<AuthSessionModel>(
      AuthEndpoint.passwordLogin,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthSessionModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'User login failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthTokensModel>> refreshToken(
    RefreshRequestModel requestModel,
  ) async {
    Log.info('Refreshing token', name: _tag);

    final response = await _apiHelper.post<AuthTokensModel>(
      AuthEndpoint.refreshToken,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthTokensModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Token refresh failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> logout(
    RefreshRequestModel requestModel,
  ) async {
    Log.info('Logging out user', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.logout,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      throwOnError: false,
      parser: (_) => const ApiNoData(),
    );

    if (response.isError) {
      Log.warning(
        'Logout failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<AuthSessionModel>> googleMobileSignIn(
    GoogleMobileRequestModel requestModel,
  ) async {
    final len = requestModel.idToken.length;
    Log.info('Google mobile sign-in (idToken.length=$len)', name: _tag);

    final response = await _apiHelper.post<AuthSessionModel>(
      AuthEndpoint.googleMobile,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
      parser: AuthSessionModel.fromJson,
    );

    if (response.isError) {
      Log.warning(
        'Google mobile sign-in failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }
}
