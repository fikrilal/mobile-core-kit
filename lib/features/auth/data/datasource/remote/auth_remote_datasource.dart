import '../../../../../core/configs/api_host.dart';
import '../../../../../core/network/api/api_helper.dart';
import '../../../../../core/network/api/api_response.dart';
import '../../../../../core/network/api/no_data.dart';
import '../../../../../core/network/endpoints/auth_endpoint.dart';
import '../../../../../core/utilities/log_utils.dart';
import '../../model/remote/login_request_model.dart';
import '../../model/remote/refresh_request_model.dart';
import '../../model/remote/refresh_response_model.dart';
import '../../model/remote/register_request_model.dart';
import '../../model/remote/google_mobile_request_model.dart';
import '../../model/remote/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiHelper);
  final String _tag = 'AuthRemoteDataSource';

  final ApiHelper _apiHelper;

  Future<ApiResponse<UserModel>> register(
    RegisterRequestModel requestModel,
  ) async {
    Log.info('Starting user registration', name: _tag);

    final response = await _apiHelper.post<UserModel>(
      AuthEndpoint.register,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      parser: UserModel.fromJson,
    );

    Log.info('User registration successful', name: _tag);
    return response;
  }

  Future<ApiResponse<UserModel>> login(LoginRequestModel requestModel) async {
    Log.info('Starting user login', name: _tag);

    final response = await _apiHelper.post<UserModel>(
      AuthEndpoint.login,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      parser: UserModel.fromJson,
    );

    Log.info('User login successful', name: _tag);
    return response;
  }

  Future<ApiResponse<RefreshResponseModel>> refreshToken(
    RefreshRequestModel requestModel,
  ) async {
    Log.info('Refreshing token', name: _tag);

    final response = await _apiHelper.post<RefreshResponseModel>(
      AuthEndpoint.refreshToken,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      parser: RefreshResponseModel.fromJson,
    );

    Log.info('Token refreshed successfully', name: _tag);
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
    );

    Log.info('Logout request completed', name: _tag);
    return response;
  }

  Future<ApiResponse<UserModel>> googleMobileSignIn(
    GoogleMobileRequestModel requestModel,
  ) async {
    final len = requestModel.idToken.length;
    Log.info('Google mobile sign-in (idToken.length=$len)', name: _tag);

    final response = await _apiHelper.post<UserModel>(
      AuthEndpoint.googleMobile,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      parser: UserModel.fromJson,
    );

    Log.info('Google mobile sign-in successful', name: _tag);
    return response;
  }
}
