import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';

class RefreshTokenUsecase {
  final AuthRepository _repository;

  RefreshTokenUsecase(this._repository);

  Future<Either<AuthFailure, AuthTokensEntity>> call(
    RefreshRequestEntity request,
  ) async {
    return _repository.refreshToken(request);
  }
}
