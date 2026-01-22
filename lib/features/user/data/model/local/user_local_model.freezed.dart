// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_local_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserLocalModel {

 String? get id; String? get email; bool? get emailVerified; String? get rolesJson; String? get authMethodsJson; String? get profileImageFileId; String? get displayName; String? get givenName; String? get familyName; String? get accountDeletionRequestedAt; String? get accountDeletionScheduledFor;
/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLocalModelCopyWith<UserLocalModel> get copyWith => _$UserLocalModelCopyWithImpl<UserLocalModel>(this as UserLocalModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLocalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.rolesJson, rolesJson) || other.rolesJson == rolesJson)&&(identical(other.authMethodsJson, authMethodsJson) || other.authMethodsJson == authMethodsJson)&&(identical(other.profileImageFileId, profileImageFileId) || other.profileImageFileId == profileImageFileId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.accountDeletionRequestedAt, accountDeletionRequestedAt) || other.accountDeletionRequestedAt == accountDeletionRequestedAt)&&(identical(other.accountDeletionScheduledFor, accountDeletionScheduledFor) || other.accountDeletionScheduledFor == accountDeletionScheduledFor));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,rolesJson,authMethodsJson,profileImageFileId,displayName,givenName,familyName,accountDeletionRequestedAt,accountDeletionScheduledFor);

@override
String toString() {
  return 'UserLocalModel(id: $id, email: $email, emailVerified: $emailVerified, rolesJson: $rolesJson, authMethodsJson: $authMethodsJson, profileImageFileId: $profileImageFileId, displayName: $displayName, givenName: $givenName, familyName: $familyName, accountDeletionRequestedAt: $accountDeletionRequestedAt, accountDeletionScheduledFor: $accountDeletionScheduledFor)';
}


}

/// @nodoc
abstract mixin class $UserLocalModelCopyWith<$Res>  {
  factory $UserLocalModelCopyWith(UserLocalModel value, $Res Function(UserLocalModel) _then) = _$UserLocalModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? email, bool? emailVerified, String? rolesJson, String? authMethodsJson, String? profileImageFileId, String? displayName, String? givenName, String? familyName, String? accountDeletionRequestedAt, String? accountDeletionScheduledFor
});




}
/// @nodoc
class _$UserLocalModelCopyWithImpl<$Res>
    implements $UserLocalModelCopyWith<$Res> {
  _$UserLocalModelCopyWithImpl(this._self, this._then);

  final UserLocalModel _self;
  final $Res Function(UserLocalModel) _then;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? emailVerified = freezed,Object? rolesJson = freezed,Object? authMethodsJson = freezed,Object? profileImageFileId = freezed,Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,Object? accountDeletionRequestedAt = freezed,Object? accountDeletionScheduledFor = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,rolesJson: freezed == rolesJson ? _self.rolesJson : rolesJson // ignore: cast_nullable_to_non_nullable
as String?,authMethodsJson: freezed == authMethodsJson ? _self.authMethodsJson : authMethodsJson // ignore: cast_nullable_to_non_nullable
as String?,profileImageFileId: freezed == profileImageFileId ? _self.profileImageFileId : profileImageFileId // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,accountDeletionRequestedAt: freezed == accountDeletionRequestedAt ? _self.accountDeletionRequestedAt : accountDeletionRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,accountDeletionScheduledFor: freezed == accountDeletionScheduledFor ? _self.accountDeletionScheduledFor : accountDeletionScheduledFor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLocalModel].
extension UserLocalModelPatterns on UserLocalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLocalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLocalModel value)  $default,){
final _that = this;
switch (_that) {
case _UserLocalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLocalModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? email,  bool? emailVerified,  String? rolesJson,  String? authMethodsJson,  String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName,  String? accountDeletionRequestedAt,  String? accountDeletionScheduledFor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.rolesJson,_that.authMethodsJson,_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName,_that.accountDeletionRequestedAt,_that.accountDeletionScheduledFor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? email,  bool? emailVerified,  String? rolesJson,  String? authMethodsJson,  String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName,  String? accountDeletionRequestedAt,  String? accountDeletionScheduledFor)  $default,) {final _that = this;
switch (_that) {
case _UserLocalModel():
return $default(_that.id,_that.email,_that.emailVerified,_that.rolesJson,_that.authMethodsJson,_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName,_that.accountDeletionRequestedAt,_that.accountDeletionScheduledFor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? email,  bool? emailVerified,  String? rolesJson,  String? authMethodsJson,  String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName,  String? accountDeletionRequestedAt,  String? accountDeletionScheduledFor)?  $default,) {final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.rolesJson,_that.authMethodsJson,_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName,_that.accountDeletionRequestedAt,_that.accountDeletionScheduledFor);case _:
  return null;

}
}

}

