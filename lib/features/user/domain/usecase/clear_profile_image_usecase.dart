import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';

class ClearProfileImageUseCase {
  ClearProfileImageUseCase(this._profileImageRepository, this._getMe);

  final ProfileImageRepository _profileImageRepository;
  final GetMeUseCase _getMe;

  Future<Either<AuthFailure, UserEntity>> call(
    ClearProfileImageRequestEntity request,
  ) async {
    final result = await _profileImageRepository.clearProfileImage(request);

    return result.match(
      (failure) => Future.value(left(failure)),
      (_) => _getMe(),
    );
  }
}
