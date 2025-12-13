import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_tokens_entity.dart';
import 'auth_user_entity.dart';

part 'auth_session_entity.freezed.dart';

@freezed
abstract class AuthSessionEntity with _$AuthSessionEntity {
  const factory AuthSessionEntity({
    required AuthTokensEntity tokens,
    required AuthUserEntity user,
  }) = _AuthSessionEntity;
}

