// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_account_deletion_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestAccountDeletionState {

 RequestAccountDeletionStatus get status; AccountDeletionAction? get action; AuthFailure? get failure;
/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAccountDeletionStateCopyWith<RequestAccountDeletionState> get copyWith => _$RequestAccountDeletionStateCopyWithImpl<RequestAccountDeletionState>(this as RequestAccountDeletionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAccountDeletionState&&(identical(other.status, status) || other.status == status)&&(identical(other.action, action) || other.action == action)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,action,failure);

@override
String toString() {
  return 'RequestAccountDeletionState(status: $status, action: $action, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $RequestAccountDeletionStateCopyWith<$Res>  {
  factory $RequestAccountDeletionStateCopyWith(RequestAccountDeletionState value, $Res Function(RequestAccountDeletionState) _then) = _$RequestAccountDeletionStateCopyWithImpl;
@useResult
$Res call({
 RequestAccountDeletionStatus status, AccountDeletionAction? action, AuthFailure? failure
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$RequestAccountDeletionStateCopyWithImpl<$Res>
    implements $RequestAccountDeletionStateCopyWith<$Res> {
  _$RequestAccountDeletionStateCopyWithImpl(this._self, this._then);

  final RequestAccountDeletionState _self;
  final $Res Function(RequestAccountDeletionState) _then;

/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? action = freezed,Object? failure = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestAccountDeletionStatus,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AccountDeletionAction?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}
/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequestAccountDeletionState].
extension RequestAccountDeletionStatePatterns on RequestAccountDeletionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAccountDeletionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAccountDeletionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAccountDeletionState value)  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAccountDeletionState value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAccountDeletionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RequestAccountDeletionStatus status,  AccountDeletionAction? action,  AuthFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestAccountDeletionState() when $default != null:
return $default(_that.status,_that.action,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RequestAccountDeletionStatus status,  AccountDeletionAction? action,  AuthFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _RequestAccountDeletionState():
return $default(_that.status,_that.action,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RequestAccountDeletionStatus status,  AccountDeletionAction? action,  AuthFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _RequestAccountDeletionState() when $default != null:
return $default(_that.status,_that.action,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _RequestAccountDeletionState extends RequestAccountDeletionState {
  const _RequestAccountDeletionState({this.status = RequestAccountDeletionStatus.initial, this.action, this.failure}): super._();
  

@override@JsonKey() final  RequestAccountDeletionStatus status;
@override final  AccountDeletionAction? action;
@override final  AuthFailure? failure;

/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAccountDeletionStateCopyWith<_RequestAccountDeletionState> get copyWith => __$RequestAccountDeletionStateCopyWithImpl<_RequestAccountDeletionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAccountDeletionState&&(identical(other.status, status) || other.status == status)&&(identical(other.action, action) || other.action == action)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,action,failure);

@override
String toString() {
  return 'RequestAccountDeletionState(status: $status, action: $action, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$RequestAccountDeletionStateCopyWith<$Res> implements $RequestAccountDeletionStateCopyWith<$Res> {
  factory _$RequestAccountDeletionStateCopyWith(_RequestAccountDeletionState value, $Res Function(_RequestAccountDeletionState) _then) = __$RequestAccountDeletionStateCopyWithImpl;
@override @useResult
$Res call({
 RequestAccountDeletionStatus status, AccountDeletionAction? action, AuthFailure? failure
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$RequestAccountDeletionStateCopyWithImpl<$Res>
    implements _$RequestAccountDeletionStateCopyWith<$Res> {
  __$RequestAccountDeletionStateCopyWithImpl(this._self, this._then);

  final _RequestAccountDeletionState _self;
  final $Res Function(_RequestAccountDeletionState) _then;

/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? action = freezed,Object? failure = freezed,}) {
  return _then(_RequestAccountDeletionState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestAccountDeletionStatus,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AccountDeletionAction?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}

/// Create a copy of RequestAccountDeletionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
