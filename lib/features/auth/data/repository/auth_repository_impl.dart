import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/network/api/api_response_either.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/utilities/log_utils.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/error/auth_failure_mapper.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_result_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/login_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/logout_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/oidc_exchange_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/refresh_request_model.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/register_request_model.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final GoogleFederatedAuthService _googleAuth;

  AuthRepositoryImpl(this._remote, this._googleAuth);

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> register(
    RegisterRequestEntity request,
  ) async {
    final apiRequest = RegisterRequestModel.fromEntity(request);

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
    final apiRequest = LoginRequestModel.fromEntity(request);

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

      Log.debug(
        'Exchanging Google OIDC id_token (length=${idToken.length})',
        name: 'AuthRepository',
      );

      final apiRequest = OidcExchangeRequestModel(
        provider: 'GOOGLE',
        idToken: idToken,
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
}
