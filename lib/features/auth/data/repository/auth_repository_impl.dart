import 'package:fpdart/fpdart.dart';
import '../model/remote/refresh_response_model.dart';
import '../../domain/entity/login_request_entity.dart';
import '../../domain/entity/refresh_request_entity.dart';
import '../../domain/entity/refresh_response_entity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/remote/auth_remote_datasource.dart';
import '../model/remote/login_request_model.dart';
import '../model/remote/refresh_request_model.dart';
import '../model/remote/register_request_model.dart';
import '../model/remote/user_model.dart';
import '../../../../../core/network/exceptions/api_failure.dart';
import '../../domain/failure/auth_failure.dart';
import '../../domain/entity/register_request_entity.dart';
import '../model/remote/google_mobile_request_model.dart';
import '../../../../core/utilities/log_utils.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<AuthFailure, UserEntity>> register(
    RegisterRequestEntity request,
  ) async {
    final apiRequest = RegisterRequestModel.fromEntity(request);

    try {
      final apiResponse = await _remote.register(apiRequest);
      final model = apiResponse.data!;
      return right(model.toEntity());
    } on ApiFailure catch (f) {
      return left(_mapApiFailure(f));
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
  Future<Either<AuthFailure, UserEntity>> login(
    LoginRequestEntity request,
  ) async {
    final apiRequest = LoginRequestModel.fromEntity(request);

    try {
      final apiResponse = await _remote.login(apiRequest);
      final model = apiResponse.data!;
      return right(model.toEntity());
    } on ApiFailure catch (f) {
      return left(_mapApiFailure(f));
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
  Future<Either<AuthFailure, RefreshResponseEntity>> refreshToken(
    RefreshRequestEntity request,
  ) async {
    final apiRequest = RefreshRequestModel.fromEntity(request);
    try {
      final apiResponse = await _remote.refreshToken(apiRequest);
      final model = apiResponse.data!;
      return right(model.toEntity());
    } on ApiFailure catch (f) {
      return left(_mapApiFailure(f));
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
      return right(apiResponse.message);
    } on ApiFailure catch (f) {
      return left(_mapApiFailure(f));
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
      case 500:
        return const AuthFailure.serverError();
      case 409:
        final msg = f.message.toLowerCase();
        if (msg.contains('email')) return const AuthFailure.emailTaken();
        if (msg.contains('username')) return const AuthFailure.usernameTaken();

        return const AuthFailure.usernameTaken();
      case 422:
      case 400:
        final hasValidationErrors = (f.validationErrors ?? []).isNotEmpty;
        if (!hasValidationErrors) {
          final msg = f.message.toLowerCase();
          if (msg.contains('already') && msg.contains('email')) {
            return const AuthFailure.emailTaken();
          }
          if (msg.contains('already') && msg.contains('username')) {
            return const AuthFailure.usernameTaken();
          }
        }
        return AuthFailure.validation(f.validationErrors ?? []);
      case -1:
        return const AuthFailure.network();
      default:
        return const AuthFailure.unexpected();
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> googleMobileSignIn({
    required String idToken,
  }) async {
    final apiRequest = GoogleMobileRequestModel(idToken);
    try {
      Log.debug(
        'Exchanging Google ID token (length=${idToken.length})',
        name: 'AuthRepository',
      );
      final apiResponse = await _remote.googleMobileSignIn(apiRequest);
      final model = apiResponse.data!;
      Log.info(
        'Google mobile exchange success; token lengths (access=${model.accessToken?.length ?? 0}, refresh=${model.refreshToken?.length ?? 0})',
        name: 'AuthRepository',
      );
      return right(model.toEntity());
    } on ApiFailure catch (f) {
      Log.error(
        'Google mobile exchange failed',
        f,
        StackTrace.current,
        true,
        'AuthRepository',
      );
      return left(_mapApiFailureForGoogle(f));
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
        return AuthFailure.validation(f.validationErrors ?? []);
      case 429:
        return const AuthFailure.tooManyRequests();
      case 500:
        return const AuthFailure.serverError();
      case -1:
        return const AuthFailure.network();
      default:
        return const AuthFailure.unexpected();
    }
  }
}
