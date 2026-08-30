import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/profile_details.dart';

abstract class ProfileRepository {
  Future<Either<AuthFailure, UserEntity>> patchMeProfile(
    ProfileDetails details,
  );
}
