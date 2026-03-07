import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'patch_me_request_model.freezed.dart';
part 'patch_me_request_model.g.dart';

/// Request payload for `PATCH /v1/me`.
///
/// Backend contract:
/// - `profile` is required.
/// - Omitted fields are unchanged.
/// - `null` clears a field (template currently omits nulls by default).
@freezed
abstract class PatchMeRequestModel with _$PatchMeRequestModel {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory PatchMeRequestModel({required PatchMeProfileModel profile}) =
      _PatchMeRequestModel;

  const PatchMeRequestModel._();

  factory PatchMeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PatchMeRequestModelFromJson(json);
}

@freezed
abstract class PatchMeProfileModel with _$PatchMeProfileModel {
  @JsonSerializable(includeIfNull: false)
  const factory PatchMeProfileModel({
    String? displayName,
    String? givenName,
    String? familyName,
  }) = _PatchMeProfileModel;

  const PatchMeProfileModel._();

  factory PatchMeProfileModel.fromJson(Map<String, dynamic> json) =>
      _$PatchMeProfileModelFromJson(json);
}
