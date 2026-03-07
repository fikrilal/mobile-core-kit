// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revoke_me_session_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RevokeMeSessionRequestModel {

 String get sessionId;
/// Create a copy of RevokeMeSessionRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevokeMeSessionRequestModelCopyWith<RevokeMeSessionRequestModel> get copyWith => _$RevokeMeSessionRequestModelCopyWithImpl<RevokeMeSessionRequestModel>(this as RevokeMeSessionRequestModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevokeMeSessionRequestModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'RevokeMeSessionRequestModel(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $RevokeMeSessionRequestModelCopyWith<$Res>  {
  factory $RevokeMeSessionRequestModelCopyWith(RevokeMeSessionRequestModel value, $Res Function(RevokeMeSessionRequestModel) _then) = _$RevokeMeSessionRequestModelCopyWithImpl;
@useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class _$RevokeMeSessionRequestModelCopyWithImpl<$Res>
    implements $RevokeMeSessionRequestModelCopyWith<$Res> {
  _$RevokeMeSessionRequestModelCopyWithImpl(this._self, this._then);

  final RevokeMeSessionRequestModel _self;
  final $Res Function(RevokeMeSessionRequestModel) _then;

/// Create a copy of RevokeMeSessionRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionId = null,}) {
  return _then(_self.copyWith(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RevokeMeSessionRequestModel].
extension RevokeMeSessionRequestModelPatterns on RevokeMeSessionRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevokeMeSessionRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevokeMeSessionRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevokeMeSessionRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RevokeMeSessionRequestModel() when $default != null:
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
case _RevokeMeSessionRequestModel() when $default != null:
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
case _RevokeMeSessionRequestModel():
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
case _RevokeMeSessionRequestModel() when $default != null:
return $default(_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc


class _RevokeMeSessionRequestModel implements RevokeMeSessionRequestModel {
  const _RevokeMeSessionRequestModel({required this.sessionId});
  

@override final  String sessionId;

/// Create a copy of RevokeMeSessionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevokeMeSessionRequestModelCopyWith<_RevokeMeSessionRequestModel> get copyWith => __$RevokeMeSessionRequestModelCopyWithImpl<_RevokeMeSessionRequestModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevokeMeSessionRequestModel&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,sessionId);

@override
String toString() {
  return 'RevokeMeSessionRequestModel(sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$RevokeMeSessionRequestModelCopyWith<$Res> implements $RevokeMeSessionRequestModelCopyWith<$Res> {
  factory _$RevokeMeSessionRequestModelCopyWith(_RevokeMeSessionRequestModel value, $Res Function(_RevokeMeSessionRequestModel) _then) = __$RevokeMeSessionRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String sessionId
});




}
/// @nodoc
class __$RevokeMeSessionRequestModelCopyWithImpl<$Res>
    implements _$RevokeMeSessionRequestModelCopyWith<$Res> {
  __$RevokeMeSessionRequestModelCopyWithImpl(this._self, this._then);

  final _RevokeMeSessionRequestModel _self;
  final $Res Function(_RevokeMeSessionRequestModel) _then;

/// Create a copy of RevokeMeSessionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionId = null,}) {
  return _then(_RevokeMeSessionRequestModel(
sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
