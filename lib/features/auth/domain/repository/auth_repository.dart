import '../entity/login_request_entity.dart';
import '../entity/refresh_request_entity.dart';
import '../entity/refresh_response_entity.dart';
import '../entity/user_entity.dart';
import '../entity/register_request_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../failure/auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, UserEntity>> register(
    RegisterRequestEntity request,
  );

  Future<Either<AuthFailure, UserEntity>> login(LoginRequestEntity request);

  Future<Either<AuthFailure, RefreshResponseEntity>> refreshToken(
    RefreshRequestEntity request,
  );

  Future<Either<AuthFailure, String?>> logout(RefreshRequestEntity request);

  /// Native Google sign-in using ID token from SDK.
  Future<Either<AuthFailure, UserEntity>> googleMobileSignIn({
    required String idToken,
  });
}
