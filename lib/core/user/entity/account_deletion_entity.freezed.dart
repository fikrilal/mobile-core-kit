// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_deletion_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountDeletionEntity {

 String get requestedAt; String get scheduledFor;
/// Create a copy of AccountDeletionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionEntityCopyWith<AccountDeletionEntity> get copyWith => _$AccountDeletionEntityCopyWithImpl<AccountDeletionEntity>(this as AccountDeletionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionEntity&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor));
}


@override
int get hashCode => Object.hash(runtimeType,requestedAt,scheduledFor);

@override
String toString() {
  return 'AccountDeletionEntity(requestedAt: $requestedAt, scheduledFor: $scheduledFor)';
}


}

/// @nodoc
abstract mixin class $AccountDeletionEntityCopyWith<$Res>  {
  factory $AccountDeletionEntityCopyWith(AccountDeletionEntity value, $Res Function(AccountDeletionEntity) _then) = _$AccountDeletionEntityCopyWithImpl;
@useResult
$Res call({
 String requestedAt, String scheduledFor
});




}
/// @nodoc
class _$AccountDeletionEntityCopyWithImpl<$Res>
    implements $AccountDeletionEntityCopyWith<$Res> {
  _$AccountDeletionEntityCopyWithImpl(this._self, this._then);

  final AccountDeletionEntity _self;
  final $Res Function(AccountDeletionEntity) _then;

/// Create a copy of AccountDeletionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestedAt = null,Object? scheduledFor = null,}) {
  return _then(_self.copyWith(
requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionEntity].
extension AccountDeletionEntityPatterns on AccountDeletionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionEntity value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestedAt,  String scheduledFor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionEntity() when $default != null:
return $default(_that.requestedAt,_that.scheduledFor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestedAt,  String scheduledFor)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionEntity():
return $default(_that.requestedAt,_that.scheduledFor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestedAt,  String scheduledFor)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionEntity() when $default != null:
return $default(_that.requestedAt,_that.scheduledFor);case _:
  return null;

}
}

}

/// @nodoc


class _AccountDeletionEntity implements AccountDeletionEntity {
  const _AccountDeletionEntity({required this.requestedAt, required this.scheduledFor});
  

@override final  String requestedAt;
@override final  String scheduledFor;

/// Create a copy of AccountDeletionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionEntityCopyWith<_AccountDeletionEntity> get copyWith => __$AccountDeletionEntityCopyWithImpl<_AccountDeletionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionEntity&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor));
}


@override
int get hashCode => Object.hash(runtimeType,requestedAt,scheduledFor);

@override
String toString() {
  return 'AccountDeletionEntity(requestedAt: $requestedAt, scheduledFor: $scheduledFor)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionEntityCopyWith<$Res> implements $AccountDeletionEntityCopyWith<$Res> {
  factory _$AccountDeletionEntityCopyWith(_AccountDeletionEntity value, $Res Function(_AccountDeletionEntity) _then) = __$AccountDeletionEntityCopyWithImpl;
@override @useResult
$Res call({
 String requestedAt, String scheduledFor
});




}
/// @nodoc
class __$AccountDeletionEntityCopyWithImpl<$Res>
    implements _$AccountDeletionEntityCopyWith<$Res> {
  __$AccountDeletionEntityCopyWithImpl(this._self, this._then);

  final _AccountDeletionEntity _self;
  final $Res Function(_AccountDeletionEntity) _then;

/// Create a copy of AccountDeletionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestedAt = null,Object? scheduledFor = null,}) {
  return _then(_AccountDeletionEntity(
requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
