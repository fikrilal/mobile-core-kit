// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_request_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordResetRequestState {

 String get email; bool get emailTouched; ValidationError? get emailError; AuthFailure? get failure; PasswordResetRequestStatus get status;
/// Create a copy of PasswordResetRequestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetRequestStateCopyWith<PasswordResetRequestState> get copyWith => _$PasswordResetRequestStateCopyWithImpl<PasswordResetRequestState>(this as PasswordResetRequestState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetRequestState&&(identical(other.email, email) || other.email == email)&&(identical(other.emailTouched, emailTouched) || other.emailTouched == emailTouched)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,email,emailTouched,emailError,failure,status);

@override
String toString() {
  return 'PasswordResetRequestState(email: $email, emailTouched: $emailTouched, emailError: $emailError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class $PasswordResetRequestStateCopyWith<$Res>  {
  factory $PasswordResetRequestStateCopyWith(PasswordResetRequestState value, $Res Function(PasswordResetRequestState) _then) = _$PasswordResetRequestStateCopyWithImpl;
@useResult
$Res call({
 String email, bool emailTouched, ValidationError? emailError, AuthFailure? failure, PasswordResetRequestStatus status
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$PasswordResetRequestStateCopyWithImpl<$Res>
    implements $PasswordResetRequestStateCopyWith<$Res> {
  _$PasswordResetRequestStateCopyWithImpl(this._self, this._then);

  final PasswordResetRequestState _self;
  final $Res Function(PasswordResetRequestState) _then;

/// Create a copy of PasswordResetRequestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? emailTouched = null,Object? emailError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailTouched: null == emailTouched ? _self.emailTouched : emailTouched // ignore: cast_nullable_to_non_nullable
as bool,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PasswordResetRequestStatus,
  ));
}
/// Create a copy of PasswordResetRequestState
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


/// Adds pattern-matching-related methods to [PasswordResetRequestState].
extension PasswordResetRequestStatePatterns on PasswordResetRequestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetRequestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetRequestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetRequestState value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetRequestState value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  bool emailTouched,  ValidationError? emailError,  AuthFailure? failure,  PasswordResetRequestStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetRequestState() when $default != null:
return $default(_that.email,_that.emailTouched,_that.emailError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  bool emailTouched,  ValidationError? emailError,  AuthFailure? failure,  PasswordResetRequestStatus status)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequestState():
return $default(_that.email,_that.emailTouched,_that.emailError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  bool emailTouched,  ValidationError? emailError,  AuthFailure? failure,  PasswordResetRequestStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequestState() when $default != null:
return $default(_that.email,_that.emailTouched,_that.emailError,_that.failure,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordResetRequestState extends PasswordResetRequestState {
  const _PasswordResetRequestState({this.email = '', this.emailTouched = false, this.emailError, this.failure, this.status = PasswordResetRequestStatus.initial}): super._();
  

@override@JsonKey() final  String email;
@override@JsonKey() final  bool emailTouched;
@override final  ValidationError? emailError;
@override final  AuthFailure? failure;
@override@JsonKey() final  PasswordResetRequestStatus status;

/// Create a copy of PasswordResetRequestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetRequestStateCopyWith<_PasswordResetRequestState> get copyWith => __$PasswordResetRequestStateCopyWithImpl<_PasswordResetRequestState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetRequestState&&(identical(other.email, email) || other.email == email)&&(identical(other.emailTouched, emailTouched) || other.emailTouched == emailTouched)&&(identical(other.emailError, emailError) || other.emailError == emailError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,email,emailTouched,emailError,failure,status);

@override
String toString() {
  return 'PasswordResetRequestState(email: $email, emailTouched: $emailTouched, emailError: $emailError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetRequestStateCopyWith<$Res> implements $PasswordResetRequestStateCopyWith<$Res> {
  factory _$PasswordResetRequestStateCopyWith(_PasswordResetRequestState value, $Res Function(_PasswordResetRequestState) _then) = __$PasswordResetRequestStateCopyWithImpl;
@override @useResult
$Res call({
 String email, bool emailTouched, ValidationError? emailError, AuthFailure? failure, PasswordResetRequestStatus status
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$PasswordResetRequestStateCopyWithImpl<$Res>
    implements _$PasswordResetRequestStateCopyWith<$Res> {
  __$PasswordResetRequestStateCopyWithImpl(this._self, this._then);

  final _PasswordResetRequestState _self;
  final $Res Function(_PasswordResetRequestState) _then;

/// Create a copy of PasswordResetRequestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? emailTouched = null,Object? emailError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_PasswordResetRequestState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailTouched: null == emailTouched ? _self.emailTouched : emailTouched // ignore: cast_nullable_to_non_nullable
as bool,emailError: freezed == emailError ? _self.emailError : emailError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PasswordResetRequestStatus,
  ));
}

/// Create a copy of PasswordResetRequestState
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
