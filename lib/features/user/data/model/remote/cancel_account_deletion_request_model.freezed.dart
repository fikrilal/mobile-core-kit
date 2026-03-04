// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_account_deletion_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CancelAccountDeletionRequestModel {

 String? get idempotencyKey;
/// Create a copy of CancelAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelAccountDeletionRequestModelCopyWith<CancelAccountDeletionRequestModel> get copyWith => _$CancelAccountDeletionRequestModelCopyWithImpl<CancelAccountDeletionRequestModel>(this as CancelAccountDeletionRequestModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAccountDeletionRequestModel&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'CancelAccountDeletionRequestModel(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $CancelAccountDeletionRequestModelCopyWith<$Res>  {
  factory $CancelAccountDeletionRequestModelCopyWith(CancelAccountDeletionRequestModel value, $Res Function(CancelAccountDeletionRequestModel) _then) = _$CancelAccountDeletionRequestModelCopyWithImpl;
@useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class _$CancelAccountDeletionRequestModelCopyWithImpl<$Res>
    implements $CancelAccountDeletionRequestModelCopyWith<$Res> {
  _$CancelAccountDeletionRequestModelCopyWithImpl(this._self, this._then);

  final CancelAccountDeletionRequestModel _self;
  final $Res Function(CancelAccountDeletionRequestModel) _then;

/// Create a copy of CancelAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelAccountDeletionRequestModel].
extension CancelAccountDeletionRequestModelPatterns on CancelAccountDeletionRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelAccountDeletionRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelAccountDeletionRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelAccountDeletionRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestModel() when $default != null:
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
case _CancelAccountDeletionRequestModel() when $default != null:
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
case _CancelAccountDeletionRequestModel():
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
case _CancelAccountDeletionRequestModel() when $default != null:
return $default(_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _CancelAccountDeletionRequestModel implements CancelAccountDeletionRequestModel {
  const _CancelAccountDeletionRequestModel({this.idempotencyKey});
  

@override final  String? idempotencyKey;

/// Create a copy of CancelAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelAccountDeletionRequestModelCopyWith<_CancelAccountDeletionRequestModel> get copyWith => __$CancelAccountDeletionRequestModelCopyWithImpl<_CancelAccountDeletionRequestModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionRequestModel&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'CancelAccountDeletionRequestModel(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$CancelAccountDeletionRequestModelCopyWith<$Res> implements $CancelAccountDeletionRequestModelCopyWith<$Res> {
  factory _$CancelAccountDeletionRequestModelCopyWith(_CancelAccountDeletionRequestModel value, $Res Function(_CancelAccountDeletionRequestModel) _then) = __$CancelAccountDeletionRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class __$CancelAccountDeletionRequestModelCopyWithImpl<$Res>
    implements _$CancelAccountDeletionRequestModelCopyWith<$Res> {
  __$CancelAccountDeletionRequestModelCopyWithImpl(this._self, this._then);

  final _CancelAccountDeletionRequestModel _self;
  final $Res Function(_CancelAccountDeletionRequestModel) _then;

/// Create a copy of CancelAccountDeletionRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_CancelAccountDeletionRequestModel(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
