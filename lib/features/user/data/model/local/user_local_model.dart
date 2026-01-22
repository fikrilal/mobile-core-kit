import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_profile_entity.dart';

part 'user_local_model.freezed.dart';

@freezed
abstract class UserLocalModel with _$UserLocalModel {
  static const tableName = 'users';
  static const createTableQuery =
      'CREATE TABLE IF NOT EXISTS users ('
      'id TEXT PRIMARY KEY,'
      'email TEXT,'
      'emailVerified INTEGER,'
      'rolesJson TEXT,'
      'authMethodsJson TEXT,'
      'profileImageFileId TEXT,'
      'displayName TEXT,'
      'givenName TEXT,'
      'familyName TEXT,'
      'accountDeletionRequestedAt TEXT,'
      'accountDeletionScheduledFor TEXT'
      ');';

  const factory UserLocalModel({
    String? id,
    String? email,
    bool? emailVerified,
    String? rolesJson,
    String? authMethodsJson,
    String? profileImageFileId,
    String? displayName,
    String? givenName,
    String? familyName,
    String? accountDeletionRequestedAt,
    String? accountDeletionScheduledFor,
  }) = _UserLocalModel;

  const UserLocalModel._();

  factory UserLocalModel.fromMap(Map<String, dynamic> m) => UserLocalModel(
    id: m['id'] as String?,
    email: m['email'] as String?,
    emailVerified: m['emailVerified'] == null
        ? null
        : (m['emailVerified'] as int) == 1,
    rolesJson: m['rolesJson'] as String?,
    authMethodsJson: m['authMethodsJson'] as String?,
    profileImageFileId: m['profileImageFileId'] as String?,
    displayName: m['displayName'] as String?,
    givenName: m['givenName'] as String?,
    familyName: m['familyName'] as String?,
    accountDeletionRequestedAt: m['accountDeletionRequestedAt'] as String?,
    accountDeletionScheduledFor: m['accountDeletionScheduledFor'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'emailVerified': emailVerified == null ? null : (emailVerified! ? 1 : 0),
    'rolesJson': rolesJson,
    'authMethodsJson': authMethodsJson,
    'profileImageFileId': profileImageFileId,
    'displayName': displayName,
    'givenName': givenName,
    'familyName': familyName,
    'accountDeletionRequestedAt': accountDeletionRequestedAt,
    'accountDeletionScheduledFor': accountDeletionScheduledFor,
  };

  UserEntity? toEntity() {
    if (id == null || id!.isEmpty || email == null || email!.isEmpty) {
      return null;
    }
    final roles = _decodeStringList(rolesJson);
    final authMethods = _decodeStringList(authMethodsJson);
    final accountDeletion = _toAccountDeletionEntity(
      requestedAt: accountDeletionRequestedAt,
      scheduledFor: accountDeletionScheduledFor,
    );

    return UserEntity(
      id: id!,
      email: email!,
      emailVerified: emailVerified ?? false,
      roles: roles,
      authMethods: authMethods,
      profile: UserProfileEntity(
        profileImageFileId: profileImageFileId,
        displayName: displayName,
        givenName: givenName,
        familyName: familyName,
      ),
      accountDeletion: accountDeletion,
    );
  }

  static List<String> _decodeStringList(String? json) {
    if (json == null || json.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Object?>()
          .map((e) => e?.toString())
          .whereType<String>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static AccountDeletionEntity? _toAccountDeletionEntity({
    required String? requestedAt,
    required String? scheduledFor,
  }) {
    if (requestedAt == null || requestedAt.trim().isEmpty) return null;
    if (scheduledFor == null || scheduledFor.trim().isEmpty) return null;
    return AccountDeletionEntity(
      requestedAt: requestedAt,
      scheduledFor: scheduledFor,
    );
  }
}

extension UserEntityLocalX on UserEntity {
  UserLocalModel toLocalModel() {
    final rolesJson = roles.isEmpty ? null : jsonEncode(roles);
    final authMethodsJson = authMethods.isEmpty ? null : jsonEncode(authMethods);
    return UserLocalModel(
      id: id,
      email: email,
      emailVerified: emailVerified,
      rolesJson: rolesJson,
      authMethodsJson: authMethodsJson,
      profileImageFileId: profile.profileImageFileId,
      displayName: profile.displayName,
      givenName: profile.givenName,
      familyName: profile.familyName,
      accountDeletionRequestedAt: accountDeletion?.requestedAt,
      accountDeletionScheduledFor: accountDeletion?.scheduledFor,
    );
  }
}
