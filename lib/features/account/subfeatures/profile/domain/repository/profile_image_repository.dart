import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_image_upload_plan_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/profile_image_url_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/value/validated_profile_image_upload.dart';

abstract class ProfileImageRepository {
  Future<Either<AuthFailure, ProfileImageUploadPlanEntity>> createUploadPlan(
    ValidatedProfileImageUpload upload,
  );

  Future<Either<AuthFailure, Unit>> uploadToPresignedUrl({
    required ProfileImageUploadPlanEntity plan,
    required Uint8List bytes,
  });

  Future<Either<AuthFailure, Unit>> completeUpload(
    CompleteProfileImageUploadRequestEntity request,
  );

  Future<Either<AuthFailure, Unit>> clearProfileImage(
    ClearProfileImageRequestEntity request,
  );

  Future<Either<AuthFailure, ProfileImageUrlEntity?>> getProfileImageUrl();
}
