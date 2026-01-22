// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => _RegisterRequestModel(
  email: json['email'] as String,
  password: json['password'] as String,
  deviceId: json['deviceId'] as String?,
  deviceName: json['deviceName'] as String?,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  _RegisterRequestModel instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'deviceId': ?instance.deviceId,
  'deviceName': ?instance.deviceName,
};
