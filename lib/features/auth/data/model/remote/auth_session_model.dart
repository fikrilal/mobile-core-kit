import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/auth_session_entity.dart';
import '../../../domain/entity/auth_tokens_entity.dart';
import '../../../../user/data/model/remote/user_model.dart';

part 'auth_session_model.freezed.dart';
part 'auth_session_model.g.dart';

/// Auth session response (tokens + user profile).
///
/// This matches `/auth/password/login` on the reference backend:
/// {
///   "data": {
///     "tokens": {
///       "accessToken": "...",
///       "refreshToken": "...",
///       "tokenType": "Bearer",
///       "expiresIn": 900
///     },
///     "user": {
///       "id": "...",
///       "email": "...",
///       "firstName": "...",
///       "lastName": "...",
///       "emailVerified": true
///     }
///   }
/// }
@freezed
abstract class AuthSessionModel with _$AuthSessionModel {
  const factory AuthSessionModel({
    required AuthSessionDataModel data,
  }) = _AuthSessionModel;

  const AuthSessionModel._();

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);
}

@freezed
abstract class AuthSessionDataModel with _$AuthSessionDataModel {
  const factory AuthSessionDataModel({
    required AuthTokensModel tokens,
    required UserModel user,
  }) = _AuthSessionDataModel;

  factory AuthSessionDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionDataModelFromJson(json);
}

@freezed
abstract class AuthTokensModel with _$AuthTokensModel {
  const factory AuthTokensModel({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) = _AuthTokensModel;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  const AuthTokensModel._();

  AuthTokensEntity toEntity() => AuthTokensEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      );
}

extension AuthSessionModelX on AuthSessionModel {
  AuthSessionEntity toEntity() => AuthSessionEntity(
        tokens: data.tokens.toEntity(),
        user: data.user.toEntity(),
      );
}
