import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens_entity.freezed.dart';

@freezed
abstract class AuthTokensEntity with _$AuthTokensEntity {
  const factory AuthTokensEntity({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) = _AuthTokensEntity;
}

