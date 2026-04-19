import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/refresh_current_user_after_profile_image_mutation.dart';

class ClearProfileImageUseCase {
  ClearProfileImageUseCase(
    this._profileImageRepository,
    this._currentUserFetcher,
  );

  final ProfileImageRepository _profileImageRepository;
  final CurrentUserFetcher _currentUserFetcher;

  Future<Either<AuthFailure, UserEntity>> call(
    ClearProfileImageRequestEntity request,
  ) async {
    final result = await _profileImageRepository.clearProfileImage(request);

    return result.match(
      (failure) => Future.value(left(failure)),
      (_) => refreshCurrentUserAfterProfileImageMutation(_currentUserFetcher),
    );
  }
}
