import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';

class GetProfileImageUrlUseCase {
  GetProfileImageUrlUseCase(this._repository);

  final ProfileImageRepository _repository;

  Future<Either<AuthFailure, ProfileImageUrlEntity?>> call() =>
      _repository.getProfileImageUrl();
}
