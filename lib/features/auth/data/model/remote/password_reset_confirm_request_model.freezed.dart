// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_confirm_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordResetConfirmRequestModel {

 String get token; String get newPassword;
/// Create a copy of PasswordResetConfirmRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetConfirmRequestModelCopyWith<PasswordResetConfirmRequestModel> get copyWith => _$PasswordResetConfirmRequestModelCopyWithImpl<PasswordResetConfirmRequestModel>(this as PasswordResetConfirmRequestModel, _$identity);

  /// Serializes this PasswordResetConfirmRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetConfirmRequestModel&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequestModel(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $PasswordResetConfirmRequestModelCopyWith<$Res>  {
  factory $PasswordResetConfirmRequestModelCopyWith(PasswordResetConfirmRequestModel value, $Res Function(PasswordResetConfirmRequestModel) _then) = _$PasswordResetConfirmRequestModelCopyWithImpl;
@useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class _$PasswordResetConfirmRequestModelCopyWithImpl<$Res>
    implements $PasswordResetConfirmRequestModelCopyWith<$Res> {
  _$PasswordResetConfirmRequestModelCopyWithImpl(this._self, this._then);

  final PasswordResetConfirmRequestModel _self;
  final $Res Function(PasswordResetConfirmRequestModel) _then;

/// Create a copy of PasswordResetConfirmRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetConfirmRequestModel].
extension PasswordResetConfirmRequestModelPatterns on PasswordResetConfirmRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetConfirmRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetConfirmRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetConfirmRequestModel() when $default != null:
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
case _PasswordResetConfirmRequestModel() when $default != null:
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
case _PasswordResetConfirmRequestModel():
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
case _PasswordResetConfirmRequestModel() when $default != null:
return $default(_that.token,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _PasswordResetConfirmRequestModel extends PasswordResetConfirmRequestModel {
  const _PasswordResetConfirmRequestModel({required this.token, required this.newPassword}): super._();
  factory _PasswordResetConfirmRequestModel.fromJson(Map<String, dynamic> json) => _$PasswordResetConfirmRequestModelFromJson(json);

@override final  String token;
@override final  String newPassword;

/// Create a copy of PasswordResetConfirmRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetConfirmRequestModelCopyWith<_PasswordResetConfirmRequestModel> get copyWith => __$PasswordResetConfirmRequestModelCopyWithImpl<_PasswordResetConfirmRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetConfirmRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetConfirmRequestModel&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,newPassword);

@override
String toString() {
  return 'PasswordResetConfirmRequestModel(token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetConfirmRequestModelCopyWith<$Res> implements $PasswordResetConfirmRequestModelCopyWith<$Res> {
  factory _$PasswordResetConfirmRequestModelCopyWith(_PasswordResetConfirmRequestModel value, $Res Function(_PasswordResetConfirmRequestModel) _then) = __$PasswordResetConfirmRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String token, String newPassword
});




}
/// @nodoc
class __$PasswordResetConfirmRequestModelCopyWithImpl<$Res>
    implements _$PasswordResetConfirmRequestModelCopyWith<$Res> {
  __$PasswordResetConfirmRequestModelCopyWithImpl(this._self, this._then);

  final _PasswordResetConfirmRequestModel _self;
  final $Res Function(_PasswordResetConfirmRequestModel) _then;

/// Create a copy of PasswordResetConfirmRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? newPassword = null,}) {
  return _then(_PasswordResetConfirmRequestModel(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
