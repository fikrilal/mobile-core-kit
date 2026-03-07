import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image_url_model.freezed.dart';
part 'profile_image_url_model.g.dart';

// ignore_for_file: invalid_annotation_target

/// Response body for `GET /v1/me/profile-image/url` (200 only).
@freezed
abstract class ProfileImageUrlModel with _$ProfileImageUrlModel {
  @JsonSerializable(includeIfNull: false)
  const factory ProfileImageUrlModel({
    required String url,
    required String expiresAt,
  }) = _ProfileImageUrlModel;

  const ProfileImageUrlModel._();

  factory ProfileImageUrlModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUrlModelFromJson(json);
}
