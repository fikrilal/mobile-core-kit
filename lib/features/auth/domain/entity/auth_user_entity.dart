import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_entity.freezed.dart';

@freezed
abstract class AuthUserEntity with _$AuthUserEntity {
  const factory AuthUserEntity({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    required bool emailVerified,
  }) = _AuthUserEntity;
}

