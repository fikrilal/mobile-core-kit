import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_failure_mapper.dart';
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
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_confirm_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/verify_email_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final GoogleFederatedAuthService _googleAuth;

  final DeviceIdentityService _deviceIdentity;

  AuthRepositoryImpl(this._remote, this._googleAuth, this._deviceIdentity);

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> register(
    RegisterRequestEntity request,
  ) async {
    final device = await _deviceIdentity.get();
    final apiRequest = RegisterRequestModel.fromEntity(
      request,
    ).copyWith(deviceId: device.id, deviceName: device.name);

    try {
      final apiResponse = await _remote.register(apiRequest);
      return apiResponse
          .toEitherWithFallback('Register failed.')
          .mapLeft(mapAuthFailure)
          .map((m) => m.toSessionEntity());
    } catch (e, st) {
      Log.error(
        'Register user unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> login(
    LoginRequestEntity request,
  ) async {
    final device = await _deviceIdentity.get();
    final apiRequest = LoginRequestModel.fromEntity(
      request,
    ).copyWith(deviceId: device.id, deviceName: device.name);

    try {
      final apiResponse = await _remote.login(apiRequest);
      return apiResponse
          .toEitherWithFallback('Login failed.')
          .mapLeft(mapAuthFailure)
          .map((m) => m.toSessionEntity());
    } catch (e, st) {
      Log.error('Login user unexpected error', e, st, true, 'AuthRepository');
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, AuthTokensEntity>> refreshToken(
    RefreshRequestEntity request,
  ) async {
    final apiRequest = RefreshRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.refreshToken(apiRequest);
      return apiResponse
          .toEitherWithFallback('Token refresh failed.')
          .mapLeft(mapAuthFailureForRefresh)
          .map((m) => m.toTokensEntity());
    } catch (e, st) {
      Log.error(
        'Refresh token unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> logout(LogoutRequestEntity request) async {
    final apiRequest = LogoutRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.logout(apiRequest);
      return apiResponse
          .toEitherWithFallback('Logout failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error('Logout unexpected error', e, st, true, 'AuthRepository');
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> signInWithGoogleOidc() async {
    try {
      final idToken = await _googleAuth.signInAndGetOidcIdToken();
      if (idToken == null) return left(const AuthFailure.cancelled());

      final device = await _deviceIdentity.get();

      Log.debug(
        'Exchanging Google OIDC id_token (length=${idToken.length})',
        name: 'AuthRepository',
      );

      final apiRequest = OidcExchangeRequestModel(
        provider: 'GOOGLE',
        idToken: idToken,
        deviceId: device.id,
        deviceName: device.name,
      );
      final apiResponse = await _remote.oidcExchange(apiRequest);
      return apiResponse
          .toEitherWithFallback('Google sign-in failed.')
          .mapLeft(mapAuthFailureForOidcExchange)
          .map((m) => m.toSessionEntity());
    } catch (e, st) {
      Log.error(
        'Unexpected error during Google sign-in',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> verifyEmail(
    VerifyEmailRequestEntity request,
  ) async {
    final apiRequest = VerifyEmailRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.verifyEmail(apiRequest);
      return apiResponse
          .toEitherWithFallback('Verify email failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error('Verify email unexpected error', e, st, true, 'AuthRepository');
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> resendEmailVerification() async {
    try {
      final apiResponse = await _remote.resendEmailVerification();
      return apiResponse
          .toEitherWithFallback('Resend verification email failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Resend verification email unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> changePassword(
    ChangePasswordRequestEntity request,
  ) async {
    final apiRequest = ChangePasswordRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.changePassword(apiRequest);
      return apiResponse
          .toEitherWithFallback('Change password failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Change password unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> requestPasswordReset(
    PasswordResetRequestEntity request,
  ) async {
    final apiRequest = PasswordResetRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.requestPasswordReset(apiRequest);
      return apiResponse
          .toEitherWithFallback('Password reset request failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Password reset request unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> confirmPasswordReset(
    PasswordResetConfirmRequestEntity request,
  ) async {
    final apiRequest = PasswordResetConfirmRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.confirmPasswordReset(apiRequest);
      return apiResponse
          .toEitherWithFallback('Password reset confirm failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'Password reset confirm unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
