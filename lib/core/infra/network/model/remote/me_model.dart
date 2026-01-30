import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/domain/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';

part 'me_model.freezed.dart';
part 'me_model.g.dart';

/// Current signed-in user payload returned by backend-core-kit.
///
/// Source: `MeDto` in `backend-core-kit` OpenAPI (`GET /v1/me`).
///
/// Kept in `core` because it is reused across multiple features (e.g. auth and
/// user), and feature-to-feature imports are forbidden by architecture lints.
@freezed
abstract class MeModel with _$MeModel {
  const factory MeModel({
    required String id,
    required String email,
    required bool emailVerified,
    required List<String> roles,
    required List<String> authMethods,
    required MeProfileModel profile,
    AccountDeletionModel? accountDeletion,
  }) = _MeModel;

  const MeModel._();

  factory MeModel.fromJson(Map<String, dynamic> json) =>
      _$MeModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    emailVerified: emailVerified,
    roles: roles,
    authMethods: authMethods,
    profile: profile.toEntity(),
    accountDeletion: accountDeletion?.toEntity(),
  );
}

@freezed
abstract class MeProfileModel with _$MeProfileModel {
  const factory MeProfileModel({
    String? profileImageFileId,
    String? displayName,
    String? givenName,
    String? familyName,
  }) = _MeProfileModel;

  const MeProfileModel._();

  factory MeProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MeProfileModelFromJson(json);

  UserProfileEntity toEntity() => UserProfileEntity(
    profileImageFileId: profileImageFileId,
    displayName: displayName,
    givenName: givenName,
    familyName: familyName,
  );
}

@freezed
abstract class AccountDeletionModel with _$AccountDeletionModel {
  const factory AccountDeletionModel({
    required String requestedAt,
    required String scheduledFor,
  }) = _AccountDeletionModel;

  const AccountDeletionModel._();

  factory AccountDeletionModel.fromJson(Map<String, dynamic> json) =>
      _$AccountDeletionModelFromJson(json);

  AccountDeletionEntity toEntity() => AccountDeletionEntity(
    requestedAt: requestedAt,
    scheduledFor: scheduledFor,
  );
}
