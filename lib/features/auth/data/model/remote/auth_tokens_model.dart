import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';

part 'auth_tokens_model.freezed.dart';
part 'auth_tokens_model.g.dart';

@freezed
abstract class AuthTokensModel with _$AuthTokensModel {
  const factory AuthTokensModel({
    required String accessToken,
    required String refreshToken,
    @Default('Bearer') String tokenType,
    required int expiresIn,
  }) = _AuthTokensModel;

  const AuthTokensModel._();

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  AuthTokensEntity toEntity() => AuthTokensEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
  );
}
