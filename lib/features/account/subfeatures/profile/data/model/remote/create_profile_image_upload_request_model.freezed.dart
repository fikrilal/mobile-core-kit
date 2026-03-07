// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_profile_image_upload_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateProfileImageUploadRequestModel {

 String get contentType; int get sizeBytes;
/// Create a copy of CreateProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProfileImageUploadRequestModelCopyWith<CreateProfileImageUploadRequestModel> get copyWith => _$CreateProfileImageUploadRequestModelCopyWithImpl<CreateProfileImageUploadRequestModel>(this as CreateProfileImageUploadRequestModel, _$identity);

  /// Serializes this CreateProfileImageUploadRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProfileImageUploadRequestModel&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType,sizeBytes);

@override
String toString() {
  return 'CreateProfileImageUploadRequestModel(contentType: $contentType, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $CreateProfileImageUploadRequestModelCopyWith<$Res>  {
  factory $CreateProfileImageUploadRequestModelCopyWith(CreateProfileImageUploadRequestModel value, $Res Function(CreateProfileImageUploadRequestModel) _then) = _$CreateProfileImageUploadRequestModelCopyWithImpl;
@useResult
$Res call({
 String contentType, int sizeBytes
});




}
/// @nodoc
class _$CreateProfileImageUploadRequestModelCopyWithImpl<$Res>
    implements $CreateProfileImageUploadRequestModelCopyWith<$Res> {
  _$CreateProfileImageUploadRequestModelCopyWithImpl(this._self, this._then);

  final CreateProfileImageUploadRequestModel _self;
  final $Res Function(CreateProfileImageUploadRequestModel) _then;

/// Create a copy of CreateProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = null,Object? sizeBytes = null,}) {
  return _then(_self.copyWith(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProfileImageUploadRequestModel].
extension CreateProfileImageUploadRequestModelPatterns on CreateProfileImageUploadRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProfileImageUploadRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProfileImageUploadRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProfileImageUploadRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contentType,  int sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel() when $default != null:
return $default(_that.contentType,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contentType,  int sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel():
return $default(_that.contentType,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contentType,  int sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadRequestModel() when $default != null:
return $default(_that.contentType,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateProfileImageUploadRequestModel extends CreateProfileImageUploadRequestModel {
  const _CreateProfileImageUploadRequestModel({required this.contentType, required this.sizeBytes}): super._();
  factory _CreateProfileImageUploadRequestModel.fromJson(Map<String, dynamic> json) => _$CreateProfileImageUploadRequestModelFromJson(json);

@override final  String contentType;
@override final  int sizeBytes;

/// Create a copy of CreateProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProfileImageUploadRequestModelCopyWith<_CreateProfileImageUploadRequestModel> get copyWith => __$CreateProfileImageUploadRequestModelCopyWithImpl<_CreateProfileImageUploadRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateProfileImageUploadRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProfileImageUploadRequestModel&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType,sizeBytes);

@override
String toString() {
  return 'CreateProfileImageUploadRequestModel(contentType: $contentType, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$CreateProfileImageUploadRequestModelCopyWith<$Res> implements $CreateProfileImageUploadRequestModelCopyWith<$Res> {
  factory _$CreateProfileImageUploadRequestModelCopyWith(_CreateProfileImageUploadRequestModel value, $Res Function(_CreateProfileImageUploadRequestModel) _then) = __$CreateProfileImageUploadRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String contentType, int sizeBytes
});




}
/// @nodoc
class __$CreateProfileImageUploadRequestModelCopyWithImpl<$Res>
    implements _$CreateProfileImageUploadRequestModelCopyWith<$Res> {
  __$CreateProfileImageUploadRequestModelCopyWithImpl(this._self, this._then);

  final _CreateProfileImageUploadRequestModel _self;
  final $Res Function(_CreateProfileImageUploadRequestModel) _then;

/// Create a copy of CreateProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = null,Object? sizeBytes = null,}) {
  return _then(_CreateProfileImageUploadRequestModel(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
