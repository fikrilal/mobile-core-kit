// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refresh_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RefreshRequestModel {

 String get refreshToken;
/// Create a copy of RefreshRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshRequestModelCopyWith<RefreshRequestModel> get copyWith => _$RefreshRequestModelCopyWithImpl<RefreshRequestModel>(this as RefreshRequestModel, _$identity);

  /// Serializes this RefreshRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshRequestModel&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestModel(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $RefreshRequestModelCopyWith<$Res>  {
  factory $RefreshRequestModelCopyWith(RefreshRequestModel value, $Res Function(RefreshRequestModel) _then) = _$RefreshRequestModelCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshRequestModelCopyWithImpl<$Res>
    implements $RefreshRequestModelCopyWith<$Res> {
  _$RefreshRequestModelCopyWithImpl(this._self, this._then);

  final RefreshRequestModel _self;
  final $Res Function(RefreshRequestModel) _then;

/// Create a copy of RefreshRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshRequestModel].
extension RefreshRequestModelPatterns on RefreshRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshRequestModel() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestModel():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestModel() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshRequestModel extends RefreshRequestModel {
  const _RefreshRequestModel({required this.refreshToken}): super._();
  factory _RefreshRequestModel.fromJson(Map<String, dynamic> json) => _$RefreshRequestModelFromJson(json);

@override final  String refreshToken;

/// Create a copy of RefreshRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshRequestModelCopyWith<_RefreshRequestModel> get copyWith => __$RefreshRequestModelCopyWithImpl<_RefreshRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshRequestModel&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestModel(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshRequestModelCopyWith<$Res> implements $RefreshRequestModelCopyWith<$Res> {
  factory _$RefreshRequestModelCopyWith(_RefreshRequestModel value, $Res Function(_RefreshRequestModel) _then) = __$RefreshRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshRequestModelCopyWithImpl<$Res>
    implements _$RefreshRequestModelCopyWith<$Res> {
  __$RefreshRequestModelCopyWithImpl(this._self, this._then);

  final _RefreshRequestModel _self;
  final $Res Function(_RefreshRequestModel) _then;

/// Create a copy of RefreshRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshRequestModel(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
