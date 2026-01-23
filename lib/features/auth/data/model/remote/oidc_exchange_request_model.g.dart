// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_exchange_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OidcExchangeRequestModel _$OidcExchangeRequestModelFromJson(
  Map<String, dynamic> json,
) => _OidcExchangeRequestModel(
  provider: json['provider'] as String,
  idToken: json['idToken'] as String,
  deviceId: json['deviceId'] as String?,
  deviceName: json['deviceName'] as String?,
);

Map<String, dynamic> _$OidcExchangeRequestModelToJson(
  _OidcExchangeRequestModel instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'idToken': instance.idToken,
  'deviceId': ?instance.deviceId,
  'deviceName': ?instance.deviceName,
};
