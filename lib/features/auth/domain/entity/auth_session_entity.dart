import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

part 'auth_session_entity.freezed.dart';

@freezed
abstract class AuthSessionEntity with _$AuthSessionEntity {
  const factory AuthSessionEntity({
    required AuthTokensEntity tokens,

    /// User can be null when restoring a session from tokens only.
    ///
    /// On app start, the app may restore tokens from secure storage and then
    /// hydrate the user via `GET /v1/users/me`.
    UserEntity? user,
  }) = _AuthSessionEntity;
}
