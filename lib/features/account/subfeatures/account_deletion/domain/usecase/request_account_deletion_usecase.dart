import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/request_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';

class RequestAccountDeletionUseCase {
  RequestAccountDeletionUseCase(this._repository);

  final AccountDeletionRepository _repository;

  Future<Either<AuthFailure, Unit>> call(
    RequestAccountDeletionRequestEntity request,
  ) {
    return _repository.requestAccountDeletion(request);
  }
}
