// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUserModel _$AuthUserModelFromJson(Map<String, dynamic> json) =>
    _AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      authMethods: (json['authMethods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AuthUserModelToJson(_AuthUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
      'authMethods': instance.authMethods,
    };
