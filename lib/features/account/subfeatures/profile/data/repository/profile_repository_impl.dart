import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response_either.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/error/profile_failure_mapper.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/patch_me_profile_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<AuthFailure, UserEntity>> patchMeProfile(
    PatchMeProfileRequestEntity request,
  ) async {
    try {
      final apiResponse = await _remote.patchMeProfile(
        request: PatchMeRequestModel(
          profile: PatchMeProfileModel(
            displayName: request.displayName,
            givenName: request.givenName,
            familyName: request.familyName,
          ),
        ),
      );

      return apiResponse
          .toEitherWithFallback('Failed to update profile.')
          .mapLeft(mapProfileFailure)
          .map((model) => model.toEntity());
    } catch (e, st) {
      Log.error(
        'PatchMeProfile unexpected error',
        e,
        st,
        true,
        'ProfileRepository',
      );
      return left(const AuthFailure.unexpected());
    }
  }
}
