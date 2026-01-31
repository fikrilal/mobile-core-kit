import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/core/domain/user/entity/account_deletion_entity.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_profile_entity.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,

    /// Whether the user's email address has been verified.
    ///
    /// Backend source: `AuthUserDto.emailVerified`, `MeDto.emailVerified`.
    @Default(false) bool emailVerified,

    /// Authorization roles for the current user (RBAC).
    ///
    /// Backend source: `MeDto.roles`.
    @Default(<String>[]) List<String> roles,

    /// Linked authentication methods on this account.
    ///
    /// Backend source: `MeDto.authMethods` and (optionally) `AuthUserDto.authMethods`.
    @Default(<String>[]) List<String> authMethods,

    /// User profile information (`/v1/me.profile`).
    ///
    /// This may be incomplete for newly registered users (progressive profiling).
    @Default(UserProfileEntity()) UserProfileEntity profile,

    /// When present, the account is scheduled for deletion.
    ///
    /// Backend source: `MeDto.accountDeletion`.
    AccountDeletionEntity? accountDeletion,
  }) = _UserEntity;
}
