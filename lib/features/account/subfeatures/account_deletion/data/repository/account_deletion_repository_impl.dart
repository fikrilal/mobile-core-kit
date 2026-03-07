import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/datasource/remote/account_deletion_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/error/account_deletion_failure_mapper.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/model/remote/cancel_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/model/remote/request_account_deletion_request_model.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';

class AccountDeletionRepositoryImpl implements AccountDeletionRepository {
  AccountDeletionRepositoryImpl(this._remote);

  final AccountDeletionRemoteDataSource _remote;

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
          .mapLeft(mapAccountDeletionFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'RequestAccountDeletion unexpected error',
        e,
        st,
        true,
        'AccountDeletionRepository',
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
          .mapLeft(mapAccountDeletionFailure)
          .map((_) => unit);
    } catch (e, st) {
      Log.error(
        'CancelAccountDeletion unexpected error',
        e,
        st,
        true,
        'AccountDeletionRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
