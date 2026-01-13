import 'package:fpdart/fpdart.dart';

import '../../../auth/domain/failure/auth_failure.dart';
import '../entity/user_entity.dart';
import '../repository/user_repository.dart';

class GetMeUseCase {
  final UserRepository _repository;
  GetMeUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call() => _repository.getMe();
}
