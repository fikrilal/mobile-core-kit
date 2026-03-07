// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cancel_account_deletion_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CancelAccountDeletionRequestEntity {

 String? get idempotencyKey;
/// Create a copy of CancelAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelAccountDeletionRequestEntityCopyWith<CancelAccountDeletionRequestEntity> get copyWith => _$CancelAccountDeletionRequestEntityCopyWithImpl<CancelAccountDeletionRequestEntity>(this as CancelAccountDeletionRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAccountDeletionRequestEntity&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'CancelAccountDeletionRequestEntity(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $CancelAccountDeletionRequestEntityCopyWith<$Res>  {
  factory $CancelAccountDeletionRequestEntityCopyWith(CancelAccountDeletionRequestEntity value, $Res Function(CancelAccountDeletionRequestEntity) _then) = _$CancelAccountDeletionRequestEntityCopyWithImpl;
@useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class _$CancelAccountDeletionRequestEntityCopyWithImpl<$Res>
    implements $CancelAccountDeletionRequestEntityCopyWith<$Res> {
  _$CancelAccountDeletionRequestEntityCopyWithImpl(this._self, this._then);

  final CancelAccountDeletionRequestEntity _self;
  final $Res Function(CancelAccountDeletionRequestEntity) _then;

/// Create a copy of CancelAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelAccountDeletionRequestEntity].
extension CancelAccountDeletionRequestEntityPatterns on CancelAccountDeletionRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelAccountDeletionRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelAccountDeletionRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelAccountDeletionRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CancelAccountDeletionRequestEntity() when $default != null:
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
case _CancelAccountDeletionRequestEntity() when $default != null:
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
case _CancelAccountDeletionRequestEntity():
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
case _CancelAccountDeletionRequestEntity() when $default != null:
return $default(_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _CancelAccountDeletionRequestEntity implements CancelAccountDeletionRequestEntity {
  const _CancelAccountDeletionRequestEntity({this.idempotencyKey});
  

@override final  String? idempotencyKey;

/// Create a copy of CancelAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelAccountDeletionRequestEntityCopyWith<_CancelAccountDeletionRequestEntity> get copyWith => __$CancelAccountDeletionRequestEntityCopyWithImpl<_CancelAccountDeletionRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelAccountDeletionRequestEntity&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'CancelAccountDeletionRequestEntity(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$CancelAccountDeletionRequestEntityCopyWith<$Res> implements $CancelAccountDeletionRequestEntityCopyWith<$Res> {
  factory _$CancelAccountDeletionRequestEntityCopyWith(_CancelAccountDeletionRequestEntity value, $Res Function(_CancelAccountDeletionRequestEntity) _then) = __$CancelAccountDeletionRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class __$CancelAccountDeletionRequestEntityCopyWithImpl<$Res>
    implements _$CancelAccountDeletionRequestEntityCopyWith<$Res> {
  __$CancelAccountDeletionRequestEntityCopyWithImpl(this._self, this._then);

  final _CancelAccountDeletionRequestEntity _self;
  final $Res Function(_CancelAccountDeletionRequestEntity) _then;

/// Create a copy of CancelAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_CancelAccountDeletionRequestEntity(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
