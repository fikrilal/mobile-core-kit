// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_confirm_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordResetConfirmState {

 String get token; String get newPassword; String get confirmNewPassword; bool get newPasswordTouched; bool get confirmNewPasswordTouched; ValidationError? get tokenError; ValidationError? get newPasswordError; ValidationError? get confirmNewPasswordError; AuthFailure? get failure; PasswordResetConfirmStatus get status;
/// Create a copy of PasswordResetConfirmState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmStateCopyWith<PasswordResetConfirmState> get copyWith => _$PasswordResetConfirmStateCopyWithImpl<PasswordResetConfirmState>(this as PasswordResetConfirmState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmState&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmNewPassword, confirmNewPassword) || other.confirmNewPassword == confirmNewPassword)&&(identical(other.newPasswordTouched, newPasswordTouched) || other.newPasswordTouched == newPasswordTouched)&&(identical(other.confirmNewPasswordTouched, confirmNewPasswordTouched) || other.confirmNewPasswordTouched == confirmNewPasswordTouched)&&(identical(other.tokenError, tokenError) || other.tokenError == tokenError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmNewPasswordError, confirmNewPasswordError) || other.confirmNewPasswordError == confirmNewPasswordError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,token,newPassword,confirmNewPassword,newPasswordTouched,confirmNewPasswordTouched,tokenError,newPasswordError,confirmNewPasswordError,failure,status);

