import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image_upload_plan_model.freezed.dart';
part 'profile_image_upload_plan_model.g.dart';

// ignore_for_file: invalid_annotation_target

Map<String, String> _headersFromJson(Map<String, dynamic> json) => json.map(
  (k, v) => MapEntry(k, v == null ? '' : v.toString()),
);

Map<String, dynamic> _headersToJson(Map<String, String> json) => json;

/// Upload plan returned by `POST /v1/me/profile-image/upload`.
///
/// Contains a backend-generated presigned URL that the client must execute.
@freezed
abstract class ProfileImageUploadPlanModel with _$ProfileImageUploadPlanModel {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory ProfileImageUploadPlanModel({
    required String fileId,
    required PresignedUploadModel upload,
    required String expiresAt,
  }) = _ProfileImageUploadPlanModel;

  const ProfileImageUploadPlanModel._();

  factory ProfileImageUploadPlanModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUploadPlanModelFromJson(json);
}

@freezed
abstract class PresignedUploadModel with _$PresignedUploadModel {
  @JsonSerializable(includeIfNull: false)
  const factory PresignedUploadModel({
    required String method,
    required String url,
    @JsonKey(fromJson: _headersFromJson, toJson: _headersToJson)
    required Map<String, String> headers,
  }) = _PresignedUploadModel;

  const PresignedUploadModel._();

  factory PresignedUploadModel.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadModelFromJson(json);
}

