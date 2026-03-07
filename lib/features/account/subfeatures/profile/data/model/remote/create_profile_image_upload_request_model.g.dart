// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_profile_image_upload_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateProfileImageUploadRequestModel
_$CreateProfileImageUploadRequestModelFromJson(Map<String, dynamic> json) =>
    _CreateProfileImageUploadRequestModel(
      contentType: json['contentType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
    );

Map<String, dynamic> _$CreateProfileImageUploadRequestModelToJson(
  _CreateProfileImageUploadRequestModel instance,
) => <String, dynamic>{
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
};
