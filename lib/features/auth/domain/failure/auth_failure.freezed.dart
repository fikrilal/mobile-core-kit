// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure()';
}


}

/// @nodoc
class $AuthFailureCopyWith<$Res>  {
$AuthFailureCopyWith(AuthFailure _, $Res Function(AuthFailure) __);
}


/// Adds pattern-matching-related methods to [AuthFailure].
extension AuthFailurePatterns on AuthFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _NetworkFailure value)?  network,TResult Function( _UnauthenticatedFailure value)?  unauthenticated,TResult Function( _EmailTakenFailure value)?  emailTaken,TResult Function( _EmailNotVerifiedFailure value)?  emailNotVerified,TResult Function( _ValidationFailure value)?  validation,TResult Function( _InvalidCredentials value)?  invalidCredentials,TResult Function( _RateLimited value)?  tooManyRequests,TResult Function( _ServerError value)?  serverError,TResult Function( _UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkFailure() when network != null:
return network(_that);case _UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated(_that);case _EmailTakenFailure() when emailTaken != null:
return emailTaken(_that);case _EmailNotVerifiedFailure() when emailNotVerified != null:
return emailNotVerified(_that);case _ValidationFailure() when validation != null:
return validation(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _RateLimited() when tooManyRequests != null:
return tooManyRequests(_that);case _ServerError() when serverError != null:
return serverError(_that);case _UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _NetworkFailure value)  network,required TResult Function( _UnauthenticatedFailure value)  unauthenticated,required TResult Function( _EmailTakenFailure value)  emailTaken,required TResult Function( _EmailNotVerifiedFailure value)  emailNotVerified,required TResult Function( _ValidationFailure value)  validation,required TResult Function( _InvalidCredentials value)  invalidCredentials,required TResult Function( _RateLimited value)  tooManyRequests,required TResult Function( _ServerError value)  serverError,required TResult Function( _UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkFailure():
return network(_that);case _UnauthenticatedFailure():
return unauthenticated(_that);case _EmailTakenFailure():
return emailTaken(_that);case _EmailNotVerifiedFailure():
return emailNotVerified(_that);case _ValidationFailure():
return validation(_that);case _InvalidCredentials():
return invalidCredentials(_that);case _RateLimited():
return tooManyRequests(_that);case _ServerError():
return serverError(_that);case _UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _NetworkFailure value)?  network,TResult? Function( _UnauthenticatedFailure value)?  unauthenticated,TResult? Function( _EmailTakenFailure value)?  emailTaken,TResult? Function( _EmailNotVerifiedFailure value)?  emailNotVerified,TResult? Function( _ValidationFailure value)?  validation,TResult? Function( _InvalidCredentials value)?  invalidCredentials,TResult? Function( _RateLimited value)?  tooManyRequests,TResult? Function( _ServerError value)?  serverError,TResult? Function( _UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case _NetworkFailure() when network != null:
return network(_that);case _UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated(_that);case _EmailTakenFailure() when emailTaken != null:
return emailTaken(_that);case _EmailNotVerifiedFailure() when emailNotVerified != null:
return emailNotVerified(_that);case _ValidationFailure() when validation != null:
return validation(_that);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials(_that);case _RateLimited() when tooManyRequests != null:
return tooManyRequests(_that);case _ServerError() when serverError != null:
return serverError(_that);case _UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  network,TResult Function()?  unauthenticated,TResult Function()?  emailTaken,TResult Function()?  emailNotVerified,TResult Function( List<ValidationError> errors)?  validation,TResult Function()?  invalidCredentials,TResult Function()?  tooManyRequests,TResult Function( String? message)?  serverError,TResult Function( String? message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkFailure() when network != null:
return network();case _UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated();case _EmailTakenFailure() when emailTaken != null:
return emailTaken();case _EmailNotVerifiedFailure() when emailNotVerified != null:
return emailNotVerified();case _ValidationFailure() when validation != null:
return validation(_that.errors);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _RateLimited() when tooManyRequests != null:
return tooManyRequests();case _ServerError() when serverError != null:
return serverError(_that.message);case _UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  network,required TResult Function()  unauthenticated,required TResult Function()  emailTaken,required TResult Function()  emailNotVerified,required TResult Function( List<ValidationError> errors)  validation,required TResult Function()  invalidCredentials,required TResult Function()  tooManyRequests,required TResult Function( String? message)  serverError,required TResult Function( String? message)  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkFailure():
return network();case _UnauthenticatedFailure():
return unauthenticated();case _EmailTakenFailure():
return emailTaken();case _EmailNotVerifiedFailure():
return emailNotVerified();case _ValidationFailure():
return validation(_that.errors);case _InvalidCredentials():
return invalidCredentials();case _RateLimited():
return tooManyRequests();case _ServerError():
return serverError(_that.message);case _UnexpectedFailure():
return unexpected(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  network,TResult? Function()?  unauthenticated,TResult? Function()?  emailTaken,TResult? Function()?  emailNotVerified,TResult? Function( List<ValidationError> errors)?  validation,TResult? Function()?  invalidCredentials,TResult? Function()?  tooManyRequests,TResult? Function( String? message)?  serverError,TResult? Function( String? message)?  unexpected,}) {final _that = this;
switch (_that) {
case _NetworkFailure() when network != null:
return network();case _UnauthenticatedFailure() when unauthenticated != null:
return unauthenticated();case _EmailTakenFailure() when emailTaken != null:
return emailTaken();case _EmailNotVerifiedFailure() when emailNotVerified != null:
return emailNotVerified();case _ValidationFailure() when validation != null:
return validation(_that.errors);case _InvalidCredentials() when invalidCredentials != null:
return invalidCredentials();case _RateLimited() when tooManyRequests != null:
return tooManyRequests();case _ServerError() when serverError != null:
return serverError(_that.message);case _UnexpectedFailure() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkFailure implements AuthFailure {
  const _NetworkFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.network()';
}


}




/// @nodoc


class _UnauthenticatedFailure implements AuthFailure {
  const _UnauthenticatedFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnauthenticatedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.unauthenticated()';
}


}




/// @nodoc


class _EmailTakenFailure implements AuthFailure {
  const _EmailTakenFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailTakenFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emailTaken()';
}


}




/// @nodoc


class _EmailNotVerifiedFailure implements AuthFailure {
  const _EmailNotVerifiedFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailNotVerifiedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.emailNotVerified()';
}


}




