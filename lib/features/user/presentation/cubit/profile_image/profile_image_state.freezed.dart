// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_image_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileImageState {

 ProfileImageStatus get status; ProfileImageAction get action; String? get cachedFilePath; AuthFailure? get failure;
/// Create a copy of ProfileImageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageStateCopyWith<ProfileImageState> get copyWith => _$ProfileImageStateCopyWithImpl<ProfileImageState>(this as ProfileImageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImageState&&(identical(other.status, status) || other.status == status)&&(identical(other.action, action) || other.action == action)&&(identical(other.cachedFilePath, cachedFilePath) || other.cachedFilePath == cachedFilePath)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,action,cachedFilePath,failure);

@override
String toString() {
  return 'ProfileImageState(status: $status, action: $action, cachedFilePath: $cachedFilePath, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ProfileImageStateCopyWith<$Res>  {
  factory $ProfileImageStateCopyWith(ProfileImageState value, $Res Function(ProfileImageState) _then) = _$ProfileImageStateCopyWithImpl;
@useResult
$Res call({
 ProfileImageStatus status, ProfileImageAction action, String? cachedFilePath, AuthFailure? failure
});


$AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ProfileImageStateCopyWithImpl<$Res>
    implements $ProfileImageStateCopyWith<$Res> {
  _$ProfileImageStateCopyWithImpl(this._self, this._then);

  final ProfileImageState _self;
  final $Res Function(ProfileImageState) _then;

/// Create a copy of ProfileImageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? action = null,Object? cachedFilePath = freezed,Object? failure = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileImageStatus,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ProfileImageAction,cachedFilePath: freezed == cachedFilePath ? _self.cachedFilePath : cachedFilePath // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}
/// Create a copy of ProfileImageState
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


/// Adds pattern-matching-related methods to [ProfileImageState].
extension ProfileImageStatePatterns on ProfileImageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImageState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImageState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileImageStatus status,  ProfileImageAction action,  String? cachedFilePath,  AuthFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImageState() when $default != null:
return $default(_that.status,_that.action,_that.cachedFilePath,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileImageStatus status,  ProfileImageAction action,  String? cachedFilePath,  AuthFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _ProfileImageState():
return $default(_that.status,_that.action,_that.cachedFilePath,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileImageStatus status,  ProfileImageAction action,  String? cachedFilePath,  AuthFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImageState() when $default != null:
return $default(_that.status,_that.action,_that.cachedFilePath,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileImageState extends ProfileImageState {
  const _ProfileImageState({this.status = ProfileImageStatus.initial, this.action = ProfileImageAction.none, this.cachedFilePath, this.failure}): super._();
  

@override@JsonKey() final  ProfileImageStatus status;
@override@JsonKey() final  ProfileImageAction action;
@override final  String? cachedFilePath;
@override final  AuthFailure? failure;

/// Create a copy of ProfileImageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageStateCopyWith<_ProfileImageState> get copyWith => __$ProfileImageStateCopyWithImpl<_ProfileImageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImageState&&(identical(other.status, status) || other.status == status)&&(identical(other.action, action) || other.action == action)&&(identical(other.cachedFilePath, cachedFilePath) || other.cachedFilePath == cachedFilePath)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,status,action,cachedFilePath,failure);

@override
String toString() {
  return 'ProfileImageState(status: $status, action: $action, cachedFilePath: $cachedFilePath, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageStateCopyWith<$Res> implements $ProfileImageStateCopyWith<$Res> {
  factory _$ProfileImageStateCopyWith(_ProfileImageState value, $Res Function(_ProfileImageState) _then) = __$ProfileImageStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileImageStatus status, ProfileImageAction action, String? cachedFilePath, AuthFailure? failure
});


@override $AuthFailureCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ProfileImageStateCopyWithImpl<$Res>
    implements _$ProfileImageStateCopyWith<$Res> {
  __$ProfileImageStateCopyWithImpl(this._self, this._then);

  final _ProfileImageState _self;
  final $Res Function(_ProfileImageState) _then;

/// Create a copy of ProfileImageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? action = null,Object? cachedFilePath = freezed,Object? failure = freezed,}) {
  return _then(_ProfileImageState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileImageStatus,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ProfileImageAction,cachedFilePath: freezed == cachedFilePath ? _self.cachedFilePath : cachedFilePath // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}

/// Create a copy of ProfileImageState
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
