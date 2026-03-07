// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_draft_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileDraftEntity {

/// Schema version of this draft payload (for forward-compatible evolution).
 int get schemaVersion;/// Given name input (can be invalid/untrimmed while user is typing).
 String get givenName;/// Optional family name input (can be invalid/untrimmed while user is typing).
 String? get familyName;/// Optional display name input (may be enabled by some products).
 String? get displayName;/// When this draft was last updated (for TTL/cleanup).
 DateTime get updatedAt;
/// Create a copy of ProfileDraftEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDraftEntityCopyWith<ProfileDraftEntity> get copyWith => _$ProfileDraftEntityCopyWithImpl<ProfileDraftEntity>(this as ProfileDraftEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDraftEntity&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,givenName,familyName,displayName,updatedAt);

@override
String toString() {
  return 'ProfileDraftEntity(schemaVersion: $schemaVersion, givenName: $givenName, familyName: $familyName, displayName: $displayName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileDraftEntityCopyWith<$Res>  {
  factory $ProfileDraftEntityCopyWith(ProfileDraftEntity value, $Res Function(ProfileDraftEntity) _then) = _$ProfileDraftEntityCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String givenName, String? familyName, String? displayName, DateTime updatedAt
});




}
/// @nodoc
class _$ProfileDraftEntityCopyWithImpl<$Res>
    implements $ProfileDraftEntityCopyWith<$Res> {
  _$ProfileDraftEntityCopyWithImpl(this._self, this._then);

  final ProfileDraftEntity _self;
  final $Res Function(ProfileDraftEntity) _then;

/// Create a copy of ProfileDraftEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? givenName = null,Object? familyName = freezed,Object? displayName = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDraftEntity].
extension ProfileDraftEntityPatterns on ProfileDraftEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDraftEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDraftEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDraftEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDraftEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDraftEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDraftEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String givenName,  String? familyName,  String? displayName,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDraftEntity() when $default != null:
return $default(_that.schemaVersion,_that.givenName,_that.familyName,_that.displayName,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String givenName,  String? familyName,  String? displayName,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileDraftEntity():
return $default(_that.schemaVersion,_that.givenName,_that.familyName,_that.displayName,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String givenName,  String? familyName,  String? displayName,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDraftEntity() when $default != null:
return $default(_that.schemaVersion,_that.givenName,_that.familyName,_that.displayName,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileDraftEntity implements ProfileDraftEntity {
  const _ProfileDraftEntity({this.schemaVersion = 1, required this.givenName, this.familyName, this.displayName, required this.updatedAt});
  

/// Schema version of this draft payload (for forward-compatible evolution).
@override@JsonKey() final  int schemaVersion;
/// Given name input (can be invalid/untrimmed while user is typing).
@override final  String givenName;
/// Optional family name input (can be invalid/untrimmed while user is typing).
@override final  String? familyName;
/// Optional display name input (may be enabled by some products).
@override final  String? displayName;
/// When this draft was last updated (for TTL/cleanup).
@override final  DateTime updatedAt;

/// Create a copy of ProfileDraftEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDraftEntityCopyWith<_ProfileDraftEntity> get copyWith => __$ProfileDraftEntityCopyWithImpl<_ProfileDraftEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDraftEntity&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,schemaVersion,givenName,familyName,displayName,updatedAt);

@override
String toString() {
  return 'ProfileDraftEntity(schemaVersion: $schemaVersion, givenName: $givenName, familyName: $familyName, displayName: $displayName, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileDraftEntityCopyWith<$Res> implements $ProfileDraftEntityCopyWith<$Res> {
  factory _$ProfileDraftEntityCopyWith(_ProfileDraftEntity value, $Res Function(_ProfileDraftEntity) _then) = __$ProfileDraftEntityCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String givenName, String? familyName, String? displayName, DateTime updatedAt
});




}
/// @nodoc
class __$ProfileDraftEntityCopyWithImpl<$Res>
    implements _$ProfileDraftEntityCopyWith<$Res> {
  __$ProfileDraftEntityCopyWithImpl(this._self, this._then);

  final _ProfileDraftEntity _self;
  final $Res Function(_ProfileDraftEntity) _then;

/// Create a copy of ProfileDraftEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? givenName = null,Object? familyName = freezed,Object? displayName = freezed,Object? updatedAt = null,}) {
  return _then(_ProfileDraftEntity(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
