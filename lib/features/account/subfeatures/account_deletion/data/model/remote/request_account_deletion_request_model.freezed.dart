// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_account_deletion_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestAccountDeletionRequestModel {

 String? get idempotencyKey;
/// Create a copy of RequestAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAccountDeletionRequestModelCopyWith<RequestAccountDeletionRequestModel> get copyWith => _$RequestAccountDeletionRequestModelCopyWithImpl<RequestAccountDeletionRequestModel>(this as RequestAccountDeletionRequestModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAccountDeletionRequestModel&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'RequestAccountDeletionRequestModel(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $RequestAccountDeletionRequestModelCopyWith<$Res>  {
  factory $RequestAccountDeletionRequestModelCopyWith(RequestAccountDeletionRequestModel value, $Res Function(RequestAccountDeletionRequestModel) _then) = _$RequestAccountDeletionRequestModelCopyWithImpl;
@useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class _$RequestAccountDeletionRequestModelCopyWithImpl<$Res>
    implements $RequestAccountDeletionRequestModelCopyWith<$Res> {
  _$RequestAccountDeletionRequestModelCopyWithImpl(this._self, this._then);

  final RequestAccountDeletionRequestModel _self;
  final $Res Function(RequestAccountDeletionRequestModel) _then;

/// Create a copy of RequestAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestAccountDeletionRequestModel].
extension RequestAccountDeletionRequestModelPatterns on RequestAccountDeletionRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAccountDeletionRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAccountDeletionRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAccountDeletionRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel() when $default != null:
return $default(_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel():
return $default(_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestModel() when $default != null:
return $default(_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _RequestAccountDeletionRequestModel implements RequestAccountDeletionRequestModel {
  const _RequestAccountDeletionRequestModel({this.idempotencyKey});
  

@override final  String? idempotencyKey;

/// Create a copy of RequestAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAccountDeletionRequestModelCopyWith<_RequestAccountDeletionRequestModel> get copyWith => __$RequestAccountDeletionRequestModelCopyWithImpl<_RequestAccountDeletionRequestModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAccountDeletionRequestModel&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'RequestAccountDeletionRequestModel(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$RequestAccountDeletionRequestModelCopyWith<$Res> implements $RequestAccountDeletionRequestModelCopyWith<$Res> {
  factory _$RequestAccountDeletionRequestModelCopyWith(_RequestAccountDeletionRequestModel value, $Res Function(_RequestAccountDeletionRequestModel) _then) = __$RequestAccountDeletionRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class __$RequestAccountDeletionRequestModelCopyWithImpl<$Res>
    implements _$RequestAccountDeletionRequestModelCopyWith<$Res> {
  __$RequestAccountDeletionRequestModelCopyWithImpl(this._self, this._then);

  final _RequestAccountDeletionRequestModel _self;
  final $Res Function(_RequestAccountDeletionRequestModel) _then;

/// Create a copy of RequestAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_RequestAccountDeletionRequestModel(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
