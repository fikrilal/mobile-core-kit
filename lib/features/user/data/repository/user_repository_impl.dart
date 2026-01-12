import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api/api_response_either.dart';
import '../../../../core/network/exceptions/api_error_codes.dart';
import '../../../../core/network/exceptions/api_failure.dart';
import '../../../../core/utilities/log_utils.dart';
import '../../../auth/domain/failure/auth_failure.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, UserEntity>> getMe() async {
    try {
      final apiResponse = await _remote.getMe();
      return apiResponse
          .toEitherWithFallback('Failed to load user.')
          .mapLeft(_mapApiFailure)
          .map((m) => m.toEntity());
    } catch (e, st) {
      Log.error(
        'GetMe unexpected error',
        e,
        st,
        true,
        'UserRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  AuthFailure _mapApiFailure(ApiFailure f) {
    final code = f.code;
    if (code != null) {
      switch (code) {
        case ApiErrorCodes.unauthorized:
          return const AuthFailure.unauthenticated();
        case ApiErrorCodes.rateLimited:
          return const AuthFailure.tooManyRequests();
      }
    }

    switch (f.statusCode) {
      case 401:
        return const AuthFailure.unauthenticated();
      case 429:
        return const AuthFailure.tooManyRequests();
      case 500:
        return const AuthFailure.serverError();
      case -1:
      case -2:
        return const AuthFailure.network();
      default:
        return const AuthFailure.unexpected();
    }
  }
}
