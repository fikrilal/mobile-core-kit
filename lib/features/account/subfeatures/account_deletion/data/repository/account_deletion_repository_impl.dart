import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/account/data/error/account_auth_failure_mapper.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/datasource/remote/account_deletion_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';

class AccountDeletionRepositoryImpl implements AccountDeletionRepository {
  AccountDeletionRepositoryImpl(this._remote);

  final AccountDeletionRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, Unit>> deleteAccount(
    AccountDeletionAction action,
  ) async {
    try {
      final apiResponse = await _remote.requestDeletion(action);

      return apiResponse
          .toEitherWithFallback('Failed to delete account.')
          .mapLeft(mapAccountAuthFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'AccountDeletion unexpected error',
        e,
        st,
        true,
        'AccountDeletionRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
