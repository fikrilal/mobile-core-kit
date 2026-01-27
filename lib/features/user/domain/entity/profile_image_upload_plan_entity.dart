import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image_upload_plan_entity.freezed.dart';

@freezed
abstract class ProfileImageUploadPlanEntity with _$ProfileImageUploadPlanEntity {
  const factory ProfileImageUploadPlanEntity({
    required String fileId,
    required ProfileImagePresignedUploadEntity upload,
    required DateTime expiresAt,
  }) = _ProfileImageUploadPlanEntity;
}

@freezed
abstract class ProfileImagePresignedUploadEntity
    with _$ProfileImagePresignedUploadEntity {
  const factory ProfileImagePresignedUploadEntity({
    required String method,
    required String url,
    required Map<String, String> headers,
  }) = _ProfileImagePresignedUploadEntity;
}

