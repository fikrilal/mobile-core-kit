// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oidc_exchange_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OidcExchangeRequestModel {

 String get provider; String get idToken;
/// Create a copy of OidcExchangeRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OidcExchangeRequestModelCopyWith<OidcExchangeRequestModel> get copyWith => _$OidcExchangeRequestModelCopyWithImpl<OidcExchangeRequestModel>(this as OidcExchangeRequestModel, _$identity);

  /// Serializes this OidcExchangeRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OidcExchangeRequestModel&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,idToken);

@override
String toString() {
  return 'OidcExchangeRequestModel(provider: $provider, idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class $OidcExchangeRequestModelCopyWith<$Res>  {
  factory $OidcExchangeRequestModelCopyWith(OidcExchangeRequestModel value, $Res Function(OidcExchangeRequestModel) _then) = _$OidcExchangeRequestModelCopyWithImpl;
@useResult
$Res call({
 String provider, String idToken
});




}
/// @nodoc
class _$OidcExchangeRequestModelCopyWithImpl<$Res>
    implements $OidcExchangeRequestModelCopyWith<$Res> {
  _$OidcExchangeRequestModelCopyWithImpl(this._self, this._then);

  final OidcExchangeRequestModel _self;
  final $Res Function(OidcExchangeRequestModel) _then;

/// Create a copy of OidcExchangeRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? idToken = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OidcExchangeRequestModel].
extension OidcExchangeRequestModelPatterns on OidcExchangeRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OidcExchangeRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OidcExchangeRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OidcExchangeRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _OidcExchangeRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OidcExchangeRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _OidcExchangeRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String idToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OidcExchangeRequestModel() when $default != null:
return $default(_that.provider,_that.idToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String idToken)  $default,) {final _that = this;
switch (_that) {
case _OidcExchangeRequestModel():
return $default(_that.provider,_that.idToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String idToken)?  $default,) {final _that = this;
switch (_that) {
case _OidcExchangeRequestModel() when $default != null:
return $default(_that.provider,_that.idToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OidcExchangeRequestModel extends OidcExchangeRequestModel {
  const _OidcExchangeRequestModel({required this.provider, required this.idToken}): super._();
  factory _OidcExchangeRequestModel.fromJson(Map<String, dynamic> json) => _$OidcExchangeRequestModelFromJson(json);

@override final  String provider;
@override final  String idToken;

/// Create a copy of OidcExchangeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OidcExchangeRequestModelCopyWith<_OidcExchangeRequestModel> get copyWith => __$OidcExchangeRequestModelCopyWithImpl<_OidcExchangeRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OidcExchangeRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OidcExchangeRequestModel&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,idToken);

@override
String toString() {
  return 'OidcExchangeRequestModel(provider: $provider, idToken: $idToken)';
}


}

/// @nodoc
abstract mixin class _$OidcExchangeRequestModelCopyWith<$Res> implements $OidcExchangeRequestModelCopyWith<$Res> {
  factory _$OidcExchangeRequestModelCopyWith(_OidcExchangeRequestModel value, $Res Function(_OidcExchangeRequestModel) _then) = __$OidcExchangeRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String provider, String idToken
});




}
/// @nodoc
class __$OidcExchangeRequestModelCopyWithImpl<$Res>
    implements _$OidcExchangeRequestModelCopyWith<$Res> {
  __$OidcExchangeRequestModelCopyWithImpl(this._self, this._then);

  final _OidcExchangeRequestModel _self;
  final $Res Function(_OidcExchangeRequestModel) _then;

/// Create a copy of OidcExchangeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? idToken = null,}) {
  return _then(_OidcExchangeRequestModel(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
