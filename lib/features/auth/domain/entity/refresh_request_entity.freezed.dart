// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RefreshRequestEntity {

 String get refreshToken;
/// Create a copy of RefreshRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshRequestEntityCopyWith<RefreshRequestEntity> get copyWith => _$RefreshRequestEntityCopyWithImpl<RefreshRequestEntity>(this as RefreshRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshRequestEntity&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}


@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestEntity(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $RefreshRequestEntityCopyWith<$Res>  {
  factory $RefreshRequestEntityCopyWith(RefreshRequestEntity value, $Res Function(RefreshRequestEntity) _then) = _$RefreshRequestEntityCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshRequestEntityCopyWithImpl<$Res>
    implements $RefreshRequestEntityCopyWith<$Res> {
  _$RefreshRequestEntityCopyWithImpl(this._self, this._then);

  final RefreshRequestEntity _self;
  final $Res Function(RefreshRequestEntity) _then;

/// Create a copy of RefreshRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshRequestEntity].
extension RefreshRequestEntityPatterns on RefreshRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshRequestEntity() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestEntity():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestEntity() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc


class _RefreshRequestEntity implements RefreshRequestEntity {
  const _RefreshRequestEntity({required this.refreshToken});
  

@override final  String refreshToken;

/// Create a copy of RefreshRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshRequestEntityCopyWith<_RefreshRequestEntity> get copyWith => __$RefreshRequestEntityCopyWithImpl<_RefreshRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshRequestEntity&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}


@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestEntity(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshRequestEntityCopyWith<$Res> implements $RefreshRequestEntityCopyWith<$Res> {
  factory _$RefreshRequestEntityCopyWith(_RefreshRequestEntity value, $Res Function(_RefreshRequestEntity) _then) = __$RefreshRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshRequestEntityCopyWithImpl<$Res>
    implements _$RefreshRequestEntityCopyWith<$Res> {
  __$RefreshRequestEntityCopyWithImpl(this._self, this._then);

  final _RefreshRequestEntity _self;
  final $Res Function(_RefreshRequestEntity) _then;

/// Create a copy of RefreshRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshRequestEntity(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
