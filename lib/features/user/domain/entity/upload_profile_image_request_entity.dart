import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_profile_image_request_entity.freezed.dart';

@freezed
abstract class UploadProfileImageRequestEntity
    with _$UploadProfileImageRequestEntity {
  const factory UploadProfileImageRequestEntity({
    required Uint8List bytes,
    required String contentType,
    String? idempotencyKey,
  }) = _UploadProfileImageRequestEntity;
}
