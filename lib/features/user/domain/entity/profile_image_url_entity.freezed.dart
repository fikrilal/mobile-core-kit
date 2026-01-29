// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_image_url_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileImageUrlEntity {

 String get url; DateTime get expiresAt;
/// Create a copy of ProfileImageUrlEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageUrlEntityCopyWith<ProfileImageUrlEntity> get copyWith => _$ProfileImageUrlEntityCopyWithImpl<ProfileImageUrlEntity>(this as ProfileImageUrlEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImageUrlEntity&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'ProfileImageUrlEntity(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ProfileImageUrlEntityCopyWith<$Res>  {
  factory $ProfileImageUrlEntityCopyWith(ProfileImageUrlEntity value, $Res Function(ProfileImageUrlEntity) _then) = _$ProfileImageUrlEntityCopyWithImpl;
@useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class _$ProfileImageUrlEntityCopyWithImpl<$Res>
    implements $ProfileImageUrlEntityCopyWith<$Res> {
  _$ProfileImageUrlEntityCopyWithImpl(this._self, this._then);

  final ProfileImageUrlEntity _self;
  final $Res Function(ProfileImageUrlEntity) _then;

/// Create a copy of ProfileImageUrlEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileImageUrlEntity].
extension ProfileImageUrlEntityPatterns on ProfileImageUrlEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImageUrlEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImageUrlEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImageUrlEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUrlEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImageUrlEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUrlEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImageUrlEntity() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUrlEntity():
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUrlEntity() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileImageUrlEntity implements ProfileImageUrlEntity {
  const _ProfileImageUrlEntity({required this.url, required this.expiresAt});
  

@override final  String url;
@override final  DateTime expiresAt;

/// Create a copy of ProfileImageUrlEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageUrlEntityCopyWith<_ProfileImageUrlEntity> get copyWith => __$ProfileImageUrlEntityCopyWithImpl<_ProfileImageUrlEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImageUrlEntity&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'ProfileImageUrlEntity(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageUrlEntityCopyWith<$Res> implements $ProfileImageUrlEntityCopyWith<$Res> {
  factory _$ProfileImageUrlEntityCopyWith(_ProfileImageUrlEntity value, $Res Function(_ProfileImageUrlEntity) _then) = __$ProfileImageUrlEntityCopyWithImpl;
@override @useResult
$Res call({
 String url, DateTime expiresAt
});




}
/// @nodoc
class __$ProfileImageUrlEntityCopyWithImpl<$Res>
    implements _$ProfileImageUrlEntityCopyWith<$Res> {
  __$ProfileImageUrlEntityCopyWithImpl(this._self, this._then);

  final _ProfileImageUrlEntity _self;
  final $Res Function(_ProfileImageUrlEntity) _then;

/// Create a copy of ProfileImageUrlEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_ProfileImageUrlEntity(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
