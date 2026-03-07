// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_image_upload_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileImageUploadPlanModel _$ProfileImageUploadPlanModelFromJson(
  Map<String, dynamic> json,
) => _ProfileImageUploadPlanModel(
  fileId: json['fileId'] as String,
  upload: PresignedUploadModel.fromJson(json['upload'] as Map<String, dynamic>),
  expiresAt: json['expiresAt'] as String,
);

Map<String, dynamic> _$ProfileImageUploadPlanModelToJson(
  _ProfileImageUploadPlanModel instance,
) => <String, dynamic>{
  'fileId': instance.fileId,
  'upload': instance.upload.toJson(),
  'expiresAt': instance.expiresAt,
};

_PresignedUploadModel _$PresignedUploadModelFromJson(
  Map<String, dynamic> json,
) => _PresignedUploadModel(
  method: json['method'] as String,
  url: json['url'] as String,
  headers: _headersFromJson(json['headers'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PresignedUploadModelToJson(
  _PresignedUploadModel instance,
) => <String, dynamic>{
  'method': instance.method,
  'url': instance.url,
  'headers': _headersToJson(instance.headers),
};
