import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';

class GetProfileImageUrlUseCase {
  GetProfileImageUrlUseCase(this._repository);

  final ProfileImageRepository _repository;

  Future<Either<AuthFailure, ProfileImageUrlEntity?>> call() =>
      _repository.getProfileImageUrl();
}

