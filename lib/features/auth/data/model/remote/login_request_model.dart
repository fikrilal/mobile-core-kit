import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/features/auth/domain/entity/login_request_entity.dart';

part 'login_request_model.freezed.dart';
part 'login_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
abstract class LoginRequestModel with _$LoginRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory LoginRequestModel({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) = _LoginRequestModel;

  const LoginRequestModel._();

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  factory LoginRequestModel.fromEntity(LoginRequestEntity entity) {
    return LoginRequestModel(email: entity.email, password: entity.password);
  }
}
