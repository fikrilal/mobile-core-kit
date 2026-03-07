import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/error/user_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, UserEntity>> getMe() async {
    try {
      final apiResponse = await _remote.getMe();
      return apiResponse
          .toEitherWithFallback('Failed to load user.')
          .mapLeft(mapUserFailure)
          .map((m) => m.toEntity());
    } catch (e, st) {
      Log.error('GetMe unexpected error', e, st, true, 'UserRepository');
      return left(const AuthFailure.unexpected());
    }
  }
}
