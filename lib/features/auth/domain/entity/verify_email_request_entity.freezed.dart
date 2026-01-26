// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_email_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerifyEmailRequestEntity {

 String get token;
/// Create a copy of VerifyEmailRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyEmailRequestEntityCopyWith<VerifyEmailRequestEntity> get copyWith => _$VerifyEmailRequestEntityCopyWithImpl<VerifyEmailRequestEntity>(this as VerifyEmailRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyEmailRequestEntity&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'VerifyEmailRequestEntity(token: $token)';
}


}

/// @nodoc
abstract mixin class $VerifyEmailRequestEntityCopyWith<$Res>  {
  factory $VerifyEmailRequestEntityCopyWith(VerifyEmailRequestEntity value, $Res Function(VerifyEmailRequestEntity) _then) = _$VerifyEmailRequestEntityCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$VerifyEmailRequestEntityCopyWithImpl<$Res>
    implements $VerifyEmailRequestEntityCopyWith<$Res> {
  _$VerifyEmailRequestEntityCopyWithImpl(this._self, this._then);

  final VerifyEmailRequestEntity _self;
  final $Res Function(VerifyEmailRequestEntity) _then;

/// Create a copy of VerifyEmailRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyEmailRequestEntity].
extension VerifyEmailRequestEntityPatterns on VerifyEmailRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyEmailRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyEmailRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyEmailRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity() when $default != null:
return $default(_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token)  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity():
return $default(_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token)?  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestEntity() when $default != null:
return $default(_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _VerifyEmailRequestEntity implements VerifyEmailRequestEntity {
  const _VerifyEmailRequestEntity({required this.token});
  

@override final  String token;

/// Create a copy of VerifyEmailRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyEmailRequestEntityCopyWith<_VerifyEmailRequestEntity> get copyWith => __$VerifyEmailRequestEntityCopyWithImpl<_VerifyEmailRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyEmailRequestEntity&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'VerifyEmailRequestEntity(token: $token)';
}


}

/// @nodoc
abstract mixin class _$VerifyEmailRequestEntityCopyWith<$Res> implements $VerifyEmailRequestEntityCopyWith<$Res> {
  factory _$VerifyEmailRequestEntityCopyWith(_VerifyEmailRequestEntity value, $Res Function(_VerifyEmailRequestEntity) _then) = __$VerifyEmailRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String token
});




}
/// @nodoc
class __$VerifyEmailRequestEntityCopyWithImpl<$Res>
    implements _$VerifyEmailRequestEntityCopyWith<$Res> {
  __$VerifyEmailRequestEntityCopyWithImpl(this._self, this._then);

  final _VerifyEmailRequestEntity _self;
  final $Res Function(_VerifyEmailRequestEntity) _then;

/// Create a copy of VerifyEmailRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_VerifyEmailRequestEntity(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
