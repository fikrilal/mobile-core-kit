import 'package:fpdart/fpdart.dart';

import '../../../auth/domain/failure/auth_failure.dart';
import '../entity/user_entity.dart';

abstract class UserRepository {
  Future<Either<AuthFailure, UserEntity>> getMe();
}
