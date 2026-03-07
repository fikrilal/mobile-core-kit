// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_push_token_upsert_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MePushTokenUpsertRequestModel {

 String get platform; String get token;
/// Create a copy of MePushTokenUpsertRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MePushTokenUpsertRequestModelCopyWith<MePushTokenUpsertRequestModel> get copyWith => _$MePushTokenUpsertRequestModelCopyWithImpl<MePushTokenUpsertRequestModel>(this as MePushTokenUpsertRequestModel, _$identity);

  /// Serializes this MePushTokenUpsertRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MePushTokenUpsertRequestModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,token);

@override
String toString() {
  return 'MePushTokenUpsertRequestModel(platform: $platform, token: $token)';
}


}

/// @nodoc
abstract mixin class $MePushTokenUpsertRequestModelCopyWith<$Res>  {
  factory $MePushTokenUpsertRequestModelCopyWith(MePushTokenUpsertRequestModel value, $Res Function(MePushTokenUpsertRequestModel) _then) = _$MePushTokenUpsertRequestModelCopyWithImpl;
@useResult
$Res call({
 String platform, String token
});




}
/// @nodoc
class _$MePushTokenUpsertRequestModelCopyWithImpl<$Res>
    implements $MePushTokenUpsertRequestModelCopyWith<$Res> {
  _$MePushTokenUpsertRequestModelCopyWithImpl(this._self, this._then);

  final MePushTokenUpsertRequestModel _self;
  final $Res Function(MePushTokenUpsertRequestModel) _then;

/// Create a copy of MePushTokenUpsertRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? platform = null,Object? token = null,}) {
  return _then(_self.copyWith(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MePushTokenUpsertRequestModel].
extension MePushTokenUpsertRequestModelPatterns on MePushTokenUpsertRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MePushTokenUpsertRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MePushTokenUpsertRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MePushTokenUpsertRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String platform,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel() when $default != null:
return $default(_that.platform,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String platform,  String token)  $default,) {final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel():
return $default(_that.platform,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String platform,  String token)?  $default,) {final _that = this;
switch (_that) {
case _MePushTokenUpsertRequestModel() when $default != null:
return $default(_that.platform,_that.token);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _MePushTokenUpsertRequestModel extends MePushTokenUpsertRequestModel {
  const _MePushTokenUpsertRequestModel({required this.platform, required this.token}): super._();
  factory _MePushTokenUpsertRequestModel.fromJson(Map<String, dynamic> json) => _$MePushTokenUpsertRequestModelFromJson(json);

@override final  String platform;
@override final  String token;

/// Create a copy of MePushTokenUpsertRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MePushTokenUpsertRequestModelCopyWith<_MePushTokenUpsertRequestModel> get copyWith => __$MePushTokenUpsertRequestModelCopyWithImpl<_MePushTokenUpsertRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MePushTokenUpsertRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MePushTokenUpsertRequestModel&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,platform,token);

@override
String toString() {
  return 'MePushTokenUpsertRequestModel(platform: $platform, token: $token)';
}


}

/// @nodoc
abstract mixin class _$MePushTokenUpsertRequestModelCopyWith<$Res> implements $MePushTokenUpsertRequestModelCopyWith<$Res> {
  factory _$MePushTokenUpsertRequestModelCopyWith(_MePushTokenUpsertRequestModel value, $Res Function(_MePushTokenUpsertRequestModel) _then) = __$MePushTokenUpsertRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String platform, String token
});




}
/// @nodoc
class __$MePushTokenUpsertRequestModelCopyWithImpl<$Res>
    implements _$MePushTokenUpsertRequestModelCopyWith<$Res> {
  __$MePushTokenUpsertRequestModelCopyWithImpl(this._self, this._then);

  final _MePushTokenUpsertRequestModel _self;
  final $Res Function(_MePushTokenUpsertRequestModel) _then;

/// Create a copy of MePushTokenUpsertRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? platform = null,Object? token = null,}) {
  return _then(_MePushTokenUpsertRequestModel(
platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
