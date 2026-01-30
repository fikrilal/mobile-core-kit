import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/foundation/utilities/jwt_utils.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/auth/data/model/remote/auth_user_model.dart';

part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

/// Auth result payload returned by backend-core-kit for token refresh.
///
/// API convention: the backend returns `{ "data": <payload> }`, and [ApiHelper]
/// extracts the inner `<payload>` for [fromJson].
///
/// Source: `AuthResultDto` in `backend-core-kit` OpenAPI (`POST /v1/auth/refresh`).
@freezed
abstract class AuthResultModel with _$AuthResultModel {
  const factory AuthResultModel({
    required AuthUserModel user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResultModel;

  const AuthResultModel._();

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);
}

extension AuthResultModelX on AuthResultModel {
  AuthSessionEntity toSessionEntity() =>
      AuthSessionEntity(tokens: toTokensEntity(), user: user.toEntity());

  AuthTokensEntity toTokensEntity() {
    final expiry = JwtUtils.tryComputeExpiry(accessToken);

    return AuthTokensEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: 'Bearer',
      expiresIn: expiry?.expiresIn ?? 0,
      expiresAt: expiry?.expiresAt,
    );
  }
}
