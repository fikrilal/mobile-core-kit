import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/input/profile_update_input.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/profile_details.dart';

class PatchMeProfileUseCase {
  PatchMeProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call(ProfileUpdateInput input) async {
    final details = ProfileDetails.create(
      givenName: input.givenName,
      familyName: input.familyName,
      displayName: input.displayName,
    );

    return details.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.patchMeProfile,
    );
  }
}
