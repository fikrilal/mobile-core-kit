import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/entity/request_account_deletion_request_entity.dart';

abstract class AccountDeletionRepository {
  Future<Either<AuthFailure, Unit>> requestAccountDeletion(
    RequestAccountDeletionRequestEntity request,
  );

  Future<Either<AuthFailure, Unit>> cancelAccountDeletion(
    CancelAccountDeletionRequestEntity request,
  );
}
