import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_image_url_entity.freezed.dart';

@freezed
abstract class ProfileImageUrlEntity with _$ProfileImageUrlEntity {
  const factory ProfileImageUrlEntity({
    required String url,
    required DateTime expiresAt,
  }) = _ProfileImageUrlEntity;
}
