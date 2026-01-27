// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complete_profile_image_upload_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompleteProfileImageUploadRequestEntity {

 String get fileId;
/// Create a copy of CompleteProfileImageUploadRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompleteProfileImageUploadRequestEntityCopyWith<CompleteProfileImageUploadRequestEntity> get copyWith => _$CompleteProfileImageUploadRequestEntityCopyWithImpl<CompleteProfileImageUploadRequestEntity>(this as CompleteProfileImageUploadRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompleteProfileImageUploadRequestEntity&&(identical(other.fileId, fileId) || other.fileId == fileId));
}


@override
int get hashCode => Object.hash(runtimeType,fileId);

@override
String toString() {
  return 'CompleteProfileImageUploadRequestEntity(fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class $CompleteProfileImageUploadRequestEntityCopyWith<$Res>  {
  factory $CompleteProfileImageUploadRequestEntityCopyWith(CompleteProfileImageUploadRequestEntity value, $Res Function(CompleteProfileImageUploadRequestEntity) _then) = _$CompleteProfileImageUploadRequestEntityCopyWithImpl;
@useResult
$Res call({
 String fileId
});




}
/// @nodoc
class _$CompleteProfileImageUploadRequestEntityCopyWithImpl<$Res>
    implements $CompleteProfileImageUploadRequestEntityCopyWith<$Res> {
  _$CompleteProfileImageUploadRequestEntityCopyWithImpl(this._self, this._then);

  final CompleteProfileImageUploadRequestEntity _self;
  final $Res Function(CompleteProfileImageUploadRequestEntity) _then;

/// Create a copy of CompleteProfileImageUploadRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompleteProfileImageUploadRequestEntity].
extension CompleteProfileImageUploadRequestEntityPatterns on CompleteProfileImageUploadRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompleteProfileImageUploadRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompleteProfileImageUploadRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompleteProfileImageUploadRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CompleteProfileImageUploadRequestEntity() when $default != null:
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
case _CompleteProfileImageUploadRequestEntity() when $default != null:
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
case _CompleteProfileImageUploadRequestEntity():
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
case _CompleteProfileImageUploadRequestEntity() when $default != null:
return $default(_that.fileId);case _:
  return null;

}
}

}

/// @nodoc


class _CompleteProfileImageUploadRequestEntity implements CompleteProfileImageUploadRequestEntity {
  const _CompleteProfileImageUploadRequestEntity({required this.fileId});
  

@override final  String fileId;

/// Create a copy of CompleteProfileImageUploadRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompleteProfileImageUploadRequestEntityCopyWith<_CompleteProfileImageUploadRequestEntity> get copyWith => __$CompleteProfileImageUploadRequestEntityCopyWithImpl<_CompleteProfileImageUploadRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompleteProfileImageUploadRequestEntity&&(identical(other.fileId, fileId) || other.fileId == fileId));
}


@override
int get hashCode => Object.hash(runtimeType,fileId);

@override
String toString() {
  return 'CompleteProfileImageUploadRequestEntity(fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class _$CompleteProfileImageUploadRequestEntityCopyWith<$Res> implements $CompleteProfileImageUploadRequestEntityCopyWith<$Res> {
  factory _$CompleteProfileImageUploadRequestEntityCopyWith(_CompleteProfileImageUploadRequestEntity value, $Res Function(_CompleteProfileImageUploadRequestEntity) _then) = __$CompleteProfileImageUploadRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String fileId
});




}
/// @nodoc
class __$CompleteProfileImageUploadRequestEntityCopyWithImpl<$Res>
    implements _$CompleteProfileImageUploadRequestEntityCopyWith<$Res> {
  __$CompleteProfileImageUploadRequestEntityCopyWithImpl(this._self, this._then);

  final _CompleteProfileImageUploadRequestEntity _self;
  final $Res Function(_CompleteProfileImageUploadRequestEntity) _then;

/// Create a copy of CompleteProfileImageUploadRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,}) {
  return _then(_CompleteProfileImageUploadRequestEntity(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
