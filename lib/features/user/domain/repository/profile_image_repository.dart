import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/complete_profile_image_upload_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/create_profile_image_upload_plan_request_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_upload_plan_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/profile_image_url_entity.dart';

abstract class ProfileImageRepository {
  Future<Either<AuthFailure, ProfileImageUploadPlanEntity>> createUploadPlan(
    CreateProfileImageUploadPlanRequestEntity request,
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

