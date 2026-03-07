// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_profile_image_upload_plan_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateProfileImageUploadPlanRequestEntity {

 String get contentType; int get sizeBytes; String? get idempotencyKey;
/// Create a copy of CreateProfileImageUploadPlanRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateProfileImageUploadPlanRequestEntityCopyWith<CreateProfileImageUploadPlanRequestEntity> get copyWith => _$CreateProfileImageUploadPlanRequestEntityCopyWithImpl<CreateProfileImageUploadPlanRequestEntity>(this as CreateProfileImageUploadPlanRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateProfileImageUploadPlanRequestEntity&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,sizeBytes,idempotencyKey);

@override
String toString() {
  return 'CreateProfileImageUploadPlanRequestEntity(contentType: $contentType, sizeBytes: $sizeBytes, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $CreateProfileImageUploadPlanRequestEntityCopyWith<$Res>  {
  factory $CreateProfileImageUploadPlanRequestEntityCopyWith(CreateProfileImageUploadPlanRequestEntity value, $Res Function(CreateProfileImageUploadPlanRequestEntity) _then) = _$CreateProfileImageUploadPlanRequestEntityCopyWithImpl;
@useResult
$Res call({
 String contentType, int sizeBytes, String? idempotencyKey
});




}
/// @nodoc
class _$CreateProfileImageUploadPlanRequestEntityCopyWithImpl<$Res>
    implements $CreateProfileImageUploadPlanRequestEntityCopyWith<$Res> {
  _$CreateProfileImageUploadPlanRequestEntityCopyWithImpl(this._self, this._then);

  final CreateProfileImageUploadPlanRequestEntity _self;
  final $Res Function(CreateProfileImageUploadPlanRequestEntity) _then;

/// Create a copy of CreateProfileImageUploadPlanRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = null,Object? sizeBytes = null,Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateProfileImageUploadPlanRequestEntity].
extension CreateProfileImageUploadPlanRequestEntityPatterns on CreateProfileImageUploadPlanRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateProfileImageUploadPlanRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateProfileImageUploadPlanRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateProfileImageUploadPlanRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contentType,  int sizeBytes,  String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity() when $default != null:
return $default(_that.contentType,_that.sizeBytes,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contentType,  int sizeBytes,  String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity():
return $default(_that.contentType,_that.sizeBytes,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contentType,  int sizeBytes,  String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _CreateProfileImageUploadPlanRequestEntity() when $default != null:
return $default(_that.contentType,_that.sizeBytes,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _CreateProfileImageUploadPlanRequestEntity implements CreateProfileImageUploadPlanRequestEntity {
  const _CreateProfileImageUploadPlanRequestEntity({required this.contentType, required this.sizeBytes, this.idempotencyKey});
  

@override final  String contentType;
@override final  int sizeBytes;
@override final  String? idempotencyKey;

/// Create a copy of CreateProfileImageUploadPlanRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateProfileImageUploadPlanRequestEntityCopyWith<_CreateProfileImageUploadPlanRequestEntity> get copyWith => __$CreateProfileImageUploadPlanRequestEntityCopyWithImpl<_CreateProfileImageUploadPlanRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateProfileImageUploadPlanRequestEntity&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,contentType,sizeBytes,idempotencyKey);

@override
String toString() {
  return 'CreateProfileImageUploadPlanRequestEntity(contentType: $contentType, sizeBytes: $sizeBytes, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$CreateProfileImageUploadPlanRequestEntityCopyWith<$Res> implements $CreateProfileImageUploadPlanRequestEntityCopyWith<$Res> {
  factory _$CreateProfileImageUploadPlanRequestEntityCopyWith(_CreateProfileImageUploadPlanRequestEntity value, $Res Function(_CreateProfileImageUploadPlanRequestEntity) _then) = __$CreateProfileImageUploadPlanRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 String contentType, int sizeBytes, String? idempotencyKey
});




}
/// @nodoc
class __$CreateProfileImageUploadPlanRequestEntityCopyWithImpl<$Res>
    implements _$CreateProfileImageUploadPlanRequestEntityCopyWith<$Res> {
  __$CreateProfileImageUploadPlanRequestEntityCopyWithImpl(this._self, this._then);

  final _CreateProfileImageUploadPlanRequestEntity _self;
  final $Res Function(_CreateProfileImageUploadPlanRequestEntity) _then;

/// Create a copy of CreateProfileImageUploadPlanRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = null,Object? sizeBytes = null,Object? idempotencyKey = freezed,}) {
  return _then(_CreateProfileImageUploadPlanRequestEntity(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
