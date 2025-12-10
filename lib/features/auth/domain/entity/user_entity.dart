import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _UserEntity;
}
