import 'package:freezed_annotation/freezed_annotation.dart';

part 'complete_profile_image_upload_request_entity.freezed.dart';

@freezed
abstract class CompleteProfileImageUploadRequestEntity
    with _$CompleteProfileImageUploadRequestEntity {
  const factory CompleteProfileImageUploadRequestEntity({
    required String fileId,
  }) = _CompleteProfileImageUploadRequestEntity;
}
