import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/input/profile_image_upload_input.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/refresh_current_user_after_profile_image_mutation.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/validated_profile_image_upload.dart';

class UploadProfileImageUseCase {
  UploadProfileImageUseCase(this._repository, this._currentUserFetcher);

  final ProfileImageRepository _repository;
  final CurrentUserFetcher _currentUserFetcher;

  Future<Either<AuthFailure, UserEntity>> call(
    ProfileImageUploadInput input,
  ) async {
    final upload = ValidatedProfileImageUpload.create(
      bytes: input.bytes,
      contentType: input.contentType,
      idempotencyKey: input.idempotencyKey,
    );

    return upload.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _upload,
    );
  }

  Future<Either<AuthFailure, UserEntity>> _upload(
    ValidatedProfileImageUpload upload,
  ) async {
    final planResult = await _repository.createUploadPlan(upload);

    return planResult.match((failure) => Future.value(left(failure)), (
      plan,
    ) async {
      final uploadResult = await _repository.uploadToPresignedUrl(
        plan: plan,
        bytes: upload.bytes,
      );

      return uploadResult.match((failure) => Future.value(left(failure)), (
        _,
      ) async {
        final completeResult = await _repository.completeUpload(
          CompleteProfileImageUploadRequestEntity(fileId: plan.fileId),
        );

        return completeResult.match(
          (failure) => Future.value(left(failure)),
          (_) =>
              refreshCurrentUserAfterProfileImageMutation(_currentUserFetcher),
        );
      });
    });
  }
}
