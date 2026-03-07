// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_account_deletion_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestAccountDeletionRequestEntity {

 String? get idempotencyKey;
/// Create a copy of RequestAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAccountDeletionRequestEntityCopyWith<RequestAccountDeletionRequestEntity> get copyWith => _$RequestAccountDeletionRequestEntityCopyWithImpl<RequestAccountDeletionRequestEntity>(this as RequestAccountDeletionRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAccountDeletionRequestEntity&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'RequestAccountDeletionRequestEntity(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $RequestAccountDeletionRequestEntityCopyWith<$Res>  {
  factory $RequestAccountDeletionRequestEntityCopyWith(RequestAccountDeletionRequestEntity value, $Res Function(RequestAccountDeletionRequestEntity) _then) = _$RequestAccountDeletionRequestEntityCopyWithImpl;
@useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class _$RequestAccountDeletionRequestEntityCopyWithImpl<$Res>
    implements $RequestAccountDeletionRequestEntityCopyWith<$Res> {
  _$RequestAccountDeletionRequestEntityCopyWithImpl(this._self, this._then);

  final RequestAccountDeletionRequestEntity _self;
  final $Res Function(RequestAccountDeletionRequestEntity) _then;

/// Create a copy of RequestAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestAccountDeletionRequestEntity].
extension RequestAccountDeletionRequestEntityPatterns on RequestAccountDeletionRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAccountDeletionRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAccountDeletionRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAccountDeletionRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionRequestEntity() when $default != null:
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
case _RequestAccountDeletionRequestEntity() when $default != null:
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
case _RequestAccountDeletionRequestEntity():
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
case _RequestAccountDeletionRequestEntity() when $default != null:
return $default(_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _RequestAccountDeletionRequestEntity implements RequestAccountDeletionRequestEntity {
  const _RequestAccountDeletionRequestEntity({this.idempotencyKey});
  

@override final  String? idempotencyKey;

/// Create a copy of RequestAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAccountDeletionRequestEntityCopyWith<_RequestAccountDeletionRequestEntity> get copyWith => __$RequestAccountDeletionRequestEntityCopyWithImpl<_RequestAccountDeletionRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAccountDeletionRequestEntity&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,idempotencyKey);

@override
String toString() {
  return 'RequestAccountDeletionRequestEntity(idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$RequestAccountDeletionRequestEntityCopyWith<$Res> implements $RequestAccountDeletionRequestEntityCopyWith<$Res> {
  factory _$RequestAccountDeletionRequestEntityCopyWith(_RequestAccountDeletionRequestEntity value, $Res Function(_RequestAccountDeletionRequestEntity) _then) = __$RequestAccountDeletionRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String? idempotencyKey
});




}
/// @nodoc
class __$RequestAccountDeletionRequestEntityCopyWithImpl<$Res>
    implements _$RequestAccountDeletionRequestEntityCopyWith<$Res> {
  __$RequestAccountDeletionRequestEntityCopyWithImpl(this._self, this._then);

  final _RequestAccountDeletionRequestEntity _self;
  final $Res Function(_RequestAccountDeletionRequestEntity) _then;

/// Create a copy of RequestAccountDeletionRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = freezed,}) {
  return _then(_RequestAccountDeletionRequestEntity(
idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
