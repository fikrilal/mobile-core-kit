import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/login_request_entity.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

@freezed
abstract class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({
    required String email,
    required String password,
  }) = _LoginRequestModel;

  const LoginRequestModel._();

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  factory LoginRequestModel.fromEntity(LoginRequestEntity entity) {
    return LoginRequestModel(email: entity.email, password: entity.password);
  }
}
