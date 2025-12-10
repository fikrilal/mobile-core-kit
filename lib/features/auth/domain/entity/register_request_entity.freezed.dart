// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegisterRequestEntity {

 String get displayName; String get email; String get password; String get timezone; String get profileVisibility;
/// Create a copy of RegisterRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestEntityCopyWith<RegisterRequestEntity> get copyWith => _$RegisterRequestEntityCopyWithImpl<RegisterRequestEntity>(this as RegisterRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequestEntity&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,email,password,timezone,profileVisibility);

@override
String toString() {
  return 'RegisterRequestEntity(displayName: $displayName, email: $email, password: $password, timezone: $timezone, profileVisibility: $profileVisibility)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestEntityCopyWith<$Res>  {
  factory $RegisterRequestEntityCopyWith(RegisterRequestEntity value, $Res Function(RegisterRequestEntity) _then) = _$RegisterRequestEntityCopyWithImpl;
@useResult
$Res call({
 String displayName, String email, String password, String timezone, String profileVisibility
});




}
/// @nodoc
class _$RegisterRequestEntityCopyWithImpl<$Res>
    implements $RegisterRequestEntityCopyWith<$Res> {
  _$RegisterRequestEntityCopyWithImpl(this._self, this._then);

  final RegisterRequestEntity _self;
  final $Res Function(RegisterRequestEntity) _then;

/// Create a copy of RegisterRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? email = null,Object? password = null,Object? timezone = null,Object? profileVisibility = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequestEntity].
extension RegisterRequestEntityPatterns on RegisterRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String email,  String password,  String timezone,  String profileVisibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequestEntity() when $default != null:
return $default(_that.displayName,_that.email,_that.password,_that.timezone,_that.profileVisibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String email,  String password,  String timezone,  String profileVisibility)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestEntity():
return $default(_that.displayName,_that.email,_that.password,_that.timezone,_that.profileVisibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String email,  String password,  String timezone,  String profileVisibility)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestEntity() when $default != null:
return $default(_that.displayName,_that.email,_that.password,_that.timezone,_that.profileVisibility);case _:
  return null;

}
}

}

/// @nodoc


class _RegisterRequestEntity implements RegisterRequestEntity {
  const _RegisterRequestEntity({required this.displayName, required this.email, required this.password, required this.timezone, required this.profileVisibility});
  

@override final  String displayName;
@override final  String email;
@override final  String password;
@override final  String timezone;
@override final  String profileVisibility;

/// Create a copy of RegisterRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestEntityCopyWith<_RegisterRequestEntity> get copyWith => __$RegisterRequestEntityCopyWithImpl<_RegisterRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequestEntity&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,email,password,timezone,profileVisibility);

@override
String toString() {
  return 'RegisterRequestEntity(displayName: $displayName, email: $email, password: $password, timezone: $timezone, profileVisibility: $profileVisibility)';
}


}

/// @nodoc
abstract mixin class _$RegisterRequestEntityCopyWith<$Res> implements $RegisterRequestEntityCopyWith<$Res> {
  factory _$RegisterRequestEntityCopyWith(_RegisterRequestEntity value, $Res Function(_RegisterRequestEntity) _then) = __$RegisterRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String email, String password, String timezone, String profileVisibility
});




}
/// @nodoc
class __$RegisterRequestEntityCopyWithImpl<$Res>
    implements _$RegisterRequestEntityCopyWith<$Res> {
  __$RegisterRequestEntityCopyWithImpl(this._self, this._then);

  final _RegisterRequestEntity _self;
  final $Res Function(_RegisterRequestEntity) _then;

/// Create a copy of RegisterRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? email = null,Object? password = null,Object? timezone = null,Object? profileVisibility = null,}) {
  return _then(_RegisterRequestEntity(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
