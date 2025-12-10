// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => _RegisterRequestModel(
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  timezone: json['timezone'] as String,
  profileVisibility: json['profileVisibility'] as String,
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  _RegisterRequestModel instance,
) => <String, dynamic>{
  'displayName': instance.displayName,
  'email': instance.email,
  'password': instance.password,
  'timezone': instance.timezone,
  'profileVisibility': instance.profileVisibility,
};
