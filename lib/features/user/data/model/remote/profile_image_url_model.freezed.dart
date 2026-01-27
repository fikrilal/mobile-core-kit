// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_image_url_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileImageUrlModel {

 String get url; String get expiresAt;
/// Create a copy of ProfileImageUrlModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageUrlModelCopyWith<ProfileImageUrlModel> get copyWith => _$ProfileImageUrlModelCopyWithImpl<ProfileImageUrlModel>(this as ProfileImageUrlModel, _$identity);

  /// Serializes this ProfileImageUrlModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImageUrlModel&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'ProfileImageUrlModel(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ProfileImageUrlModelCopyWith<$Res>  {
  factory $ProfileImageUrlModelCopyWith(ProfileImageUrlModel value, $Res Function(ProfileImageUrlModel) _then) = _$ProfileImageUrlModelCopyWithImpl;
@useResult
$Res call({
 String url, String expiresAt
});




}
/// @nodoc
class _$ProfileImageUrlModelCopyWithImpl<$Res>
    implements $ProfileImageUrlModelCopyWith<$Res> {
  _$ProfileImageUrlModelCopyWithImpl(this._self, this._then);

  final ProfileImageUrlModel _self;
  final $Res Function(ProfileImageUrlModel) _then;

/// Create a copy of ProfileImageUrlModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileImageUrlModel].
extension ProfileImageUrlModelPatterns on ProfileImageUrlModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImageUrlModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImageUrlModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImageUrlModel value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUrlModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImageUrlModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUrlModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImageUrlModel() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUrlModel():
return $default(_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUrlModel() when $default != null:
return $default(_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _ProfileImageUrlModel extends ProfileImageUrlModel {
  const _ProfileImageUrlModel({required this.url, required this.expiresAt}): super._();
  factory _ProfileImageUrlModel.fromJson(Map<String, dynamic> json) => _$ProfileImageUrlModelFromJson(json);

@override final  String url;
@override final  String expiresAt;

/// Create a copy of ProfileImageUrlModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageUrlModelCopyWith<_ProfileImageUrlModel> get copyWith => __$ProfileImageUrlModelCopyWithImpl<_ProfileImageUrlModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileImageUrlModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImageUrlModel&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,expiresAt);

@override
String toString() {
  return 'ProfileImageUrlModel(url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageUrlModelCopyWith<$Res> implements $ProfileImageUrlModelCopyWith<$Res> {
  factory _$ProfileImageUrlModelCopyWith(_ProfileImageUrlModel value, $Res Function(_ProfileImageUrlModel) _then) = __$ProfileImageUrlModelCopyWithImpl;
@override @useResult
$Res call({
 String url, String expiresAt
});




}
/// @nodoc
class __$ProfileImageUrlModelCopyWithImpl<$Res>
    implements _$ProfileImageUrlModelCopyWith<$Res> {
  __$ProfileImageUrlModelCopyWithImpl(this._self, this._then);

  final _ProfileImageUrlModel _self;
  final $Res Function(_ProfileImageUrlModel) _then;

/// Create a copy of ProfileImageUrlModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? expiresAt = null,}) {
  return _then(_ProfileImageUrlModel(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
