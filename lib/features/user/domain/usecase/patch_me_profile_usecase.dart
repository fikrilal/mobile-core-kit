import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/foundation/validation/value_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/value/family_name.dart';
import 'package:mobile_core_kit/features/user/domain/value/given_name.dart';

class PatchMeProfileUseCase {
  PatchMeProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<Either<AuthFailure, UserEntity>> call(
    PatchMeProfileRequestEntity request,
  ) async {
    final errors = <ValidationError>[];

    final givenName = GivenName.create(request.givenName);
    final familyName = FamilyName.createOptional(request.familyName ?? '');

    String normalizedGivenName = request.givenName.trim();
    String? normalizedFamilyName = request.familyName?.trim();

    givenName.fold(
      (f) => errors.add(
        ValidationError(field: 'givenName', message: '', code: f.code),
      ),
      (value) => normalizedGivenName = value.value,
    );

    familyName.fold(
      (f) => errors.add(
        ValidationError(field: 'familyName', message: '', code: f.code),
      ),
      (value) => normalizedFamilyName = value?.value,
    );

    final displayNameTrimmed = request.displayName?.trim();
    final normalizedDisplayName =
        (displayNameTrimmed == null || displayNameTrimmed.isEmpty)
        ? null
        : displayNameTrimmed;

    if (errors.isNotEmpty) {
      return left<AuthFailure, UserEntity>(AuthFailure.validation(errors));
    }

    return _repository.patchMeProfile(
      PatchMeProfileRequestEntity(
        givenName: normalizedGivenName,
        familyName: normalizedFamilyName,
        displayName: normalizedDisplayName,
      ),
    );
  }
}
