import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens_entity.freezed.dart';

@freezed
abstract class AuthTokensEntity with _$AuthTokensEntity {
  const factory AuthTokensEntity({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    /// When the access token is expected to expire.
    ///
    /// This is computed client-side using `expiresIn` at the time tokens are
    /// received/persisted. It can be null for legacy/restored sessions that
    /// were persisted before this field existed.
    DateTime? expiresAt,
  }) = _AuthTokensEntity;
}
