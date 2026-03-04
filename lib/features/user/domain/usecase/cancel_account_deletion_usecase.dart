import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';

class CancelAccountDeletionUseCase {
  CancelAccountDeletionUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<AuthFailure, Unit>> call(
    CancelAccountDeletionRequestEntity request,
  ) {
    return _repository.cancelAccountDeletion(request);
  }
}
