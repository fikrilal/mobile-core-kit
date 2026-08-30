import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/auth/domain/value/password_reset_credentials.dart';

part 'password_reset_confirm_request_model.freezed.dart';
part 'password_reset_confirm_request_model.g.dart';

// ignore_for_file: invalid_annotation_target

@freezed
abstract class PasswordResetConfirmRequestModel
    with _$PasswordResetConfirmRequestModel {
  @JsonSerializable(includeIfNull: false)
  const factory PasswordResetConfirmRequestModel({
    required String token,
    required String newPassword,
  }) = _PasswordResetConfirmRequestModel;

  const PasswordResetConfirmRequestModel._();

  factory PasswordResetConfirmRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PasswordResetConfirmRequestModelFromJson(json);

  factory PasswordResetConfirmRequestModel.fromCredentials(
    PasswordResetCredentials credentials,
  ) => PasswordResetConfirmRequestModel(
    token: credentials.token.value,
    newPassword: credentials.newPassword.value,
  );
}
