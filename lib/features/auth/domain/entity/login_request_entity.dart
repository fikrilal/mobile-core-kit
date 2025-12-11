import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_entity.freezed.dart';

@freezed
abstract class LoginRequestEntity with _$LoginRequestEntity {
  const factory LoginRequestEntity({
    required String email,
    required String password,
  }) = _LoginRequestEntity;
}
