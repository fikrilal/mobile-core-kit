import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/auth_session_entity.dart';
import 'auth_tokens_model.dart';
import '../../../../user/data/model/remote/user_model.dart';

part 'auth_session_model.freezed.dart';
part 'auth_session_model.g.dart';

/// Auth session payload (tokens + user profile).
///
/// API convention: the backend returns `{ "data": <payload> }`.
@freezed
abstract class AuthSessionModel with _$AuthSessionModel {
  const factory AuthSessionModel({
    required AuthTokensModel tokens,
    required UserModel user,
  }) = _AuthSessionModel;

  const AuthSessionModel._();

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);
}

extension AuthSessionModelX on AuthSessionModel {
  AuthSessionEntity toEntity() => AuthSessionEntity(
        tokens: tokens.toEntity(),
        user: user.toEntity(),
      );
}
