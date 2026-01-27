// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_confirm_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordResetConfirmRequestEntity {

 String get token; String get newPassword;
/// Create a copy of PasswordResetConfirmRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmRequestEntityCopyWith<PasswordResetConfirmRequestEntity> get copyWith => _$PasswordResetConfirmRequestEntityCopyWithImpl<PasswordResetConfirmRequestEntity>(this as PasswordResetConfirmRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmRequestEntity&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}


@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequestEntity(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmRequestEntityCopyWith<$Res>  {
  factory $PasswordResetConfirmRequestEntityCopyWith(PasswordResetConfirmRequestEntity value, $Res Function(PasswordResetConfirmRequestEntity) _then) = _$PasswordResetConfirmRequestEntityCopyWithImpl;
@useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class _$PasswordResetConfirmRequestEntityCopyWithImpl<$Res>
    implements $PasswordResetConfirmRequestEntityCopyWith<$Res> {
  _$PasswordResetConfirmRequestEntityCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmRequestEntity _self;
  final $Res Function(PasswordResetConfirmRequestEntity) _then;

/// Create a copy of PasswordResetConfirmRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetConfirmRequestEntity].
extension PasswordResetConfirmRequestEntityPatterns on PasswordResetConfirmRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirmRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity() when $default != null:
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity():
return $default(_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestEntity() when $default != null:
return $default(_that.token,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordResetConfirmRequestEntity implements PasswordResetConfirmRequestEntity {
  const _PasswordResetConfirmRequestEntity({required this.token, required this.newPassword});
  

@override final  String token;
@override final  String newPassword;

/// Create a copy of PasswordResetConfirmRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmRequestEntityCopyWith<_PasswordResetConfirmRequestEntity> get copyWith => __$PasswordResetConfirmRequestEntityCopyWithImpl<_PasswordResetConfirmRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirmRequestEntity&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}


@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequestEntity(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmRequestEntityCopyWith<$Res> implements $PasswordResetConfirmRequestEntityCopyWith<$Res> {
  factory _$PasswordResetConfirmRequestEntityCopyWith(_PasswordResetConfirmRequestEntity value, $Res Function(_PasswordResetConfirmRequestEntity) _then) = __$PasswordResetConfirmRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class __$PasswordResetConfirmRequestEntityCopyWithImpl<$Res>
    implements _$PasswordResetConfirmRequestEntityCopyWith<$Res> {
  __$PasswordResetConfirmRequestEntityCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirmRequestEntity _self;
  final $Res Function(_PasswordResetConfirmRequestEntity) _then;

/// Create a copy of PasswordResetConfirmRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_PasswordResetConfirmRequestEntity(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
