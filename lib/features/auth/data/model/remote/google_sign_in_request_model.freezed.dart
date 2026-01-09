// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'google_sign_in_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoogleSignInRequestModel {

 String get idToken;
/// Create a copy of GoogleSignInRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleSignInRequestModelCopyWith<GoogleSignInRequestModel> get copyWith => _$GoogleSignInRequestModelCopyWithImpl<GoogleSignInRequestModel>(this as GoogleSignInRequestModel, _$identity);

  /// Serializes this GoogleSignInRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleSignInRequestModel&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idToken);

@override
String toString() {
  return 'GoogleSignInRequestModel(idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class $GoogleSignInRequestModelCopyWith<$Res>  {
  factory $GoogleSignInRequestModelCopyWith(GoogleSignInRequestModel value, $Res Function(GoogleSignInRequestModel) _then) = _$GoogleSignInRequestModelCopyWithImpl;
@useResult
$Res call({
 String idToken
});




}
/// @nodoc
class _$GoogleSignInRequestModelCopyWithImpl<$Res>
    implements $GoogleSignInRequestModelCopyWith<$Res> {
  _$GoogleSignInRequestModelCopyWithImpl(this._self, this._then);

  final GoogleSignInRequestModel _self;
  final $Res Function(GoogleSignInRequestModel) _then;

/// Create a copy of GoogleSignInRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idToken = null,}) {
  return _then(_self.copyWith(
idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleSignInRequestModel].
extension GoogleSignInRequestModelPatterns on GoogleSignInRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleSignInRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleSignInRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleSignInRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleSignInRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String idToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleSignInRequestModel() when $default != null:
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String idToken)  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInRequestModel():
return $default(_that.idToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String idToken)?  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInRequestModel() when $default != null:
return $default(_that.idToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleSignInRequestModel extends GoogleSignInRequestModel {
  const _GoogleSignInRequestModel(this.idToken): super._();
  factory _GoogleSignInRequestModel.fromJson(Map<String, dynamic> json) => _$GoogleSignInRequestModelFromJson(json);

@override final  String idToken;

/// Create a copy of GoogleSignInRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleSignInRequestModelCopyWith<_GoogleSignInRequestModel> get copyWith => __$GoogleSignInRequestModelCopyWithImpl<_GoogleSignInRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleSignInRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleSignInRequestModel&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idToken);

@override
String toString() {
  return 'GoogleSignInRequestModel(idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class _$GoogleSignInRequestModelCopyWith<$Res> implements $GoogleSignInRequestModelCopyWith<$Res> {
  factory _$GoogleSignInRequestModelCopyWith(_GoogleSignInRequestModel value, $Res Function(_GoogleSignInRequestModel) _then) = __$GoogleSignInRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String idToken
});




}
/// @nodoc
class __$GoogleSignInRequestModelCopyWithImpl<$Res>
    implements _$GoogleSignInRequestModelCopyWith<$Res> {
  __$GoogleSignInRequestModelCopyWithImpl(this._self, this._then);

  final _GoogleSignInRequestModel _self;
  final $Res Function(_GoogleSignInRequestModel) _then;

/// Create a copy of GoogleSignInRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idToken = null,}) {
  return _then(_GoogleSignInRequestModel(
null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
