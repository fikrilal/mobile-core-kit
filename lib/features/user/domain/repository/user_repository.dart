import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';

abstract class UserRepository {
  Future<Either<AuthFailure, UserEntity>> getMe();

  Future<Either<AuthFailure, UserEntity>> patchMeProfile(
    PatchMeProfileRequestEntity request,
  );
}
