import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

abstract class UserRepository {
  Future<Either<AuthFailure, UserEntity>> getMe();
}
