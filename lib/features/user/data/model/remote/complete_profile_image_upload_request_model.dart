import 'package:freezed_annotation/freezed_annotation.dart';

part 'complete_profile_image_upload_request_model.freezed.dart';
part 'complete_profile_image_upload_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

/// Request payload for `POST /v1/me/profile-image/complete`.
@freezed
abstract class CompleteProfileImageUploadRequestModel
    with _$CompleteProfileImageUploadRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CompleteProfileImageUploadRequestModel({
    required String fileId,
  }) = _CompleteProfileImageUploadRequestModel;

  const CompleteProfileImageUploadRequestModel._();

  factory CompleteProfileImageUploadRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CompleteProfileImageUploadRequestModelFromJson(json);
}

