// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PasswordResetConfirmRequestModel _$PasswordResetConfirmRequestModelFromJson(
  Map<String, dynamic> json,
) => _PasswordResetConfirmRequestModel(
  token: json['token'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmRequestModelToJson(
  _PasswordResetConfirmRequestModel instance,
) => <String, dynamic>{
  'token': instance.token,
  'newPassword': instance.newPassword,
};
