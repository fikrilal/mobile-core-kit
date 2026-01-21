import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/features/auth/domain/entity/register_request_entity.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    required String email,
    required String password,
  }) = _RegisterRequestModel;

  const RegisterRequestModel._();

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  factory RegisterRequestModel.fromEntity(RegisterRequestEntity entity) {
    return RegisterRequestModel(
      email: entity.email,
      password: entity.password,
    );
  }
}
