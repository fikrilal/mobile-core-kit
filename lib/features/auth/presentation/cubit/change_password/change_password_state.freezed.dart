// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangePasswordState {

 String get currentPassword; String get newPassword; String get confirmNewPassword; ValidationError? get currentPasswordError; ValidationError? get newPasswordError; ValidationError? get confirmNewPasswordError; AuthFailure? get failure; ChangePasswordStatus get status;
/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordStateCopyWith<ChangePasswordState> get copyWith => _$ChangePasswordStateCopyWithImpl<ChangePasswordState>(this as ChangePasswordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordState&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmNewPassword, confirmNewPassword) || other.confirmNewPassword == confirmNewPassword)&&(identical(other.currentPasswordError, currentPasswordError) || other.currentPasswordError == currentPasswordError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmNewPasswordError, confirmNewPasswordError) || other.confirmNewPasswordError == confirmNewPasswordError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword,confirmNewPassword,currentPasswordError,newPasswordError,confirmNewPasswordError,failure,status);

@override
String toString() {
  return 'ChangePasswordState(currentPassword: $currentPassword, newPassword: $newPassword, confirmNewPassword: $confirmNewPassword, currentPasswordError: $currentPasswordError, newPasswordError: $newPasswordError, confirmNewPasswordError: $confirmNewPasswordError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class $ChangePasswordStateCopyWith<$Res>  {
  factory $ChangePasswordStateCopyWith(ChangePasswordState value, $Res Function(ChangePasswordState) _then) = _$ChangePasswordStateCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword, String confirmNewPassword, ValidationError? currentPasswordError, ValidationError? newPasswordError, ValidationError? confirmNewPasswordError, AuthFailure? failure, ChangePasswordStatus status
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ChangePasswordStateCopyWithImpl<$Res>
    implements $ChangePasswordStateCopyWith<$Res> {
  _$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final ChangePasswordState _self;
  final $Res Function(ChangePasswordState) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,Object? confirmNewPassword = null,Object? currentPasswordError = freezed,Object? newPasswordError = freezed,Object? confirmNewPasswordError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmNewPassword: null == confirmNewPassword ? _self.confirmNewPassword : confirmNewPassword // ignore: cast_nullable_to_non_nullable
as String,currentPasswordError: freezed == currentPasswordError ? _self.currentPasswordError : currentPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,confirmNewPasswordError: freezed == confirmNewPasswordError ? _self.confirmNewPasswordError : confirmNewPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangePasswordStatus,
  ));
}
/// Create a copy of ChangePasswordState
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


/// Adds pattern-matching-related methods to [ChangePasswordState].
extension ChangePasswordStatePatterns on ChangePasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordState value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordState value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword,  String confirmNewPassword,  ValidationError? currentPasswordError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  ChangePasswordStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.currentPassword,_that.newPassword,_that.confirmNewPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword,  String confirmNewPassword,  ValidationError? currentPasswordError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  ChangePasswordStatus status)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState():
return $default(_that.currentPassword,_that.newPassword,_that.confirmNewPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPassword,  String newPassword,  String confirmNewPassword,  ValidationError? currentPasswordError,  ValidationError? newPasswordError,  ValidationError? confirmNewPasswordError,  AuthFailure? failure,  ChangePasswordStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.currentPassword,_that.newPassword,_that.confirmNewPassword,_that.currentPasswordError,_that.newPasswordError,_that.confirmNewPasswordError,_that.failure,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ChangePasswordState extends ChangePasswordState {
  const _ChangePasswordState({this.currentPassword = '', this.newPassword = '', this.confirmNewPassword = '', this.currentPasswordError, this.newPasswordError, this.confirmNewPasswordError, this.failure, this.status = ChangePasswordStatus.initial}): super._();
  

@override@JsonKey() final  String currentPassword;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmNewPassword;
@override final  ValidationError? currentPasswordError;
@override final  ValidationError? newPasswordError;
@override final  ValidationError? confirmNewPasswordError;
@override final  AuthFailure? failure;
@override@JsonKey() final  ChangePasswordStatus status;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordStateCopyWith<_ChangePasswordState> get copyWith => __$ChangePasswordStateCopyWithImpl<_ChangePasswordState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordState&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmNewPassword, confirmNewPassword) || other.confirmNewPassword == confirmNewPassword)&&(identical(other.currentPasswordError, currentPasswordError) || other.currentPasswordError == currentPasswordError)&&(identical(other.newPasswordError, newPasswordError) || other.newPasswordError == newPasswordError)&&(identical(other.confirmNewPasswordError, confirmNewPasswordError) || other.confirmNewPasswordError == confirmNewPasswordError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword,confirmNewPassword,currentPasswordError,newPasswordError,confirmNewPasswordError,failure,status);

@override
String toString() {
  return 'ChangePasswordState(currentPassword: $currentPassword, newPassword: $newPassword, confirmNewPassword: $confirmNewPassword, currentPasswordError: $currentPasswordError, newPasswordError: $newPasswordError, confirmNewPasswordError: $confirmNewPasswordError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordStateCopyWith<$Res> implements $ChangePasswordStateCopyWith<$Res> {
  factory _$ChangePasswordStateCopyWith(_ChangePasswordState value, $Res Function(_ChangePasswordState) _then) = __$ChangePasswordStateCopyWithImpl;
@override @useResult
$Res call({
 String currentPassword, String newPassword, String confirmNewPassword, ValidationError? currentPasswordError, ValidationError? newPasswordError, ValidationError? confirmNewPasswordError, AuthFailure? failure, ChangePasswordStatus status
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ChangePasswordStateCopyWithImpl<$Res>
    implements _$ChangePasswordStateCopyWith<$Res> {
  __$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final _ChangePasswordState _self;
  final $Res Function(_ChangePasswordState) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,Object? confirmNewPassword = null,Object? currentPasswordError = freezed,Object? newPasswordError = freezed,Object? confirmNewPasswordError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_ChangePasswordState(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmNewPassword: null == confirmNewPassword ? _self.confirmNewPassword : confirmNewPassword // ignore: cast_nullable_to_non_nullable
as String,currentPasswordError: freezed == currentPasswordError ? _self.currentPasswordError : currentPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,newPasswordError: freezed == newPasswordError ? _self.newPasswordError : newPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,confirmNewPasswordError: freezed == confirmNewPasswordError ? _self.confirmNewPasswordError : confirmNewPasswordError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChangePasswordStatus,
  ));
}

/// Create a copy of ChangePasswordState
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
