import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/user/model/remote/me_model.dart';
import 'package:mobile_core_kit/core/utilities/jwt_utils.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Auth response payload returned by backend-core-kit for auth endpoints that
/// include the full `/v1/me` payload (hydrated user).
///
/// Source: `AuthResultWithMeDto` in `backend-core-kit` OpenAPI
/// (`POST /v1/auth/password/register`, `POST /v1/auth/password/login`,
/// `POST /v1/auth/oidc/exchange`).
@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required MeModel user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponseModel;

  const AuthResponseModel._();

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
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
