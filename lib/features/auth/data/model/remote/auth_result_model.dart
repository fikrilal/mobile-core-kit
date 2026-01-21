import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/user/data/model/remote/user_model.dart';

part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

/// Auth result payload returned by backend-core-kit.
///
/// API convention: the backend returns `{ "data": <payload> }`, and [ApiHelper]
/// extracts the inner `<payload>` for [fromJson].
@freezed
abstract class AuthResultModel with _$AuthResultModel {
  const factory AuthResultModel({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResultModel;

  const AuthResultModel._();

  factory AuthResultModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResultModelFromJson(json);
}

extension AuthResultModelX on AuthResultModel {
  static const int _unknownExpiresInSeconds = 0;

  AuthSessionEntity toSessionEntity() => AuthSessionEntity(
    tokens: toTokensEntity(),
    user: user.toEntity(),
  );

  AuthTokensEntity toTokensEntity() => AuthTokensEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: 'Bearer',

    // Backend contract does not provide expiresIn; Phase 2.2 will derive expiry
    // deterministically from JWT `exp`.
    expiresIn: _unknownExpiresInSeconds,
    expiresAt: null,
  );
}
