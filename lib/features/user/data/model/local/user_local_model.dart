import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

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
      'emailVerified INTEGER,'
      'createdAt TEXT'
      ');';

  const factory UserLocalModel({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? emailVerified,
    String? createdAt,
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
    createdAt: m['createdAt'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'emailVerified': emailVerified == null ? null : (emailVerified! ? 1 : 0),
    'createdAt': createdAt,
  };

  UserEntity? toEntity() {
    if (id == null || id!.isEmpty || email == null || email!.isEmpty) {
      return null;
    }
    return UserEntity(
      id: id!,
      email: email!,
      firstName: firstName,
      lastName: lastName,
      emailVerified: emailVerified,
      createdAt: createdAt,
    );
  }
}

extension UserEntityLocalX on UserEntity {
  UserLocalModel toLocalModel() => UserLocalModel(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    emailVerified: emailVerified,
    createdAt: createdAt,
  );
}
