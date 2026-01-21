// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResultModel _$AuthResultModelFromJson(Map<String, dynamic> json) =>
    _AuthResultModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$AuthResultModelToJson(_AuthResultModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
