// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_profile_image_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadProfileImageRequestEntity {

 Uint8List get bytes; String get contentType; String? get idempotencyKey;
/// Create a copy of UploadProfileImageRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadProfileImageRequestEntityCopyWith<UploadProfileImageRequestEntity> get copyWith => _$UploadProfileImageRequestEntityCopyWithImpl<UploadProfileImageRequestEntity>(this as UploadProfileImageRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadProfileImageRequestEntity&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),contentType,idempotencyKey);

@override
String toString() {
  return 'UploadProfileImageRequestEntity(bytes: $bytes, contentType: $contentType, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class $UploadProfileImageRequestEntityCopyWith<$Res>  {
  factory $UploadProfileImageRequestEntityCopyWith(UploadProfileImageRequestEntity value, $Res Function(UploadProfileImageRequestEntity) _then) = _$UploadProfileImageRequestEntityCopyWithImpl;
@useResult
$Res call({
 Uint8List bytes, String contentType, String? idempotencyKey
});




}
/// @nodoc
class _$UploadProfileImageRequestEntityCopyWithImpl<$Res>
    implements $UploadProfileImageRequestEntityCopyWith<$Res> {
  _$UploadProfileImageRequestEntityCopyWithImpl(this._self, this._then);

  final UploadProfileImageRequestEntity _self;
  final $Res Function(UploadProfileImageRequestEntity) _then;

/// Create a copy of UploadProfileImageRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? contentType = null,Object? idempotencyKey = freezed,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadProfileImageRequestEntity].
extension UploadProfileImageRequestEntityPatterns on UploadProfileImageRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadProfileImageRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadProfileImageRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadProfileImageRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List bytes,  String contentType,  String? idempotencyKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity() when $default != null:
return $default(_that.bytes,_that.contentType,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List bytes,  String contentType,  String? idempotencyKey)  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity():
return $default(_that.bytes,_that.contentType,_that.idempotencyKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List bytes,  String contentType,  String? idempotencyKey)?  $default,) {final _that = this;
switch (_that) {
case _UploadProfileImageRequestEntity() when $default != null:
return $default(_that.bytes,_that.contentType,_that.idempotencyKey);case _:
  return null;

}
}

}

/// @nodoc


class _UploadProfileImageRequestEntity implements UploadProfileImageRequestEntity {
  const _UploadProfileImageRequestEntity({required this.bytes, required this.contentType, this.idempotencyKey});
  

@override final  Uint8List bytes;
@override final  String contentType;
@override final  String? idempotencyKey;

/// Create a copy of UploadProfileImageRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadProfileImageRequestEntityCopyWith<_UploadProfileImageRequestEntity> get copyWith => __$UploadProfileImageRequestEntityCopyWithImpl<_UploadProfileImageRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadProfileImageRequestEntity&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),contentType,idempotencyKey);

@override
String toString() {
  return 'UploadProfileImageRequestEntity(bytes: $bytes, contentType: $contentType, idempotencyKey: $idempotencyKey)';
}


}

/// @nodoc
abstract mixin class _$UploadProfileImageRequestEntityCopyWith<$Res> implements $UploadProfileImageRequestEntityCopyWith<$Res> {
  factory _$UploadProfileImageRequestEntityCopyWith(_UploadProfileImageRequestEntity value, $Res Function(_UploadProfileImageRequestEntity) _then) = __$UploadProfileImageRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 Uint8List bytes, String contentType, String? idempotencyKey
});




}
/// @nodoc
class __$UploadProfileImageRequestEntityCopyWithImpl<$Res>
    implements _$UploadProfileImageRequestEntityCopyWith<$Res> {
  __$UploadProfileImageRequestEntityCopyWithImpl(this._self, this._then);

  final _UploadProfileImageRequestEntity _self;
  final $Res Function(_UploadProfileImageRequestEntity) _then;

/// Create a copy of UploadProfileImageRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? contentType = null,Object? idempotencyKey = freezed,}) {
  return _then(_UploadProfileImageRequestEntity(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as Uint8List,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