/// @nodoc


class _UserLocalModel extends UserLocalModel {
  const _UserLocalModel({this.id, this.email, this.emailVerified, this.rolesJson, this.authMethodsJson, this.profileImageFileId, this.displayName, this.givenName, this.familyName, this.accountDeletionRequestedAt, this.accountDeletionScheduledFor}): super._();
  

@override final  String? id;
@override final  String? email;
@override final  bool? emailVerified;
@override final  String? rolesJson;
@override final  String? authMethodsJson;
@override final  String? profileImageFileId;
@override final  String? displayName;
@override final  String? givenName;
@override final  String? familyName;
@override final  String? accountDeletionRequestedAt;
@override final  String? accountDeletionScheduledFor;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLocalModelCopyWith<_UserLocalModel> get copyWith => __$UserLocalModelCopyWithImpl<_UserLocalModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLocalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.rolesJson, rolesJson) || other.rolesJson == rolesJson)&&(identical(other.authMethodsJson, authMethodsJson) || other.authMethodsJson == authMethodsJson)&&(identical(other.profileImageFileId, profileImageFileId) || other.profileImageFileId == profileImageFileId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.accountDeletionRequestedAt, accountDeletionRequestedAt) || other.accountDeletionRequestedAt == accountDeletionRequestedAt)&&(identical(other.accountDeletionScheduledFor, accountDeletionScheduledFor) || other.accountDeletionScheduledFor == accountDeletionScheduledFor));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,rolesJson,authMethodsJson,profileImageFileId,displayName,givenName,familyName,accountDeletionRequestedAt,accountDeletionScheduledFor);

@override
String toString() {
  return 'UserLocalModel(id: $id, email: $email, emailVerified: $emailVerified, rolesJson: $rolesJson, authMethodsJson: $authMethodsJson, profileImageFileId: $profileImageFileId, displayName: $displayName, givenName: $givenName, familyName: $familyName, accountDeletionRequestedAt: $accountDeletionRequestedAt, accountDeletionScheduledFor: $accountDeletionScheduledFor)';
}


}

/// @nodoc
abstract mixin class _$UserLocalModelCopyWith<$Res> implements $UserLocalModelCopyWith<$Res> {
  factory _$UserLocalModelCopyWith(_UserLocalModel value, $Res Function(_UserLocalModel) _then) = __$UserLocalModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? email, bool? emailVerified, String? rolesJson, String? authMethodsJson, String? profileImageFileId, String? displayName, String? givenName, String? familyName, String? accountDeletionRequestedAt, String? accountDeletionScheduledFor
});




}
/// @nodoc
class __$UserLocalModelCopyWithImpl<$Res>
    implements _$UserLocalModelCopyWith<$Res> {
  __$UserLocalModelCopyWithImpl(this._self, this._then);

  final _UserLocalModel _self;
  final $Res Function(_UserLocalModel) _then;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? emailVerified = freezed,Object? rolesJson = freezed,Object? authMethodsJson = freezed,Object? profileImageFileId = freezed,Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,Object? accountDeletionRequestedAt = freezed,Object? accountDeletionScheduledFor = freezed,}) {
  return _then(_UserLocalModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,rolesJson: freezed == rolesJson ? _self.rolesJson : rolesJson // ignore: cast_nullable_to_non_nullable
as String?,authMethodsJson: freezed == authMethodsJson ? _self.authMethodsJson : authMethodsJson // ignore: cast_nullable_to_non_nullable
as String?,profileImageFileId: freezed == profileImageFileId ? _self.profileImageFileId : profileImageFileId // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,accountDeletionRequestedAt: freezed == accountDeletionRequestedAt ? _self.accountDeletionRequestedAt : accountDeletionRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,accountDeletionScheduledFor: freezed == accountDeletionScheduledFor ? _self.accountDeletionScheduledFor : accountDeletionScheduledFor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
