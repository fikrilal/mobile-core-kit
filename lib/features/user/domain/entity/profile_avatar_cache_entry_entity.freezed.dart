// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_avatar_cache_entry_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileAvatarCacheEntryEntity {

 String get filePath; DateTime get cachedAt; bool get isExpired;
/// Create a copy of ProfileAvatarCacheEntryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileAvatarCacheEntryEntityCopyWith<ProfileAvatarCacheEntryEntity> get copyWith => _$ProfileAvatarCacheEntryEntityCopyWithImpl<ProfileAvatarCacheEntryEntity>(this as ProfileAvatarCacheEntryEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileAvatarCacheEntryEntity&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,cachedAt,isExpired);

@override
String toString() {
  return 'ProfileAvatarCacheEntryEntity(filePath: $filePath, cachedAt: $cachedAt, isExpired: $isExpired)';
}


}

/// @nodoc
abstract mixin class $ProfileAvatarCacheEntryEntityCopyWith<$Res>  {
  factory $ProfileAvatarCacheEntryEntityCopyWith(ProfileAvatarCacheEntryEntity value, $Res Function(ProfileAvatarCacheEntryEntity) _then) = _$ProfileAvatarCacheEntryEntityCopyWithImpl;
@useResult
$Res call({
 String filePath, DateTime cachedAt, bool isExpired
});




}
/// @nodoc
class _$ProfileAvatarCacheEntryEntityCopyWithImpl<$Res>
    implements $ProfileAvatarCacheEntryEntityCopyWith<$Res> {
  _$ProfileAvatarCacheEntryEntityCopyWithImpl(this._self, this._then);

  final ProfileAvatarCacheEntryEntity _self;
  final $Res Function(ProfileAvatarCacheEntryEntity) _then;

/// Create a copy of ProfileAvatarCacheEntryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? cachedAt = null,Object? isExpired = null,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,cachedAt: null == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileAvatarCacheEntryEntity].
extension ProfileAvatarCacheEntryEntityPatterns on ProfileAvatarCacheEntryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileAvatarCacheEntryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileAvatarCacheEntryEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileAvatarCacheEntryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath,  DateTime cachedAt,  bool isExpired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity() when $default != null:
return $default(_that.filePath,_that.cachedAt,_that.isExpired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath,  DateTime cachedAt,  bool isExpired)  $default,) {final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity():
return $default(_that.filePath,_that.cachedAt,_that.isExpired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath,  DateTime cachedAt,  bool isExpired)?  $default,) {final _that = this;
switch (_that) {
case _ProfileAvatarCacheEntryEntity() when $default != null:
return $default(_that.filePath,_that.cachedAt,_that.isExpired);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileAvatarCacheEntryEntity implements ProfileAvatarCacheEntryEntity {
  const _ProfileAvatarCacheEntryEntity({required this.filePath, required this.cachedAt, required this.isExpired});
  

@override final  String filePath;
@override final  DateTime cachedAt;
@override final  bool isExpired;

/// Create a copy of ProfileAvatarCacheEntryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileAvatarCacheEntryEntityCopyWith<_ProfileAvatarCacheEntryEntity> get copyWith => __$ProfileAvatarCacheEntryEntityCopyWithImpl<_ProfileAvatarCacheEntryEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileAvatarCacheEntryEntity&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt)&&(identical(other.isExpired, isExpired) || other.isExpired == isExpired));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,cachedAt,isExpired);

@override
String toString() {
  return 'ProfileAvatarCacheEntryEntity(filePath: $filePath, cachedAt: $cachedAt, isExpired: $isExpired)';
}


}

/// @nodoc
abstract mixin class _$ProfileAvatarCacheEntryEntityCopyWith<$Res> implements $ProfileAvatarCacheEntryEntityCopyWith<$Res> {
  factory _$ProfileAvatarCacheEntryEntityCopyWith(_ProfileAvatarCacheEntryEntity value, $Res Function(_ProfileAvatarCacheEntryEntity) _then) = __$ProfileAvatarCacheEntryEntityCopyWithImpl;
@override @useResult
$Res call({
 String filePath, DateTime cachedAt, bool isExpired
});




}
/// @nodoc
class __$ProfileAvatarCacheEntryEntityCopyWithImpl<$Res>
    implements _$ProfileAvatarCacheEntryEntityCopyWith<$Res> {
  __$ProfileAvatarCacheEntryEntityCopyWithImpl(this._self, this._then);

  final _ProfileAvatarCacheEntryEntity _self;
  final $Res Function(_ProfileAvatarCacheEntryEntity) _then;

/// Create a copy of ProfileAvatarCacheEntryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? cachedAt = null,Object? isExpired = null,}) {
  return _then(_ProfileAvatarCacheEntryEntity(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,cachedAt: null == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isExpired: null == isExpired ? _self.isExpired : isExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
