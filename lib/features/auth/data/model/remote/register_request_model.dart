import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/register_request_entity.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    required String displayName,
    required String email,
    required String password,
    required String timezone,
    required String profileVisibility,
  }) = _RegisterRequestModel;

  const RegisterRequestModel._();

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  factory RegisterRequestModel.fromEntity(RegisterRequestEntity entity) {
    return RegisterRequestModel(
      displayName: entity.displayName,
      email: entity.email,
      password: entity.password,
      timezone: entity.timezone,
      profileVisibility: entity.profileVisibility,
    );
  }
}
