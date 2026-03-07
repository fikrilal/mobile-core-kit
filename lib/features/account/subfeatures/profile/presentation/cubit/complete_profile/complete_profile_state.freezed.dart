// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompleteProfileState {

 String get givenName; String get familyName; ValidationError? get givenNameError; ValidationError? get familyNameError; AuthFailure? get failure; CompleteProfileStatus get status;
/// Create a copy of CompleteProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompleteProfileStateCopyWith<CompleteProfileState> get copyWith => _$CompleteProfileStateCopyWithImpl<CompleteProfileState>(this as CompleteProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompleteProfileState&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.givenNameError, givenNameError) || other.givenNameError == givenNameError)&&(identical(other.familyNameError, familyNameError) || other.familyNameError == familyNameError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,givenNameError,familyNameError,failure,status);

@override
String toString() {
  return 'CompleteProfileState(givenName: $givenName, familyName: $familyName, givenNameError: $givenNameError, familyNameError: $familyNameError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class $CompleteProfileStateCopyWith<$Res>  {
  factory $CompleteProfileStateCopyWith(CompleteProfileState value, $Res Function(CompleteProfileState) _then) = _$CompleteProfileStateCopyWithImpl;
@useResult
$Res call({
 String givenName, String familyName, ValidationError? givenNameError, ValidationError? familyNameError, AuthFailure? failure, CompleteProfileStatus status
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$CompleteProfileStateCopyWithImpl<$Res>
    implements $CompleteProfileStateCopyWith<$Res> {
  _$CompleteProfileStateCopyWithImpl(this._self, this._then);

  final CompleteProfileState _self;
  final $Res Function(CompleteProfileState) _then;

/// Create a copy of CompleteProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? givenName = null,Object? familyName = null,Object? givenNameError = freezed,Object? familyNameError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,givenNameError: freezed == givenNameError ? _self.givenNameError : givenNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,familyNameError: freezed == familyNameError ? _self.familyNameError : familyNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompleteProfileStatus,
  ));
}
/// Create a copy of CompleteProfileState
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


/// Adds pattern-matching-related methods to [CompleteProfileState].
extension CompleteProfileStatePatterns on CompleteProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompleteProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompleteProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompleteProfileState value)  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompleteProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  CompleteProfileStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompleteProfileState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  CompleteProfileStatus status)  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String givenName,  String familyName,  ValidationError? givenNameError,  ValidationError? familyNameError,  AuthFailure? failure,  CompleteProfileStatus status)?  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileState() when $default != null:
return $default(_that.givenName,_that.familyName,_that.givenNameError,_that.familyNameError,_that.failure,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _CompleteProfileState implements CompleteProfileState {
  const _CompleteProfileState({this.givenName = '', this.familyName = '', this.givenNameError, this.familyNameError, this.failure, this.status = CompleteProfileStatus.initial});
  

@override@JsonKey() final  String givenName;
@override@JsonKey() final  String familyName;
@override final  ValidationError? givenNameError;
@override final  ValidationError? familyNameError;
@override final  AuthFailure? failure;
@override@JsonKey() final  CompleteProfileStatus status;

/// Create a copy of CompleteProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompleteProfileStateCopyWith<_CompleteProfileState> get copyWith => __$CompleteProfileStateCopyWithImpl<_CompleteProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompleteProfileState&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName)&&(identical(other.givenNameError, givenNameError) || other.givenNameError == givenNameError)&&(identical(other.familyNameError, familyNameError) || other.familyNameError == familyNameError)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,givenName,familyName,givenNameError,familyNameError,failure,status);

@override
String toString() {
  return 'CompleteProfileState(givenName: $givenName, familyName: $familyName, givenNameError: $givenNameError, familyNameError: $familyNameError, failure: $failure, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CompleteProfileStateCopyWith<$Res> implements $CompleteProfileStateCopyWith<$Res> {
  factory _$CompleteProfileStateCopyWith(_CompleteProfileState value, $Res Function(_CompleteProfileState) _then) = __$CompleteProfileStateCopyWithImpl;
@override @useResult
$Res call({
 String givenName, String familyName, ValidationError? givenNameError, ValidationError? familyNameError, AuthFailure? failure, CompleteProfileStatus status
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$CompleteProfileStateCopyWithImpl<$Res>
    implements _$CompleteProfileStateCopyWith<$Res> {
  __$CompleteProfileStateCopyWithImpl(this._self, this._then);

  final _CompleteProfileState _self;
  final $Res Function(_CompleteProfileState) _then;

/// Create a copy of CompleteProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? givenName = null,Object? familyName = null,Object? givenNameError = freezed,Object? familyNameError = freezed,Object? failure = freezed,Object? status = null,}) {
  return _then(_CompleteProfileState(
givenName: null == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String,familyName: null == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String,givenNameError: freezed == givenNameError ? _self.givenNameError : givenNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,familyNameError: freezed == familyNameError ? _self.familyNameError : familyNameError // ignore: cast_nullable_to_non_nullable
as ValidationError?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CompleteProfileStatus,
  ));
}

/// Create a copy of CompleteProfileState
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
