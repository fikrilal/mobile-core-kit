// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeModel _$MeModelFromJson(Map<String, dynamic> json) => _MeModel(
  id: json['id'] as String,
  email: json['email'] as String,
  emailVerified: json['emailVerified'] as bool,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  authMethods: (json['authMethods'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  profile: MeProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
  accountDeletion: json['accountDeletion'] == null
      ? null
      : AccountDeletionModel.fromJson(
          json['accountDeletion'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MeModelToJson(_MeModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'roles': instance.roles,
  'authMethods': instance.authMethods,
  'profile': instance.profile,
  'accountDeletion': instance.accountDeletion,
};

_MeProfileModel _$MeProfileModelFromJson(Map<String, dynamic> json) =>
    _MeProfileModel(
      profileImageFileId: json['profileImageFileId'] as String?,
      displayName: json['displayName'] as String?,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
    );

Map<String, dynamic> _$MeProfileModelToJson(_MeProfileModel instance) =>
    <String, dynamic>{
      'profileImageFileId': instance.profileImageFileId,
      'displayName': instance.displayName,
      'givenName': instance.givenName,
      'familyName': instance.familyName,
    };

_AccountDeletionModel _$AccountDeletionModelFromJson(
  Map<String, dynamic> json,
) => _AccountDeletionModel(
  requestedAt: json['requestedAt'] as String,
  scheduledFor: json['scheduledFor'] as String,
);

Map<String, dynamic> _$AccountDeletionModelToJson(
  _AccountDeletionModel instance,
) => <String, dynamic>{
  'requestedAt': instance.requestedAt,
  'scheduledFor': instance.scheduledFor,
};
