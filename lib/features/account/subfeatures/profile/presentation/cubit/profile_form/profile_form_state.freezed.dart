// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFormState {

 String get givenName; String get familyName; ValidationError? get givenNameError; ValidationError? get familyNameError; AuthFailure? get failure; ProfileFormStatus get status;
/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFormStateCopyWith<ProfileFormState> get copyWith => _$ProfileFormStateCopyWithImpl<ProfileFormState>(this as ProfileFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFormState&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.givenNameError, givenNameError) || other.givenNameError == givenNameError)&&(identical(other.familyNameError, familyNameError) || other.familyNameError == familyNameError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,givenNameError,familyNameError,failure,status);

@override
String toString() {
  return 'ProfileFormState(givenName: $givenName, familyName: $familyName, givenNameError: $givenNameError, familyNameError: $familyNameError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class $ProfileFormStateCopyWith<$Res>  {
  factory $ProfileFormStateCopyWith(ProfileFormState value, $Res Function(ProfileFormState) _then) = _$ProfileFormStateCopyWithImpl;
@useResult
$Res call({
 String givenName, String familyName, ValidationError? givenNameError, ValidationError? familyNameError, AuthFailure? failure, ProfileFormStatus status
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ProfileFormStateCopyWithImpl<$Res>
    implements $ProfileFormStateCopyWith<$Res> {
  _$ProfileFormStateCopyWithImpl(this._self, this._then);

  final ProfileFormState _self;
  final $Res Function(ProfileFormState) _then;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? givenName = null,Object? familyName = null,Object? givenNameError = freezed,Object? familyNameError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,givenNameError: freezed == givenNameError ? _self.givenNameError : givenNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,familyNameError: freezed == familyNameError ? _self.familyNameError : familyNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileFormStatus,
  ));
}
/// Create a copy of ProfileFormState
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


/// Adds pattern-matching-related methods to [ProfileFormState].
extension ProfileFormStatePatterns on ProfileFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileFormState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  ProfileFormStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.givenName,_that.familyName,_that.givenNameError,_that.familyNameError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  ProfileFormStatus status)  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState():
return $default(_that.givenName,_that.familyName,_that.givenNameError,_that.familyNameError,_that.failure,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  ProfileFormStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.givenName,_that.familyName,_that.givenNameError,_that.familyNameError,_that.failure,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileFormState implements ProfileFormState {
  const _ProfileFormState({this.givenName = '', this.familyName = '', this.givenNameError, this.familyNameError, this.failure, this.status = ProfileFormStatus.initial});
  

@override@JsonKey() final  String givenName;
@override@JsonKey() final  String familyName;
@override final  ValidationError? givenNameError;
@override final  ValidationError? familyNameError;
@override final  AuthFailure? failure;
@override@JsonKey() final  ProfileFormStatus status;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFormStateCopyWith<_ProfileFormState> get copyWith => __$ProfileFormStateCopyWithImpl<_ProfileFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileFormState&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.givenNameError, givenNameError) || other.givenNameError == givenNameError)&&(identical(other.familyNameError, familyNameError) || other.familyNameError == familyNameError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,givenNameError,familyNameError,failure,status);

@override
String toString() {
  return 'ProfileFormState(givenName: $givenName, familyName: $familyName, givenNameError: $givenNameError, familyNameError: $familyNameError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ProfileFormStateCopyWith<$Res> implements $ProfileFormStateCopyWith<$Res> {
  factory _$ProfileFormStateCopyWith(_ProfileFormState value, $Res Function(_ProfileFormState) _then) = __$ProfileFormStateCopyWithImpl;
@override @useResult
$Res call({
 String givenName, String familyName, ValidationError? givenNameError, ValidationError? familyNameError, AuthFailure? failure, ProfileFormStatus status
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ProfileFormStateCopyWithImpl<$Res>
    implements _$ProfileFormStateCopyWith<$Res> {
  __$ProfileFormStateCopyWithImpl(this._self, this._then);

  final _ProfileFormState _self;
  final $Res Function(_ProfileFormState) _then;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? givenName = null,Object? familyName = null,Object? givenNameError = freezed,Object? familyNameError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_ProfileFormState(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,givenNameError: freezed == givenNameError ? _self.givenNameError : givenNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,familyNameError: freezed == familyNameError ? _self.familyNameError : familyNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileFormStatus,
  ));
}

/// Create a copy of ProfileFormState
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
