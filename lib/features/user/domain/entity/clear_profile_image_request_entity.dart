import 'package:freezed_annotation/freezed_annotation.dart';

part 'clear_profile_image_request_entity.freezed.dart';

@freezed
abstract class ClearProfileImageRequestEntity
    with _$ClearProfileImageRequestEntity {
  const factory ClearProfileImageRequestEntity({
    String? idempotencyKey,
  }) = _ClearProfileImageRequestEntity;
}

