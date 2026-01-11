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
import '../../domain/failure/auth_failure.dart';
import '../../domain/entity/register_request_entity.dart';
import '../error/auth_failure_mapper.dart';
import '../../../../../core/services/federated_auth/google_federated_auth_service.dart';
import '../model/remote/google_sign_in_request_model.dart';
import '../../../../core/utilities/log_utils.dart';

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
          .mapLeft(mapAuthFailure)
          .map((m) => m.toEntity());
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
  Future<Either<AuthFailure, Unit>> revokeSessions() async {
    try {
      final apiResponse = await _remote.revokeSessions();
      return apiResponse
          .toEitherWithFallback('Revoke sessions failed.')
          .mapLeft(mapAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error('Revoke sessions unexpected error', e, st, true, 'AuthRepository');
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, AuthSessionEntity>> googleSignIn() async {
    try {
      final idToken = await _googleAuth.signInAndGetFirebaseIdToken();
      if (idToken == null) return left(const AuthFailure.cancelled());

      Log.debug(
        'Exchanging Firebase ID token (length=${idToken.length})',
        name: 'AuthRepository',
      );

      final apiRequest = GoogleSignInRequestModel(idToken);
      final apiResponse = await _remote.googleSignIn(apiRequest);
      return apiResponse
          .toEitherWithFallback('Google sign-in failed.')
          .mapLeft(mapAuthFailureForGoogle)
          .map((m) => m.toEntity());
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
