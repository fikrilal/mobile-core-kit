// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_image_upload_plan_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileImageUploadPlanEntity {

 String get fileId; ProfileImagePresignedUploadEntity get upload; DateTime get expiresAt;
/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageUploadPlanEntityCopyWith<ProfileImageUploadPlanEntity> get copyWith => _$ProfileImageUploadPlanEntityCopyWithImpl<ProfileImageUploadPlanEntity>(this as ProfileImageUploadPlanEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImageUploadPlanEntity&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,fileId,upload,expiresAt);

@override
String toString() {
  return 'ProfileImageUploadPlanEntity(fileId: $fileId, upload: $upload, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ProfileImageUploadPlanEntityCopyWith<$Res>  {
  factory $ProfileImageUploadPlanEntityCopyWith(ProfileImageUploadPlanEntity value, $Res Function(ProfileImageUploadPlanEntity) _then) = _$ProfileImageUploadPlanEntityCopyWithImpl;
@useResult
$Res call({
 String fileId, ProfileImagePresignedUploadEntity upload, DateTime expiresAt
});


$ProfileImagePresignedUploadEntityCopyWith<$Res> get upload;

}
/// @nodoc
class _$ProfileImageUploadPlanEntityCopyWithImpl<$Res>
    implements $ProfileImageUploadPlanEntityCopyWith<$Res> {
  _$ProfileImageUploadPlanEntityCopyWithImpl(this._self, this._then);

  final ProfileImageUploadPlanEntity _self;
  final $Res Function(ProfileImageUploadPlanEntity) _then;

/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,Object? upload = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as ProfileImagePresignedUploadEntity,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileImagePresignedUploadEntityCopyWith<$Res> get upload {
  
  return $ProfileImagePresignedUploadEntityCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileImageUploadPlanEntity].
extension ProfileImageUploadPlanEntityPatterns on ProfileImageUploadPlanEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImageUploadPlanEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImageUploadPlanEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImageUploadPlanEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileId,  ProfileImagePresignedUploadEntity upload,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity() when $default != null:
return $default(_that.fileId,_that.upload,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileId,  ProfileImagePresignedUploadEntity upload,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity():
return $default(_that.fileId,_that.upload,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileId,  ProfileImagePresignedUploadEntity upload,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanEntity() when $default != null:
return $default(_that.fileId,_that.upload,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileImageUploadPlanEntity implements ProfileImageUploadPlanEntity {
  const _ProfileImageUploadPlanEntity({required this.fileId, required this.upload, required this.expiresAt});
  

@override final  String fileId;
@override final  ProfileImagePresignedUploadEntity upload;
@override final  DateTime expiresAt;

/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageUploadPlanEntityCopyWith<_ProfileImageUploadPlanEntity> get copyWith => __$ProfileImageUploadPlanEntityCopyWithImpl<_ProfileImageUploadPlanEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImageUploadPlanEntity&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode => Object.hash(runtimeType,fileId,upload,expiresAt);

@override
String toString() {
  return 'ProfileImageUploadPlanEntity(fileId: $fileId, upload: $upload, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageUploadPlanEntityCopyWith<$Res> implements $ProfileImageUploadPlanEntityCopyWith<$Res> {
  factory _$ProfileImageUploadPlanEntityCopyWith(_ProfileImageUploadPlanEntity value, $Res Function(_ProfileImageUploadPlanEntity) _then) = __$ProfileImageUploadPlanEntityCopyWithImpl;
@override @useResult
$Res call({
 String fileId, ProfileImagePresignedUploadEntity upload, DateTime expiresAt
});


@override $ProfileImagePresignedUploadEntityCopyWith<$Res> get upload;

}
/// @nodoc
class __$ProfileImageUploadPlanEntityCopyWithImpl<$Res>
    implements _$ProfileImageUploadPlanEntityCopyWith<$Res> {
  __$ProfileImageUploadPlanEntityCopyWithImpl(this._self, this._then);

  final _ProfileImageUploadPlanEntity _self;
  final $Res Function(_ProfileImageUploadPlanEntity) _then;

/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,Object? upload = null,Object? expiresAt = null,}) {
  return _then(_ProfileImageUploadPlanEntity(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as ProfileImagePresignedUploadEntity,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ProfileImageUploadPlanEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileImagePresignedUploadEntityCopyWith<$Res> get upload {
  
  return $ProfileImagePresignedUploadEntityCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}

/// @nodoc
mixin _$ProfileImagePresignedUploadEntity {

 String get method; String get url; Map<String, String> get headers;
/// Create a copy of ProfileImagePresignedUploadEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImagePresignedUploadEntityCopyWith<ProfileImagePresignedUploadEntity> get copyWith => _$ProfileImagePresignedUploadEntityCopyWithImpl<ProfileImagePresignedUploadEntity>(this as ProfileImagePresignedUploadEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImagePresignedUploadEntity&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.headers, headers));
}


@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'ProfileImagePresignedUploadEntity(method: $method, url: $url, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $ProfileImagePresignedUploadEntityCopyWith<$Res>  {
  factory $ProfileImagePresignedUploadEntityCopyWith(ProfileImagePresignedUploadEntity value, $Res Function(ProfileImagePresignedUploadEntity) _then) = _$ProfileImagePresignedUploadEntityCopyWithImpl;
@useResult
$Res call({
 String method, String url, Map<String, String> headers
});




}
/// @nodoc
class _$ProfileImagePresignedUploadEntityCopyWithImpl<$Res>
    implements $ProfileImagePresignedUploadEntityCopyWith<$Res> {
  _$ProfileImagePresignedUploadEntityCopyWithImpl(this._self, this._then);

  final ProfileImagePresignedUploadEntity _self;
  final $Res Function(ProfileImagePresignedUploadEntity) _then;

/// Create a copy of ProfileImagePresignedUploadEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? url = null,Object? headers = null,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileImagePresignedUploadEntity].
extension ProfileImagePresignedUploadEntityPatterns on ProfileImagePresignedUploadEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImagePresignedUploadEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImagePresignedUploadEntity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImagePresignedUploadEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  String url,  Map<String, String> headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity() when $default != null:
return $default(_that.method,_that.url,_that.headers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  String url,  Map<String, String> headers)  $default,) {final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity():
return $default(_that.method,_that.url,_that.headers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  String url,  Map<String, String> headers)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImagePresignedUploadEntity() when $default != null:
return $default(_that.method,_that.url,_that.headers);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileImagePresignedUploadEntity implements ProfileImagePresignedUploadEntity {
  const _ProfileImagePresignedUploadEntity({required this.method, required this.url, required final  Map<String, String> headers}): _headers = headers;
  

@override final  String method;
@override final  String url;
 final  Map<String, String> _headers;
@override Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}


/// Create a copy of ProfileImagePresignedUploadEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImagePresignedUploadEntityCopyWith<_ProfileImagePresignedUploadEntity> get copyWith => __$ProfileImagePresignedUploadEntityCopyWithImpl<_ProfileImagePresignedUploadEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImagePresignedUploadEntity&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._headers, _headers));
}


@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'ProfileImagePresignedUploadEntity(method: $method, url: $url, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$ProfileImagePresignedUploadEntityCopyWith<$Res> implements $ProfileImagePresignedUploadEntityCopyWith<$Res> {
  factory _$ProfileImagePresignedUploadEntityCopyWith(_ProfileImagePresignedUploadEntity value, $Res Function(_ProfileImagePresignedUploadEntity) _then) = __$ProfileImagePresignedUploadEntityCopyWithImpl;
@override @useResult
$Res call({
 String method, String url, Map<String, String> headers
});




}
/// @nodoc
class __$ProfileImagePresignedUploadEntityCopyWithImpl<$Res>
    implements _$ProfileImagePresignedUploadEntityCopyWith<$Res> {
  __$ProfileImagePresignedUploadEntityCopyWithImpl(this._self, this._then);

  final _ProfileImagePresignedUploadEntity _self;
  final $Res Function(_ProfileImagePresignedUploadEntity) _then;

/// Create a copy of ProfileImagePresignedUploadEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? url = null,Object? headers = null,}) {
  return _then(_ProfileImagePresignedUploadEntity(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
