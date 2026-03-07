// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revoke_me_session_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RevokeMeSessionRequestEntity {

 String get sessionId;
/// Create a copy of RevokeMeSessionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevokeMeSessionRequestEntityCopyWith<RevokeMeSessionRequestEntity> get copyWith => _$RevokeMeSessionRequestEntityCopyWithImpl<RevokeMeSessionRequestEntity>(this as RevokeMeSessionRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevokeMeSessionRequestEntity&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'RevokeMeSessionRequestEntity(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $RevokeMeSessionRequestEntityCopyWith<$Res>  {
  factory $RevokeMeSessionRequestEntityCopyWith(RevokeMeSessionRequestEntity value, $Res Function(RevokeMeSessionRequestEntity) _then) = _$RevokeMeSessionRequestEntityCopyWithImpl;
@useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class _$RevokeMeSessionRequestEntityCopyWithImpl<$Res>
    implements $RevokeMeSessionRequestEntityCopyWith<$Res> {
  _$RevokeMeSessionRequestEntityCopyWithImpl(this._self, this._then);

  final RevokeMeSessionRequestEntity _self;
  final $Res Function(RevokeMeSessionRequestEntity) _then;

/// Create a copy of RevokeMeSessionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RevokeMeSessionRequestEntity].
extension RevokeMeSessionRequestEntityPatterns on RevokeMeSessionRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevokeMeSessionRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevokeMeSessionRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevokeMeSessionRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity() when $default != null:
return $default(_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sessionId)  $default,) {final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity():
return $default(_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sessionId)?  $default,) {final _that = this;
switch (_that) {
case _RevokeMeSessionRequestEntity() when $default != null:
return $default(_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc


class _RevokeMeSessionRequestEntity implements RevokeMeSessionRequestEntity {
  const _RevokeMeSessionRequestEntity({required this.sessionId});
  

@override final  String sessionId;

/// Create a copy of RevokeMeSessionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevokeMeSessionRequestEntityCopyWith<_RevokeMeSessionRequestEntity> get copyWith => __$RevokeMeSessionRequestEntityCopyWithImpl<_RevokeMeSessionRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevokeMeSessionRequestEntity&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'RevokeMeSessionRequestEntity(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$RevokeMeSessionRequestEntityCopyWith<$Res> implements $RevokeMeSessionRequestEntityCopyWith<$Res> {
  factory _$RevokeMeSessionRequestEntityCopyWith(_RevokeMeSessionRequestEntity value, $Res Function(_RevokeMeSessionRequestEntity) _then) = __$RevokeMeSessionRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class __$RevokeMeSessionRequestEntityCopyWithImpl<$Res>
    implements _$RevokeMeSessionRequestEntityCopyWith<$Res> {
  __$RevokeMeSessionRequestEntityCopyWithImpl(this._self, this._then);

  final _RevokeMeSessionRequestEntity _self;
  final $Res Function(_RevokeMeSessionRequestEntity) _then;

/// Create a copy of RevokeMeSessionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,}) {
  return _then(_RevokeMeSessionRequestEntity(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
