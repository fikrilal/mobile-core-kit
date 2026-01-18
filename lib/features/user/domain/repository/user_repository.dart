import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

abstract class UserRepository {
  Future<Either<AuthFailure, UserEntity>> getMe();
}
