import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// Minimal user payload returned by auth endpoints in backend-core-kit.
///
/// Source: `AuthUserDto` in `backend-core-kit` OpenAPI.
@freezed
abstract class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String id,
    required String email,
    required bool emailVerified,

    /// Linked authentication methods on this account.
    ///
    /// Backend note: omitted on token refresh responses.
    List<String>? authMethods,
  }) = _AuthUserModel;

  const AuthUserModel._();

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    emailVerified: emailVerified,
    authMethods: authMethods ?? const [],
  );
}
