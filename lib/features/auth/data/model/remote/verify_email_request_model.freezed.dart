// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_email_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerifyEmailRequestModel {

 String get token;
/// Create a copy of VerifyEmailRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyEmailRequestModelCopyWith<VerifyEmailRequestModel> get copyWith => _$VerifyEmailRequestModelCopyWithImpl<VerifyEmailRequestModel>(this as VerifyEmailRequestModel, _$identity);

  /// Serializes this VerifyEmailRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyEmailRequestModel&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'VerifyEmailRequestModel(token: $token)';
}


}

/// @nodoc
abstract mixin class $VerifyEmailRequestModelCopyWith<$Res>  {
  factory $VerifyEmailRequestModelCopyWith(VerifyEmailRequestModel value, $Res Function(VerifyEmailRequestModel) _then) = _$VerifyEmailRequestModelCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$VerifyEmailRequestModelCopyWithImpl<$Res>
    implements $VerifyEmailRequestModelCopyWith<$Res> {
  _$VerifyEmailRequestModelCopyWithImpl(this._self, this._then);

  final VerifyEmailRequestModel _self;
  final $Res Function(VerifyEmailRequestModel) _then;

/// Create a copy of VerifyEmailRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VerifyEmailRequestModel].
extension VerifyEmailRequestModelPatterns on VerifyEmailRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyEmailRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyEmailRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyEmailRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyEmailRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyEmailRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyEmailRequestModel() when $default != null:
return $default(_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token)  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestModel():
return $default(_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token)?  $default,) {final _that = this;
switch (_that) {
case _VerifyEmailRequestModel() when $default != null:
return $default(_that.token);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _VerifyEmailRequestModel extends VerifyEmailRequestModel {
  const _VerifyEmailRequestModel({required this.token}): super._();
  factory _VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestModelFromJson(json);

@override final  String token;

/// Create a copy of VerifyEmailRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyEmailRequestModelCopyWith<_VerifyEmailRequestModel> get copyWith => __$VerifyEmailRequestModelCopyWithImpl<_VerifyEmailRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerifyEmailRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyEmailRequestModel&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'VerifyEmailRequestModel(token: $token)';
}


}

/// @nodoc
abstract mixin class _$VerifyEmailRequestModelCopyWith<$Res> implements $VerifyEmailRequestModelCopyWith<$Res> {
  factory _$VerifyEmailRequestModelCopyWith(_VerifyEmailRequestModel value, $Res Function(_VerifyEmailRequestModel) _then) = __$VerifyEmailRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String token
});




}
/// @nodoc
class __$VerifyEmailRequestModelCopyWithImpl<$Res>
    implements _$VerifyEmailRequestModelCopyWith<$Res> {
  __$VerifyEmailRequestModelCopyWithImpl(this._self, this._then);

  final _VerifyEmailRequestModel _self;
  final $Res Function(_VerifyEmailRequestModel) _then;

/// Create a copy of VerifyEmailRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_VerifyEmailRequestModel(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
