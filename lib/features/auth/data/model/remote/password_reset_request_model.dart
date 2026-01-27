import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/password_reset_request_entity.dart';

part 'password_reset_request_model.freezed.dart';
part 'password_reset_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
abstract class PasswordResetRequestModel with _$PasswordResetRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory PasswordResetRequestModel({required String email}) =
      _PasswordResetRequestModel;

  const PasswordResetRequestModel._();

  factory PasswordResetRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestModelFromJson(json);

  factory PasswordResetRequestModel.fromEntity(
    PasswordResetRequestEntity entity,
  ) => PasswordResetRequestModel(email: entity.email);
}
