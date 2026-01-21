// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserEntity {

 String get id; String get email;/// Whether the user's email address has been verified.
///
/// Backend source: `AuthUserDto.emailVerified`, `MeDto.emailVerified`.
 bool get emailVerified;/// Authorization roles for the current user (RBAC).
///
/// Backend source: `MeDto.roles`.
 List<String> get roles;/// Linked authentication methods on this account.
///
/// Backend source: `MeDto.authMethods` and (optionally) `AuthUserDto.authMethods`.
 List<String> get authMethods;/// User profile information (`/v1/me.profile`).
///
/// This may be incomplete for newly registered users (progressive profiling).
 UserProfileEntity get profile;/// When present, the account is scheduled for deletion.
///
/// Backend source: `MeDto.accountDeletion`.
 AccountDeletionEntity? get accountDeletion;
/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserEntityCopyWith<UserEntity> get copyWith => _$UserEntityCopyWithImpl<UserEntity>(this as UserEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.authMethods, authMethods)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.accountDeletion, accountDeletion) || other.accountDeletion == accountDeletion));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(authMethods),profile,accountDeletion);

@override
String toString() {
  return 'UserEntity(id: $id, email: $email, emailVerified: $emailVerified, roles: $roles, authMethods: $authMethods, profile: $profile, accountDeletion: $accountDeletion)';
}


}

/// @nodoc
abstract mixin class $UserEntityCopyWith<$Res>  {
  factory $UserEntityCopyWith(UserEntity value, $Res Function(UserEntity) _then) = _$UserEntityCopyWithImpl;
@useResult
$Res call({
 String id, String email, bool emailVerified, List<String> roles, List<String> authMethods, UserProfileEntity profile, AccountDeletionEntity? accountDeletion
});


$UserProfileEntityCopyWith<$Res> get profile;$AccountDeletionEntityCopyWith<$Res>? get accountDeletion;

}
/// @nodoc
class _$UserEntityCopyWithImpl<$Res>
    implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._self, this._then);

  final UserEntity _self;
  final $Res Function(UserEntity) _then;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? roles = null,Object? authMethods = null,Object? profile = null,Object? accountDeletion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,authMethods: null == authMethods ? _self.authMethods : authMethods // ignore: cast_nullable_to_non_nullable
as List<String>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfileEntity,accountDeletion: freezed == accountDeletion ? _self.accountDeletion : accountDeletion // ignore: cast_nullable_to_non_nullable
as AccountDeletionEntity?,
  ));
}
/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileEntityCopyWith<$Res> get profile {
  
  return $UserProfileEntityCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountDeletionEntityCopyWith<$Res>? get accountDeletion {
    if (_self.accountDeletion == null) {
    return null;
  }

  return $AccountDeletionEntityCopyWith<$Res>(_self.accountDeletion!, (value) {
    return _then(_self.copyWith(accountDeletion: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserEntity].
extension UserEntityPatterns on UserEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserEntity value)  $default,){
final _that = this;
switch (_that) {
case _UserEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  UserProfileEntity profile,  AccountDeletionEntity? accountDeletion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  UserProfileEntity profile,  AccountDeletionEntity? accountDeletion)  $default,) {final _that = this;
switch (_that) {
case _UserEntity():
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  UserProfileEntity profile,  AccountDeletionEntity? accountDeletion)?  $default,) {final _that = this;
switch (_that) {
case _UserEntity() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
  return null;

}
}

}

/// @nodoc


class _UserEntity implements UserEntity {
  const _UserEntity({required this.id, required this.email, this.emailVerified = false, final  List<String> roles = const <String>[], final  List<String> authMethods = const <String>[], this.profile = const UserProfileEntity(), this.accountDeletion}): _roles = roles,_authMethods = authMethods;
  

@override final  String id;
@override final  String email;
/// Whether the user's email address has been verified.
///
/// Backend source: `AuthUserDto.emailVerified`, `MeDto.emailVerified`.
@override@JsonKey() final  bool emailVerified;
/// Authorization roles for the current user (RBAC).
///
/// Backend source: `MeDto.roles`.
 final  List<String> _roles;
/// Authorization roles for the current user (RBAC).
///
/// Backend source: `MeDto.roles`.
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

/// Linked authentication methods on this account.
///
/// Backend source: `MeDto.authMethods` and (optionally) `AuthUserDto.authMethods`.
 final  List<String> _authMethods;
/// Linked authentication methods on this account.
///
/// Backend source: `MeDto.authMethods` and (optionally) `AuthUserDto.authMethods`.
@override@JsonKey() List<String> get authMethods {
  if (_authMethods is EqualUnmodifiableListView) return _authMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authMethods);
}

/// User profile information (`/v1/me.profile`).
///
/// This may be incomplete for newly registered users (progressive profiling).
@override@JsonKey() final  UserProfileEntity profile;
/// When present, the account is scheduled for deletion.
///
/// Backend source: `MeDto.accountDeletion`.
@override final  AccountDeletionEntity? accountDeletion;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserEntityCopyWith<_UserEntity> get copyWith => __$UserEntityCopyWithImpl<_UserEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._authMethods, _authMethods)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.accountDeletion, accountDeletion) || other.accountDeletion == accountDeletion));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_authMethods),profile,accountDeletion);

@override
String toString() {
  return 'UserEntity(id: $id, email: $email, emailVerified: $emailVerified, roles: $roles, authMethods: $authMethods, profile: $profile, accountDeletion: $accountDeletion)';
}


}

/// @nodoc
abstract mixin class _$UserEntityCopyWith<$Res> implements $UserEntityCopyWith<$Res> {
  factory _$UserEntityCopyWith(_UserEntity value, $Res Function(_UserEntity) _then) = __$UserEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, bool emailVerified, List<String> roles, List<String> authMethods, UserProfileEntity profile, AccountDeletionEntity? accountDeletion
});


@override $UserProfileEntityCopyWith<$Res> get profile;@override $AccountDeletionEntityCopyWith<$Res>? get accountDeletion;

}
/// @nodoc
class __$UserEntityCopyWithImpl<$Res>
    implements _$UserEntityCopyWith<$Res> {
  __$UserEntityCopyWithImpl(this._self, this._then);

  final _UserEntity _self;
  final $Res Function(_UserEntity) _then;

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? roles = null,Object? authMethods = null,Object? profile = null,Object? accountDeletion = freezed,}) {
  return _then(_UserEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,authMethods: null == authMethods ? _self._authMethods : authMethods // ignore: cast_nullable_to_non_nullable
as List<String>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfileEntity,accountDeletion: freezed == accountDeletion ? _self.accountDeletion : accountDeletion // ignore: cast_nullable_to_non_nullable
as AccountDeletionEntity?,
  ));
}

/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileEntityCopyWith<$Res> get profile {
  
  return $UserProfileEntityCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountDeletionEntityCopyWith<$Res>? get accountDeletion {
    if (_self.accountDeletion == null) {
    return null;
  }

  return $AccountDeletionEntityCopyWith<$Res>(_self.accountDeletion!, (value) {
    return _then(_self.copyWith(accountDeletion: value));
  });
}
}

// dart format on
