// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeSessionModel _$MeSessionModelFromJson(Map<String, dynamic> json) =>
    _MeSessionModel(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      ip: json['ip'] as String?,
      userAgent: json['userAgent'] as String?,
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      current: json['current'] as bool,
      status: $enumDecode(_$MeSessionStatusModelEnumMap, json['status']),
    );

Map<String, dynamic> _$MeSessionModelToJson(_MeSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceId': ?instance.deviceId,
      'deviceName': ?instance.deviceName,
      'ip': ?instance.ip,
      'userAgent': ?instance.userAgent,
      'lastSeenAt': instance.lastSeenAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'revokedAt': ?instance.revokedAt?.toIso8601String(),
      'current': instance.current,
      'status': _$MeSessionStatusModelEnumMap[instance.status]!,
    };

const _$MeSessionStatusModelEnumMap = {
  MeSessionStatusModel.active: 'active',
  MeSessionStatusModel.revoked: 'revoked',
  MeSessionStatusModel.expired: 'expired',
};
