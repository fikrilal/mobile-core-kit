import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/account/data/datasource/remote/me_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/data/error/account_auth_failure_mapper.dart';
import 'package:mobile_core_kit/features/account/domain/repository/current_user_repository.dart';

class CurrentUserRepositoryImpl implements CurrentUserRepository {
  CurrentUserRepositoryImpl(this._remote);

  final MeRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, UserEntity>> getCurrentUser() async {
    try {
      final apiResponse = await _remote.getMe();
      return apiResponse
          .toEitherWithFallback('Failed to load user.')
          .mapLeft(mapAccountAuthFailure)
          .map((model) => model.toEntity());
    } catch (e, st) {
      Log.error(
        'GetCurrentUser unexpected error',
        e,
        st,
        true,
        'CurrentUserRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
