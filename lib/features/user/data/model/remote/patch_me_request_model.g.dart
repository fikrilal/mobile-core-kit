// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_me_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatchMeRequestModel _$PatchMeRequestModelFromJson(Map<String, dynamic> json) =>
    _PatchMeRequestModel(
      profile: PatchMeProfileModel.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PatchMeRequestModelToJson(
  _PatchMeRequestModel instance,
) => <String, dynamic>{'profile': instance.profile.toJson()};

_PatchMeProfileModel _$PatchMeProfileModelFromJson(Map<String, dynamic> json) =>
    _PatchMeProfileModel(
      displayName: json['displayName'] as String?,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
    );

Map<String, dynamic> _$PatchMeProfileModelToJson(
  _PatchMeProfileModel instance,
) => <String, dynamic>{
  'displayName': ?instance.displayName,
  'givenName': ?instance.givenName,
  'familyName': ?instance.familyName,
};
