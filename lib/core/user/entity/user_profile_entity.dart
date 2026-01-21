import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    String? profileImageFileId,
    String? displayName,
    String? givenName,
    String? familyName,
  }) = _UserProfileEntity;
}
