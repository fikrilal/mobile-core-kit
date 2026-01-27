import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_profile_image_upload_request_model.freezed.dart';
part 'create_profile_image_upload_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

/// Request payload for `POST /v1/me/profile-image/upload`.
///
/// Backend contract:
/// - `contentType`: `image/jpeg` | `image/png` | `image/webp`
/// - `sizeBytes`: 1..5_000_000
@freezed
abstract class CreateProfileImageUploadRequestModel
    with _$CreateProfileImageUploadRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory CreateProfileImageUploadRequestModel({
    required String contentType,
    required int sizeBytes,
  }) = _CreateProfileImageUploadRequestModel;

  const CreateProfileImageUploadRequestModel._();

  factory CreateProfileImageUploadRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateProfileImageUploadRequestModelFromJson(json);
}

