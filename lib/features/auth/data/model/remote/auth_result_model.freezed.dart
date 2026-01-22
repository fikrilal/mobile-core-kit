// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthResultModel {

 AuthUserModel get user; String get accessToken; String get refreshToken;
/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResultModelCopyWith<AuthResultModel> get copyWith => _$AuthResultModelCopyWithImpl<AuthResultModel>(this as AuthResultModel, _$identity);

  /// Serializes this AuthResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResultModel&&(identical(other.user, user) || other.user == user)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,accessToken,refreshToken);

@override
String toString() {
  return 'AuthResultModel(user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $AuthResultModelCopyWith<$Res>  {
  factory $AuthResultModelCopyWith(AuthResultModel value, $Res Function(AuthResultModel) _then) = _$AuthResultModelCopyWithImpl;
@useResult
$Res call({
 AuthUserModel user, String accessToken, String refreshToken
});


$AuthUserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthResultModelCopyWithImpl<$Res>
    implements $AuthResultModelCopyWith<$Res> {
  _$AuthResultModelCopyWithImpl(this._self, this._then);

  final AuthResultModel _self;
  final $Res Function(AuthResultModel) _then;

/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserModel,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserModelCopyWith<$Res> get user {
  
  return $AuthUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResultModel].
extension AuthResultModelPatterns on AuthResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResultModel value)  $default,){
final _that = this;
switch (_that) {
case _AuthResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthUserModel user,  String accessToken,  String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResultModel() when $default != null:
return $default(_that.user,_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthUserModel user,  String accessToken,  String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _AuthResultModel():
return $default(_that.user,_that.accessToken,_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthUserModel user,  String accessToken,  String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _AuthResultModel() when $default != null:
return $default(_that.user,_that.accessToken,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResultModel extends AuthResultModel {
  const _AuthResultModel({required this.user, required this.accessToken, required this.refreshToken}): super._();
  factory _AuthResultModel.fromJson(Map<String, dynamic> json) => _$AuthResultModelFromJson(json);

@override final  AuthUserModel user;
@override final  String accessToken;
@override final  String refreshToken;

/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResultModelCopyWith<_AuthResultModel> get copyWith => __$AuthResultModelCopyWithImpl<_AuthResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResultModel&&(identical(other.user, user) || other.user == user)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,accessToken,refreshToken);

@override
String toString() {
  return 'AuthResultModel(user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$AuthResultModelCopyWith<$Res> implements $AuthResultModelCopyWith<$Res> {
  factory _$AuthResultModelCopyWith(_AuthResultModel value, $Res Function(_AuthResultModel) _then) = __$AuthResultModelCopyWithImpl;
@override @useResult
$Res call({
 AuthUserModel user, String accessToken, String refreshToken
});


@override $AuthUserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthResultModelCopyWithImpl<$Res>
    implements _$AuthResultModelCopyWith<$Res> {
  __$AuthResultModelCopyWithImpl(this._self, this._then);

  final _AuthResultModel _self;
  final $Res Function(_AuthResultModel) _then;

/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? accessToken = null,Object? refreshToken = null,}) {
  return _then(_AuthResultModel(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUserModel,accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AuthResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserModelCopyWith<$Res> get user {
  
  return $AuthUserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
