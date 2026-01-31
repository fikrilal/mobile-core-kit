import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';

class GetMeUseCase {
  final UserRepository _repository;
  GetMeUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call() => _repository.getMe();
}