@override
String toString() {
  return 'PasswordResetConfirmState(token: $token, newPassword: $newPassword, confirmNewPassword: $confirmNewPassword, newPasswordTouched: $newPasswordTouched, confirmNewPasswordTouched: $confirmNewPasswordTouched, tokenError: $tokenError, newPasswordError: $newPasswordError, confirmNewPasswordError: $confirmNewPasswordError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmStateCopyWith<$Res>  {
  factory $PasswordResetConfirmStateCopyWith(PasswordResetConfirmState value, $Res Function(PasswordResetConfirmState) _then) = _$PasswordResetConfirmStateCopyWithImpl;
@useResult
$Res call({
 String token, String newPassword, String confirmNewPassword, bool newPasswordTouched, bool confirmNewPasswordTouched, ValidationError? tokenError, ValidationError? newPasswordError, ValidationError? confirmNewPasswordError, AuthFailure? failure, PasswordResetConfirmStatus status
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$PasswordResetConfirmStateCopyWithImpl<$Res>
    implements $PasswordResetConfirmStateCopyWith<$Res> {
  _$PasswordResetConfirmStateCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmState _self;
  final $Res Function(PasswordResetConfirmState) _then;

/// Create a copy of PasswordResetConfirmState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? newPassword = null,Object? confirmNewPassword = null,Object? newPasswordTouched = null,Object? confirmNewPasswordTouched = null,Object? tokenError = freezed,Object? newPasswordError = freezed,Object? confirmNewPasswordError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmNewPassword: null == confirmNewPassword ? _self.confirmNewPassword : confirmNewPassword // ignore: cast_nullable_to_non_nullable
as String,newPasswordTouched: null == newPasswordTouched ? _self.newPasswordTouched : newPasswordTouched // ignore: cast_nullable_to_non_nullable
as bool,confirmNewPasswordTouched: null == confirmNewPasswordTouched ? _self.confirmNewPasswordTouched : confirmNewPasswordTouched // ignore: cast_nullable_to_non_nullable
as bool,tokenError: freezed == tokenError ? _self.tokenError : tokenError // ignore: cast_nullable_to_non_nullable
as ValidationError?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,confirmNewPasswordError: freezed == confirmNewPasswordError ? _self.confirmNewPasswordError : confirmNewPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PasswordResetConfirmStatus,
  ));
}
/// Create a copy of PasswordResetConfirmState
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


/// Adds pattern-matching-related methods to [PasswordResetConfirmState].
extension PasswordResetConfirmStatePatterns on PasswordResetConfirmState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirmState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirmState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirmState value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirmState value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String newPassword,  String confirmNewPassword,  bool newPasswordTouched,  bool confirmNewPasswordTouched,  ValidationError? tokenError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  PasswordResetConfirmStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetConfirmState() when $default != null:
return $default(_that.token,_that.newPassword,_that.confirmNewPassword,_that.newPasswordTouched,_that.confirmNewPasswordTouched,_that.tokenError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String newPassword,  String confirmNewPassword,  bool newPasswordTouched,  bool confirmNewPasswordTouched,  ValidationError? tokenError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  PasswordResetConfirmStatus status)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmState():
return $default(_that.token,_that.newPassword,_that.confirmNewPassword,_that.newPasswordTouched,_that.confirmNewPasswordTouched,_that.tokenError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String newPassword,  String confirmNewPassword,  bool newPasswordTouched,  bool confirmNewPasswordTouched,  ValidationError? tokenError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  PasswordResetConfirmStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmState() when $default != null:
return $default(_that.token,_that.newPassword,_that.confirmNewPassword,_that.newPasswordTouched,_that.confirmNewPasswordTouched,_that.tokenError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordResetConfirmState extends PasswordResetConfirmState {
  const _PasswordResetConfirmState({this.token = '', this.newPassword = '', this.confirmNewPassword = '', this.newPasswordTouched = false, this.confirmNewPasswordTouched = false, this.tokenError, this.newPasswordError, this.confirmNewPasswordError, this.failure, this.status = PasswordResetConfirmStatus.initial}): super._();
  

@override@JsonKey() final  String token;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmNewPassword;
@override@JsonKey() final  bool newPasswordTouched;
@override@JsonKey() final  bool confirmNewPasswordTouched;
@override final  ValidationError? tokenError;
@override final  ValidationError? newPasswordError;
@override final  ValidationError? confirmNewPasswordError;
@override final  AuthFailure? failure;
@override@JsonKey() final  PasswordResetConfirmStatus status;

/// Create a copy of PasswordResetConfirmState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmStateCopyWith<_PasswordResetConfirmState> get copyWith => __$PasswordResetConfirmStateCopyWithImpl<_PasswordResetConfirmState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirmState&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmNewPassword, confirmNewPassword) || other.confirmNewPassword == confirmNewPassword)&&(identical(other.newPasswordTouched, newPasswordTouched) || other.newPasswordTouched == newPasswordTouched)&&(identical(other.confirmNewPasswordTouched, confirmNewPasswordTouched) || other.confirmNewPasswordTouched == confirmNewPasswordTouched)&&(identical(other.tokenError, tokenError) || other.tokenError == tokenError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmNewPasswordError, confirmNewPasswordError) || other.confirmNewPasswordError == confirmNewPasswordError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,token,newPassword,confirmNewPassword,newPasswordTouched,confirmNewPasswordTouched,tokenError,newPasswordError,confirmNewPasswordError,failure,status);

@override
String toString() {
  return 'PasswordResetConfirmState(token: $token, newPassword: $newPassword, confirmNewPassword: $confirmNewPassword, newPasswordTouched: $newPasswordTouched, confirmNewPasswordTouched: $confirmNewPasswordTouched, tokenError: $tokenError, newPasswordError: $newPasswordError, confirmNewPasswordError: $confirmNewPasswordError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmStateCopyWith<$Res> implements $PasswordResetConfirmStateCopyWith<$Res> {
  factory _$PasswordResetConfirmStateCopyWith(_PasswordResetConfirmState value, $Res Function(_PasswordResetConfirmState) _then) = __$PasswordResetConfirmStateCopyWithImpl;
@override @useResult
$Res call({
 String token, String newPassword, String confirmNewPassword, bool newPasswordTouched, bool confirmNewPasswordTouched, ValidationError? tokenError, ValidationError? newPasswordError, ValidationError? confirmNewPasswordError, AuthFailure? failure, PasswordResetConfirmStatus status
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$PasswordResetConfirmStateCopyWithImpl<$Res>
    implements _$PasswordResetConfirmStateCopyWith<$Res> {
  __$PasswordResetConfirmStateCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirmState _self;
  final $Res Function(_PasswordResetConfirmState) _then;

/// Create a copy of PasswordResetConfirmState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? newPassword = null,Object? confirmNewPassword = null,Object? newPasswordTouched = null,Object? confirmNewPasswordTouched = null,Object? tokenError = freezed,Object? newPasswordError = freezed,Object? confirmNewPasswordError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_PasswordResetConfirmState(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmNewPassword: null == confirmNewPassword ? _self.confirmNewPassword : confirmNewPassword // ignore: cast_nullable_to_non_nullable
as String,newPasswordTouched: null == newPasswordTouched ? _self.newPasswordTouched : newPasswordTouched // ignore: cast_nullable_to_non_nullable
as bool,confirmNewPasswordTouched: null == confirmNewPasswordTouched ? _self.confirmNewPasswordTouched : confirmNewPasswordTouched // ignore: cast_nullable_to_non_nullable
as bool,tokenError: freezed == tokenError ? _self.tokenError : tokenError // ignore: cast_nullable_to_non_nullable
as ValidationError?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,confirmNewPasswordError: freezed == confirmNewPasswordError ? _self.confirmNewPasswordError : confirmNewPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PasswordResetConfirmStatus,
  ));
}

/// Create a copy of PasswordResetConfirmState
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
