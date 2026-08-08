import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/account_deletion_action.dart';

abstract class AccountDeletionRepository {
  Future<Either<AuthFailure, Unit>> deleteAccount(
    AccountDeletionAction action,
  );
}
