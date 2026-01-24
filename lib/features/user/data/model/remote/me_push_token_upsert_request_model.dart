import 'package:freezed_annotation/freezed_annotation.dart';

part 'me_push_token_upsert_request_model.freezed.dart';
part 'me_push_token_upsert_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

/// Request payload for `PUT /v1/me/push-token`.
///
/// Backend contract:
/// - `platform`: `ANDROID` | `IOS` | `WEB`
/// - `token`: push token (FCM/APNs), length 1..2048
@freezed
abstract class MePushTokenUpsertRequestModel with _$MePushTokenUpsertRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory MePushTokenUpsertRequestModel({
    required String platform,
    required String token,
  }) = _MePushTokenUpsertRequestModel;

  const MePushTokenUpsertRequestModel._();

  factory MePushTokenUpsertRequestModel.fromJson(Map<String, dynamic> json) =>
      _$MePushTokenUpsertRequestModelFromJson(json);
}

