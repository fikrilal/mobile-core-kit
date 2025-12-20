import 'package:fpdart/fpdart.dart';
import '../../domain/entity/login_request_entity.dart';
import '../../domain/entity/refresh_request_entity.dart';
import '../../domain/entity/auth_session_entity.dart';
import '../../domain/entity/auth_tokens_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../model/remote/login_request_model.dart';
import '../model/remote/refresh_request_model.dart';
import '../model/remote/register_request_model.dart';
import '../model/remote/auth_session_model.dart';
import '../../../../../core/network/api/api_response_either.dart';
import '../../../../../core/network/exceptions/api_failure.dart';
import '../../domain/failure/auth_failure.dart';
import '../../domain/entity/register_request_entity.dart';
import '../model/remote/google_mobile_request_model.dart';
import '../../../../core/utilities/log_utils.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> register(
    RegisterRequestEntity request,
  ) async {
    final apiRequest = RegisterRequestModel.fromEntity(request);

    try {
      final apiResponse = await _remote.register(apiRequest);
      return apiResponse
          .toEitherWithFallback('Register failed.')
          .mapLeft(_mapApiFailure)
          .map((m) => m.toEntity());
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
          .mapLeft(_mapApiFailure)
          .map((m) => m.toEntity());
    } catch (e, st) {
      Log.error(
        'Login user unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
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
          .mapLeft(_mapApiFailure)
          .map((m) => m.toEntity());
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
  Future<Either<AuthFailure, String?>> logout(
    RefreshRequestEntity request,
  ) async {
    final apiRequest = RefreshRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.logout(apiRequest);
      final message = apiResponse.message;
      return apiResponse
          .toEitherWithFallback('Logout failed.')
          .mapLeft(_mapApiFailure)
          .map((_) => message);
    } catch (e, st) {
      Log.error(
        'Logout unexpected error',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  AuthFailure _mapApiFailure(ApiFailure f) {
    switch (f.statusCode) {
      case 401:
        return const AuthFailure.invalidCredentials();
      case 429:
        return const AuthFailure.tooManyRequests();
      case 409:
        return const AuthFailure.emailTaken();
      case 422:
      case 400:
        return AuthFailure.validation(f.validationErrors ?? const []);
      case -1:
        return const AuthFailure.network();
      default:
        // Fallback for server errors and unexpected shapes.
        if ((f.statusCode ?? 0) >= 500) return const AuthFailure.serverError();
        return AuthFailure.unexpected(message: f.message);
    }
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> googleMobileSignIn({
    required String idToken,
  }) async {
    final apiRequest = GoogleMobileRequestModel(idToken);
    try {
      Log.debug(
        'Exchanging Google ID token (length=${idToken.length})',
        name: 'AuthRepository',
      );
      final apiResponse = await _remote.googleMobileSignIn(apiRequest);
      return apiResponse
          .toEitherWithFallback('Google sign-in failed.')
          .mapLeft(_mapApiFailureForGoogle)
          .map((m) => m.toEntity());
    } catch (e, st) {
      Log.error(
        'Unexpected error during Google mobile exchange',
        e,
        st,
        true,
        'AuthRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  AuthFailure _mapApiFailureForGoogle(ApiFailure f) {
    switch (f.statusCode) {
      case 401:
        // Unauthorized exchange (e.g., invalid/expired ID token)
        return const AuthFailure.invalidCredentials();
      case 400:
        // Invalid/missing token, audience/issuer mismatch, expired token
        return AuthFailure.validation(f.validationErrors ?? const []);
      case 429:
        return const AuthFailure.tooManyRequests();
      case -1:
        return const AuthFailure.network();
      default:
        if ((f.statusCode ?? 0) >= 500) return const AuthFailure.serverError();
        return AuthFailure.unexpected(message: f.message);
    }
  }
}
