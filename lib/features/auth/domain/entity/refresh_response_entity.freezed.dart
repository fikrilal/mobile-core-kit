// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_response_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefreshResponseEntity {

 String? get accessToken; String? get refreshToken; int? get expiresIn;
/// Create a copy of RefreshResponseEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshResponseEntityCopyWith<RefreshResponseEntity> get copyWith => _$RefreshResponseEntityCopyWithImpl<RefreshResponseEntity>(this as RefreshResponseEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshResponseEntity&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}


@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'RefreshResponseEntity(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $RefreshResponseEntityCopyWith<$Res>  {
  factory $RefreshResponseEntityCopyWith(RefreshResponseEntity value, $Res Function(RefreshResponseEntity) _then) = _$RefreshResponseEntityCopyWithImpl;
@useResult
$Res call({
 String? accessToken, String? refreshToken, int? expiresIn
});




}
/// @nodoc
class _$RefreshResponseEntityCopyWithImpl<$Res>
    implements $RefreshResponseEntityCopyWith<$Res> {
  _$RefreshResponseEntityCopyWithImpl(this._self, this._then);

  final RefreshResponseEntity _self;
  final $Res Function(RefreshResponseEntity) _then;

/// Create a copy of RefreshResponseEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshResponseEntity].
extension RefreshResponseEntityPatterns on RefreshResponseEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshResponseEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshResponseEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshResponseEntity value)  $default,){
final _that = this;
switch (_that) {
case _RefreshResponseEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshResponseEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshResponseEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  int? expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshResponseEntity() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  int? expiresIn)  $default,) {final _that = this;
switch (_that) {
case _RefreshResponseEntity():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? accessToken,  String? refreshToken,  int? expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _RefreshResponseEntity() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc


class _RefreshResponseEntity implements RefreshResponseEntity {
  const _RefreshResponseEntity({this.accessToken, this.refreshToken, this.expiresIn});
  

@override final  String? accessToken;
@override final  String? refreshToken;
@override final  int? expiresIn;

/// Create a copy of RefreshResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshResponseEntityCopyWith<_RefreshResponseEntity> get copyWith => __$RefreshResponseEntityCopyWithImpl<_RefreshResponseEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshResponseEntity&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}


@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'RefreshResponseEntity(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$RefreshResponseEntityCopyWith<$Res> implements $RefreshResponseEntityCopyWith<$Res> {
  factory _$RefreshResponseEntityCopyWith(_RefreshResponseEntity value, $Res Function(_RefreshResponseEntity) _then) = __$RefreshResponseEntityCopyWithImpl;
@override @useResult
$Res call({
 String? accessToken, String? refreshToken, int? expiresIn
});




}
/// @nodoc
class __$RefreshResponseEntityCopyWithImpl<$Res>
    implements _$RefreshResponseEntityCopyWith<$Res> {
  __$RefreshResponseEntityCopyWithImpl(this._self, this._then);

  final _RefreshResponseEntity _self;
  final $Res Function(_RefreshResponseEntity) _then;

/// Create a copy of RefreshResponseEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,}) {
  return _then(_RefreshResponseEntity(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
