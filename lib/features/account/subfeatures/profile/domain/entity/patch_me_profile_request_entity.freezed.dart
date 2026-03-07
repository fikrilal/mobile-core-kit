// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patch_me_profile_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PatchMeProfileRequestEntity {

 String get givenName; String? get familyName; String? get displayName;
/// Create a copy of PatchMeProfileRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchMeProfileRequestEntityCopyWith<PatchMeProfileRequestEntity> get copyWith => _$PatchMeProfileRequestEntityCopyWithImpl<PatchMeProfileRequestEntity>(this as PatchMeProfileRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchMeProfileRequestEntity&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,displayName);

@override
String toString() {
  return 'PatchMeProfileRequestEntity(givenName: $givenName, familyName: $familyName, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $PatchMeProfileRequestEntityCopyWith<$Res>  {
  factory $PatchMeProfileRequestEntityCopyWith(PatchMeProfileRequestEntity value, $Res Function(PatchMeProfileRequestEntity) _then) = _$PatchMeProfileRequestEntityCopyWithImpl;
@useResult
$Res call({
 String givenName, String? familyName, String? displayName
});




}
/// @nodoc
class _$PatchMeProfileRequestEntityCopyWithImpl<$Res>
    implements $PatchMeProfileRequestEntityCopyWith<$Res> {
  _$PatchMeProfileRequestEntityCopyWithImpl(this._self, this._then);

  final PatchMeProfileRequestEntity _self;
  final $Res Function(PatchMeProfileRequestEntity) _then;

/// Create a copy of PatchMeProfileRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? givenName = null,Object? familyName = freezed,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatchMeProfileRequestEntity].
extension PatchMeProfileRequestEntityPatterns on PatchMeProfileRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchMeProfileRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchMeProfileRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchMeProfileRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String givenName,  String? familyName,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity() when $default != null:
return $default(_that.givenName,_that.familyName,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String givenName,  String? familyName,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity():
return $default(_that.givenName,_that.familyName,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String givenName,  String? familyName,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _PatchMeProfileRequestEntity() when $default != null:
return $default(_that.givenName,_that.familyName,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _PatchMeProfileRequestEntity implements PatchMeProfileRequestEntity {
  const _PatchMeProfileRequestEntity({required this.givenName, this.familyName, this.displayName});
  

@override final  String givenName;
@override final  String? familyName;
@override final  String? displayName;

/// Create a copy of PatchMeProfileRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchMeProfileRequestEntityCopyWith<_PatchMeProfileRequestEntity> get copyWith => __$PatchMeProfileRequestEntityCopyWithImpl<_PatchMeProfileRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchMeProfileRequestEntity&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,displayName);

@override
String toString() {
  return 'PatchMeProfileRequestEntity(givenName: $givenName, familyName: $familyName, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$PatchMeProfileRequestEntityCopyWith<$Res> implements $PatchMeProfileRequestEntityCopyWith<$Res> {
  factory _$PatchMeProfileRequestEntityCopyWith(_PatchMeProfileRequestEntity value, $Res Function(_PatchMeProfileRequestEntity) _then) = __$PatchMeProfileRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String givenName, String? familyName, String? displayName
});




}
/// @nodoc
class __$PatchMeProfileRequestEntityCopyWithImpl<$Res>
    implements _$PatchMeProfileRequestEntityCopyWith<$Res> {
  __$PatchMeProfileRequestEntityCopyWithImpl(this._self, this._then);

  final _PatchMeProfileRequestEntity _self;
  final $Res Function(_PatchMeProfileRequestEntity) _then;

/// Create a copy of PatchMeProfileRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? givenName = null,Object? familyName = freezed,Object? displayName = freezed,}) {
  return _then(_PatchMeProfileRequestEntity(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
