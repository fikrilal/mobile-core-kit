import 'package:fpdart/fpdart.dart';
import '../entity/refresh_request_entity.dart';
import '../entity/refresh_response_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class RefreshTokenUsecase {
  final AuthRepository _repository;

  RefreshTokenUsecase(this._repository);

  Future<Either<AuthFailure, RefreshResponseEntity>> call(
    RefreshRequestEntity request,
  ) async {
    return _repository.refreshToken(request);
  }
}
