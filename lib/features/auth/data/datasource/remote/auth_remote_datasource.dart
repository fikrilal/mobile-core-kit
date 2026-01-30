import 'package:mobile_core_kit/core/foundation/config/api_host.dart';
import 'package:mobile_core_kit/core/foundation/utilities/idempotency_key_utils.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/api/no_data.dart';
import 'package:mobile_core_kit/core/infra/network/endpoints/auth_endpoint.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_response_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/change_password_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/logout_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/password_reset_confirm_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/password_reset_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/refresh_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/verify_email_request_model.dart';

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

  Future<ApiResponse<ApiNoData>> verifyEmail(
    VerifyEmailRequestModel requestModel,
  ) async {
    Log.info('Verifying email', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.verifyEmail,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Verify email failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> resendEmailVerification() async {
    Log.info('Resending verification email', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.resendEmailVerification,
      host: ApiHost.auth,
      requiresAuth: true,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Resend verification email failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> changePassword(
    ChangePasswordRequestModel requestModel, {
    String? idempotencyKey,
  }) async {
    Log.info('Changing password', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.changePassword,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: true,
      throwOnError: false,
      headers: <String, String>{
        'Idempotency-Key': idempotencyKey ?? IdempotencyKeyUtils.generate(),
      },
    );

    if (response.isError) {
      Log.warning(
        'Change password failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> requestPasswordReset(
    PasswordResetRequestModel requestModel,
  ) async {
    Log.info('Requesting password reset', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.passwordResetRequest,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Password reset request failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }

  Future<ApiResponse<ApiNoData>> confirmPasswordReset(
    PasswordResetConfirmRequestModel requestModel,
  ) async {
    final tokenLen = requestModel.token.length;
    Log.info('Confirming password reset (tokenLen=$tokenLen)', name: _tag);

    final response = await _apiHelper.post<ApiNoData>(
      AuthEndpoint.passwordResetConfirm,
      data: requestModel.toJson(),
      host: ApiHost.auth,
      requiresAuth: false,
      throwOnError: false,
    );

    if (response.isError) {
      Log.warning(
        'Password reset confirm failed (status=${response.statusCode}): ${response.message}',
        name: _tag,
      );
    }
    return response;
  }
}
