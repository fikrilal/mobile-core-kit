import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/cancel_account_deletion_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/request_account_deletion_request_entity.dart';

abstract class UserRepository {
  Future<Either<AuthFailure, UserEntity>> getMe();

  Future<Either<AuthFailure, UserEntity>> patchMeProfile(
    PatchMeProfileRequestEntity request,
  );

  Future<Either<AuthFailure, Unit>> requestAccountDeletion(
    RequestAccountDeletionRequestEntity request,
  );

  Future<Either<AuthFailure, Unit>> cancelAccountDeletion(
    CancelAccountDeletionRequestEntity request,
  );
}
