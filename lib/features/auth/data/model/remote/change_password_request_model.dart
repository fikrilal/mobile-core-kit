import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/change_password_request_entity.dart';

part 'change_password_request_model.freezed.dart';
part 'change_password_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
abstract class ChangePasswordRequestModel with _$ChangePasswordRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory ChangePasswordRequestModel({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequestModel;

  const ChangePasswordRequestModel._();

  factory ChangePasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestModelFromJson(json);

  factory ChangePasswordRequestModel.fromEntity(ChangePasswordRequestEntity e) {
    return ChangePasswordRequestModel(
      currentPassword: e.currentPassword,
      newPassword: e.newPassword,
    );
  }
}
