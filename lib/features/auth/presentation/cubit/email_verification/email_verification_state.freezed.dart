// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_verification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmailVerificationState {

 String get token; ValidationError? get tokenError; AuthFailure? get failure; EmailVerificationStatus get status; EmailVerificationAction? get lastAction;
/// Create a copy of EmailVerificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailVerificationStateCopyWith<EmailVerificationState> get copyWith => _$EmailVerificationStateCopyWithImpl<EmailVerificationState>(this as EmailVerificationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailVerificationState&&(identical(other.token, token) || other.token == token)&&(identical(other.tokenError, tokenError) || other.tokenError == tokenError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastAction, lastAction) || other.lastAction == lastAction));
}


@override
int get hashCode => Object.hash(runtimeType,token,tokenError,failure,status,lastAction);

@override
String toString() {
  return 'EmailVerificationState(token: $token, tokenError: $tokenError, failure: $failure, status: $status, lastAction: $lastAction)';
}


}

/// @nodoc
abstract mixin class $EmailVerificationStateCopyWith<$Res>  {
  factory $EmailVerificationStateCopyWith(EmailVerificationState value, $Res Function(EmailVerificationState) _then) = _$EmailVerificationStateCopyWithImpl;
@useResult
$Res call({
 String token, ValidationError? tokenError, AuthFailure? failure, EmailVerificationStatus status, EmailVerificationAction? lastAction
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$EmailVerificationStateCopyWithImpl<$Res>
    implements $EmailVerificationStateCopyWith<$Res> {
  _$EmailVerificationStateCopyWithImpl(this._self, this._then);

  final EmailVerificationState _self;
  final $Res Function(EmailVerificationState) _then;

/// Create a copy of EmailVerificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? tokenError = freezed,Object? failure = freezed,Object? status = null,Object? lastAction = freezed,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,tokenError: freezed == tokenError ? _self.tokenError : tokenError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmailVerificationStatus,lastAction: freezed == lastAction ? _self.lastAction : lastAction // ignore: cast_nullable_to_non_nullable
as EmailVerificationAction?,
  ));
}
/// Create a copy of EmailVerificationState
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


/// Adds pattern-matching-related methods to [EmailVerificationState].
extension EmailVerificationStatePatterns on EmailVerificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailVerificationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailVerificationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailVerificationState value)  $default,){
final _that = this;
switch (_that) {
case _EmailVerificationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailVerificationState value)?  $default,){
final _that = this;
switch (_that) {
case _EmailVerificationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  ValidationError? tokenError,  AuthFailure? failure,  EmailVerificationStatus status,  EmailVerificationAction? lastAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailVerificationState() when $default != null:
return $default(_that.token,_that.tokenError,_that.failure,_that.status,_that.lastAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  ValidationError? tokenError,  AuthFailure? failure,  EmailVerificationStatus status,  EmailVerificationAction? lastAction)  $default,) {final _that = this;
switch (_that) {
case _EmailVerificationState():
return $default(_that.token,_that.tokenError,_that.failure,_that.status,_that.lastAction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  ValidationError? tokenError,  AuthFailure? failure,  EmailVerificationStatus status,  EmailVerificationAction? lastAction)?  $default,) {final _that = this;
switch (_that) {
case _EmailVerificationState() when $default != null:
return $default(_that.token,_that.tokenError,_that.failure,_that.status,_that.lastAction);case _:
  return null;

}
}

}

/// @nodoc


class _EmailVerificationState extends EmailVerificationState {
  const _EmailVerificationState({this.token = '', this.tokenError, this.failure, this.status = EmailVerificationStatus.initial, this.lastAction}): super._();
  

@override@JsonKey() final  String token;
@override final  ValidationError? tokenError;
@override final  AuthFailure? failure;
@override@JsonKey() final  EmailVerificationStatus status;
@override final  EmailVerificationAction? lastAction;

/// Create a copy of EmailVerificationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailVerificationStateCopyWith<_EmailVerificationState> get copyWith => __$EmailVerificationStateCopyWithImpl<_EmailVerificationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailVerificationState&&(identical(other.token, token) || other.token == token)&&(identical(other.tokenError, tokenError) || other.tokenError == tokenError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastAction, lastAction) || other.lastAction == lastAction));
}


@override
int get hashCode => Object.hash(runtimeType,token,tokenError,failure,status,lastAction);

@override
String toString() {
  return 'EmailVerificationState(token: $token, tokenError: $tokenError, failure: $failure, status: $status, lastAction: $lastAction)';
}


}

/// @nodoc
abstract mixin class _$EmailVerificationStateCopyWith<$Res> implements $EmailVerificationStateCopyWith<$Res> {
  factory _$EmailVerificationStateCopyWith(_EmailVerificationState value, $Res Function(_EmailVerificationState) _then) = __$EmailVerificationStateCopyWithImpl;
@override @useResult
$Res call({
 String token, ValidationError? tokenError, AuthFailure? failure, EmailVerificationStatus status, EmailVerificationAction? lastAction
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$EmailVerificationStateCopyWithImpl<$Res>
    implements _$EmailVerificationStateCopyWith<$Res> {
  __$EmailVerificationStateCopyWithImpl(this._self, this._then);

  final _EmailVerificationState _self;
  final $Res Function(_EmailVerificationState) _then;

/// Create a copy of EmailVerificationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? tokenError = freezed,Object? failure = freezed,Object? status = null,Object? lastAction = freezed,}) {
  return _then(_EmailVerificationState(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,tokenError: freezed == tokenError ? _self.tokenError : tokenError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmailVerificationStatus,lastAction: freezed == lastAction ? _self.lastAction : lastAction // ignore: cast_nullable_to_non_nullable
as EmailVerificationAction?,
  ));
}

/// Create a copy of EmailVerificationState
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