/// @nodoc


class _ValidationFailure implements AuthFailure {
  const _ValidationFailure(final  List<ValidationError> errors): _errors = errors;
  

 final  List<ValidationError> _errors;
 List<ValidationError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationFailureCopyWith<_ValidationFailure> get copyWith => __$ValidationFailureCopyWithImpl<_ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationFailure&&const DeepCollectionEquality().equals(other._errors, _errors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'AuthFailure.validation(errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ValidationFailureCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$ValidationFailureCopyWith(_ValidationFailure value, $Res Function(_ValidationFailure) _then) = __$ValidationFailureCopyWithImpl;
@useResult
$Res call({
 List<ValidationError> errors
});




}
/// @nodoc
class __$ValidationFailureCopyWithImpl<$Res>
    implements _$ValidationFailureCopyWith<$Res> {
  __$ValidationFailureCopyWithImpl(this._self, this._then);

  final _ValidationFailure _self;
  final $Res Function(_ValidationFailure) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errors = null,}) {
  return _then(_ValidationFailure(
null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ValidationError>,
  ));
}


}

/// @nodoc


class _InvalidCredentials implements AuthFailure {
  const _InvalidCredentials();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvalidCredentials);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.invalidCredentials()';
}


}




/// @nodoc


class _RateLimited implements AuthFailure {
  const _RateLimited();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RateLimited);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthFailure.tooManyRequests()';
}


}




/// @nodoc


class _ServerError implements AuthFailure {
  const _ServerError([this.message]);
  

 final  String? message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerErrorCopyWith<_ServerError> get copyWith => __$ServerErrorCopyWithImpl<_ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.serverError(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ServerErrorCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$ServerErrorCopyWith(_ServerError value, $Res Function(_ServerError) _then) = __$ServerErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$ServerErrorCopyWithImpl<$Res>
    implements _$ServerErrorCopyWith<$Res> {
  __$ServerErrorCopyWithImpl(this._self, this._then);

  final _ServerError _self;
  final $Res Function(_ServerError) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_ServerError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _UnexpectedFailure implements AuthFailure {
  const _UnexpectedFailure({this.message});
  

 final  String? message;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnexpectedFailureCopyWith<_UnexpectedFailure> get copyWith => __$UnexpectedFailureCopyWithImpl<_UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnexpectedFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthFailure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnexpectedFailureCopyWith<$Res> implements $AuthFailureCopyWith<$Res> {
  factory _$UnexpectedFailureCopyWith(_UnexpectedFailure value, $Res Function(_UnexpectedFailure) _then) = __$UnexpectedFailureCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$UnexpectedFailureCopyWithImpl<$Res>
    implements _$UnexpectedFailureCopyWith<$Res> {
  __$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final _UnexpectedFailure _self;
  final $Res Function(_UnexpectedFailure) _then;

/// Create a copy of AuthFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_UnexpectedFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
