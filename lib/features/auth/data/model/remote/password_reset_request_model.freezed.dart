// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_reset_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PasswordResetRequestModel {

 String get email;
/// Create a copy of PasswordResetRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordResetRequestModelCopyWith<PasswordResetRequestModel> get copyWith => _$PasswordResetRequestModelCopyWithImpl<PasswordResetRequestModel>(this as PasswordResetRequestModel, _$identity);

  /// Serializes this PasswordResetRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetRequestModel&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'PasswordResetRequestModel(email: $email)';
}


}

/// @nodoc
abstract mixin class $PasswordResetRequestModelCopyWith<$Res>  {
  factory $PasswordResetRequestModelCopyWith(PasswordResetRequestModel value, $Res Function(PasswordResetRequestModel) _then) = _$PasswordResetRequestModelCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$PasswordResetRequestModelCopyWithImpl<$Res>
    implements $PasswordResetRequestModelCopyWith<$Res> {
  _$PasswordResetRequestModelCopyWithImpl(this._self, this._then);

  final PasswordResetRequestModel _self;
  final $Res Function(PasswordResetRequestModel) _then;

/// Create a copy of PasswordResetRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordResetRequestModel].
extension PasswordResetRequestModelPatterns on PasswordResetRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordResetRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordResetRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordResetRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordResetRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordResetRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordResetRequestModel() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequestModel():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _PasswordResetRequestModel() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _PasswordResetRequestModel extends PasswordResetRequestModel {
  const _PasswordResetRequestModel({required this.email}): super._();
  factory _PasswordResetRequestModel.fromJson(Map<String, dynamic> json) => _$PasswordResetRequestModelFromJson(json);

@override final  String email;

/// Create a copy of PasswordResetRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordResetRequestModelCopyWith<_PasswordResetRequestModel> get copyWith => __$PasswordResetRequestModelCopyWithImpl<_PasswordResetRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordResetRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordResetRequestModel&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'PasswordResetRequestModel(email: $email)';
}


}

/// @nodoc
abstract mixin class _$PasswordResetRequestModelCopyWith<$Res> implements $PasswordResetRequestModelCopyWith<$Res> {
  factory _$PasswordResetRequestModelCopyWith(_PasswordResetRequestModel value, $Res Function(_PasswordResetRequestModel) _then) = __$PasswordResetRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$PasswordResetRequestModelCopyWithImpl<$Res>
    implements _$PasswordResetRequestModelCopyWith<$Res> {
  __$PasswordResetRequestModelCopyWithImpl(this._self, this._then);

  final _PasswordResetRequestModel _self;
  final $Res Function(_PasswordResetRequestModel) _then;

/// Create a copy of PasswordResetRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_PasswordResetRequestModel(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
