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
    /// This is computed client-side from the JWT `exp` claim when available,
    /// and may fall back to `expiresIn` in legacy paths.
    ///
    /// It can be null for legacy/restored sessions or when expiry cannot be
    /// derived (fail-safe: no preflight refresh; rely on 401 refresh).
    DateTime? expiresAt,
  }) = _AuthTokensEntity;
}
