// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_profile_image_upload_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompleteProfileImageUploadRequestModel {

 String get fileId;
/// Create a copy of CompleteProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompleteProfileImageUploadRequestModelCopyWith<CompleteProfileImageUploadRequestModel> get copyWith => _$CompleteProfileImageUploadRequestModelCopyWithImpl<CompleteProfileImageUploadRequestModel>(this as CompleteProfileImageUploadRequestModel, _$identity);

  /// Serializes this CompleteProfileImageUploadRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompleteProfileImageUploadRequestModel&&(identical(other.fileId, fileId) || other.fileId == fileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId);

@override
String toString() {
  return 'CompleteProfileImageUploadRequestModel(fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class $CompleteProfileImageUploadRequestModelCopyWith<$Res>  {
  factory $CompleteProfileImageUploadRequestModelCopyWith(CompleteProfileImageUploadRequestModel value, $Res Function(CompleteProfileImageUploadRequestModel) _then) = _$CompleteProfileImageUploadRequestModelCopyWithImpl;
@useResult
$Res call({
 String fileId
});




}
/// @nodoc
class _$CompleteProfileImageUploadRequestModelCopyWithImpl<$Res>
    implements $CompleteProfileImageUploadRequestModelCopyWith<$Res> {
  _$CompleteProfileImageUploadRequestModelCopyWithImpl(this._self, this._then);

  final CompleteProfileImageUploadRequestModel _self;
  final $Res Function(CompleteProfileImageUploadRequestModel) _then;

/// Create a copy of CompleteProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompleteProfileImageUploadRequestModel].
extension CompleteProfileImageUploadRequestModelPatterns on CompleteProfileImageUploadRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompleteProfileImageUploadRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompleteProfileImageUploadRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompleteProfileImageUploadRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel() when $default != null:
return $default(_that.fileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileId)  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel():
return $default(_that.fileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileId)?  $default,) {final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestModel() when $default != null:
return $default(_that.fileId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CompleteProfileImageUploadRequestModel extends CompleteProfileImageUploadRequestModel {
  const _CompleteProfileImageUploadRequestModel({required this.fileId}): super._();
  factory _CompleteProfileImageUploadRequestModel.fromJson(Map<String, dynamic> json) => _$CompleteProfileImageUploadRequestModelFromJson(json);

@override final  String fileId;

/// Create a copy of CompleteProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompleteProfileImageUploadRequestModelCopyWith<_CompleteProfileImageUploadRequestModel> get copyWith => __$CompleteProfileImageUploadRequestModelCopyWithImpl<_CompleteProfileImageUploadRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompleteProfileImageUploadRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompleteProfileImageUploadRequestModel&&(identical(other.fileId, fileId) || other.fileId == fileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId);

@override
String toString() {
  return 'CompleteProfileImageUploadRequestModel(fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class _$CompleteProfileImageUploadRequestModelCopyWith<$Res> implements $CompleteProfileImageUploadRequestModelCopyWith<$Res> {
  factory _$CompleteProfileImageUploadRequestModelCopyWith(_CompleteProfileImageUploadRequestModel value, $Res Function(_CompleteProfileImageUploadRequestModel) _then) = __$CompleteProfileImageUploadRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String fileId
});




}
/// @nodoc
class __$CompleteProfileImageUploadRequestModelCopyWithImpl<$Res>
    implements _$CompleteProfileImageUploadRequestModelCopyWith<$Res> {
  __$CompleteProfileImageUploadRequestModelCopyWithImpl(this._self, this._then);

  final _CompleteProfileImageUploadRequestModel _self;
  final $Res Function(_CompleteProfileImageUploadRequestModel) _then;

/// Create a copy of CompleteProfileImageUploadRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,}) {
  return _then(_CompleteProfileImageUploadRequestModel(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
