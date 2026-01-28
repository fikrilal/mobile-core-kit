import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_image_upload_plan_request_entity.freezed.dart';

@freezed
abstract class CreateProfileImageUploadPlanRequestEntity
    with _$CreateProfileImageUploadPlanRequestEntity {
  const factory CreateProfileImageUploadPlanRequestEntity({
    required String contentType,
    required int sizeBytes,
    String? idempotencyKey,
  }) = _CreateProfileImageUploadPlanRequestEntity;
}
