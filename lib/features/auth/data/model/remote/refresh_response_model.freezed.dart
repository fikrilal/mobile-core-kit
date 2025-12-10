// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RefreshResponseModel {

 String? get accessToken; String? get refreshToken; int? get expiresIn;
/// Create a copy of RefreshResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshResponseModelCopyWith<RefreshResponseModel> get copyWith => _$RefreshResponseModelCopyWithImpl<RefreshResponseModel>(this as RefreshResponseModel, _$identity);

  /// Serializes this RefreshResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshResponseModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'RefreshResponseModel(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $RefreshResponseModelCopyWith<$Res>  {
  factory $RefreshResponseModelCopyWith(RefreshResponseModel value, $Res Function(RefreshResponseModel) _then) = _$RefreshResponseModelCopyWithImpl;
@useResult
$Res call({
 String? accessToken, String? refreshToken, int? expiresIn
});




}
/// @nodoc
class _$RefreshResponseModelCopyWithImpl<$Res>
    implements $RefreshResponseModelCopyWith<$Res> {
  _$RefreshResponseModelCopyWithImpl(this._self, this._then);

  final RefreshResponseModel _self;
  final $Res Function(RefreshResponseModel) _then;

/// Create a copy of RefreshResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshResponseModel].
extension RefreshResponseModelPatterns on RefreshResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _RefreshResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  int? expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshResponseModel() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? accessToken,  String? refreshToken,  int? expiresIn)  $default,) {final _that = this;
switch (_that) {
case _RefreshResponseModel():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? accessToken,  String? refreshToken,  int? expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _RefreshResponseModel() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshResponseModel extends RefreshResponseModel {
  const _RefreshResponseModel({this.accessToken, this.refreshToken, this.expiresIn}): super._();
  factory _RefreshResponseModel.fromJson(Map<String, dynamic> json) => _$RefreshResponseModelFromJson(json);

@override final  String? accessToken;
@override final  String? refreshToken;
@override final  int? expiresIn;

/// Create a copy of RefreshResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshResponseModelCopyWith<_RefreshResponseModel> get copyWith => __$RefreshResponseModelCopyWithImpl<_RefreshResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshResponseModel&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'RefreshResponseModel(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$RefreshResponseModelCopyWith<$Res> implements $RefreshResponseModelCopyWith<$Res> {
  factory _$RefreshResponseModelCopyWith(_RefreshResponseModel value, $Res Function(_RefreshResponseModel) _then) = __$RefreshResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String? accessToken, String? refreshToken, int? expiresIn
});




}
/// @nodoc
class __$RefreshResponseModelCopyWithImpl<$Res>
    implements _$RefreshResponseModelCopyWith<$Res> {
  __$RefreshResponseModelCopyWithImpl(this._self, this._then);

  final _RefreshResponseModel _self;
  final $Res Function(_RefreshResponseModel) _then;

/// Create a copy of RefreshResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,}) {
  return _then(_RefreshResponseModel(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
