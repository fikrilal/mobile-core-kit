// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RefreshResponseModel _$RefreshResponseModelFromJson(
  Map<String, dynamic> json,
) => _RefreshResponseModel(
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
);

Map<String, dynamic> _$RefreshResponseModelToJson(
  _RefreshResponseModel instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
};
