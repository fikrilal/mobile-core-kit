import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';

class AccountDeletionUseCase {
  AccountDeletionUseCase(this._repository);

  final AccountDeletionRepository _repository;

  Future<Either<AuthFailure, Unit>> call(AccountDeletionAction action) {
    return _repository.deleteAccount(action);
  }
}
