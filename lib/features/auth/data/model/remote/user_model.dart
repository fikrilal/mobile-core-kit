import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Remote representation of the authenticated user + tokens.
///
/// Expected JSON shape from the backend:
/// {
///   "status": "success",
///   "data": {
///     "id": "...",
///     "email": "...",
///     "displayName": "...",
///     "avatarUrl": "...",
///     "emailVerified": true,
///     "createdAt": "2024-01-01T00:00:00Z",
///     "accessToken": "...",
///     "refreshToken": "...",
///     "expiresIn": 3600
///   },
///   "message": "Login successful"
/// }
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        displayName: entity.displayName,
        emailVerified: entity.emailVerified,
        createdAt: entity.createdAt,
        avatarUrl: entity.avatarUrl,
        accessToken: entity.accessToken,
        refreshToken: entity.refreshToken,
        expiresIn: entity.expiresIn,
      );
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
      );
}
