import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/auth_user_entity.dart';

part 'user_local_model.freezed.dart';

@freezed
abstract class UserLocalModel with _$UserLocalModel {
  static const tableName = 'users';
  static const createTableQuery =
      'CREATE TABLE IF NOT EXISTS users ('
      'id TEXT PRIMARY KEY,'
      'email TEXT,'
      'firstName TEXT,'
      'lastName TEXT,'
      'emailVerified INTEGER'
      ');';

  const factory UserLocalModel({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? emailVerified,
  }) = _UserLocalModel;

  const UserLocalModel._();

  factory UserLocalModel.fromMap(Map<String, dynamic> m) => UserLocalModel(
        id: m['id'] as String?,
        email: m['email'] as String?,
        firstName: m['firstName'] as String?,
        lastName: m['lastName'] as String?,
        emailVerified: m['emailVerified'] == null
            ? null
            : (m['emailVerified'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'emailVerified':
            emailVerified == null ? null : (emailVerified! ? 1 : 0),
      };

  AuthUserEntity? toEntity() {
    if (id == null || id!.isEmpty || email == null || email!.isEmpty) {
      return null;
    }
    return AuthUserEntity(
      id: id!,
      email: email!,
      firstName: firstName,
      lastName: lastName,
      emailVerified: emailVerified ?? false,
    );
  }
}

extension AuthUserEntityLocalX on AuthUserEntity {
  UserLocalModel toLocalModel() => UserLocalModel(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        emailVerified: emailVerified,
      );
}
