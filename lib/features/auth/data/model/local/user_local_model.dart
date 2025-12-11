import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/user_entity.dart';

part 'user_local_model.freezed.dart';

@freezed
abstract class UserLocalModel with _$UserLocalModel {
  static const tableName = 'users';
  static const createTableQuery =
      'CREATE TABLE users ('
      'id TEXT PRIMARY KEY,'
      'email TEXT,'
      'displayName TEXT,'
      'emailVerified INTEGER,'
      'createdAt TEXT,'
      'avatarUrl TEXT'
      ');';

  const factory UserLocalModel({
    String? id,
    String? email,
    String? displayName,
    bool? emailVerified,
    String? createdAt,
    String? avatarUrl,
  }) = _UserLocalModel;

  const UserLocalModel._();

  factory UserLocalModel.fromMap(Map<String, dynamic> m) => UserLocalModel(
        id: m['id'] as String?,
        email: m['email'] as String?,
        displayName: m['displayName'] as String?,
        emailVerified: m['emailVerified'] == null
            ? null
            : (m['emailVerified'] as int) == 1,
        createdAt: m['createdAt'] as String?,
        avatarUrl: m['avatarUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'emailVerified':
            emailVerified == null ? null : (emailVerified! ? 1 : 0),
        'createdAt': createdAt,
        'avatarUrl': avatarUrl,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
      );
}

extension UserEntityLocalX on UserEntity {
  UserLocalModel toLocalModel() => UserLocalModel(
        id: id,
        email: email,
        displayName: displayName,
        emailVerified: emailVerified,
        createdAt: createdAt,
        avatarUrl: avatarUrl,
      );
}
