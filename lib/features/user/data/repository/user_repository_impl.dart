import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/error/user_failure_mapper.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/cancel_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/request_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/user/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';
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

  @override
  Future<Either<AuthFailure, Unit>> requestAccountDeletion(
    RequestAccountDeletionRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.requestAccountDeletion(
        request: request.toModel(),
      );

      return apiResponse
          .toEitherWithFallback('Failed to request account deletion.')
          .mapLeft(mapUserFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'RequestAccountDeletion unexpected error',
        e,
        st,
        true,
        'UserRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> cancelAccountDeletion(
    CancelAccountDeletionRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.cancelAccountDeletion(
        request: request.toModel(),
      );

      return apiResponse
          .toEitherWithFallback('Failed to cancel account deletion.')
          .mapLeft(mapUserFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'CancelAccountDeletion unexpected error',
        e,
        st,
        true,
        'UserRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
