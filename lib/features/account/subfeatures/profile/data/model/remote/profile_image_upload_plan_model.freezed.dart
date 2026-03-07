// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_image_upload_plan_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileImageUploadPlanModel {

 String get fileId; PresignedUploadModel get upload; String get expiresAt;
/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileImageUploadPlanModelCopyWith<ProfileImageUploadPlanModel> get copyWith => _$ProfileImageUploadPlanModelCopyWithImpl<ProfileImageUploadPlanModel>(this as ProfileImageUploadPlanModel, _$identity);

  /// Serializes this ProfileImageUploadPlanModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileImageUploadPlanModel&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,upload,expiresAt);

@override
String toString() {
  return 'ProfileImageUploadPlanModel(fileId: $fileId, upload: $upload, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ProfileImageUploadPlanModelCopyWith<$Res>  {
  factory $ProfileImageUploadPlanModelCopyWith(ProfileImageUploadPlanModel value, $Res Function(ProfileImageUploadPlanModel) _then) = _$ProfileImageUploadPlanModelCopyWithImpl;
@useResult
$Res call({
 String fileId, PresignedUploadModel upload, String expiresAt
});


$PresignedUploadModelCopyWith<$Res> get upload;

}
/// @nodoc
class _$ProfileImageUploadPlanModelCopyWithImpl<$Res>
    implements $ProfileImageUploadPlanModelCopyWith<$Res> {
  _$ProfileImageUploadPlanModelCopyWithImpl(this._self, this._then);

  final ProfileImageUploadPlanModel _self;
  final $Res Function(ProfileImageUploadPlanModel) _then;

/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,Object? upload = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as PresignedUploadModel,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresignedUploadModelCopyWith<$Res> get upload {
  
  return $PresignedUploadModelCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileImageUploadPlanModel].
extension ProfileImageUploadPlanModelPatterns on ProfileImageUploadPlanModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileImageUploadPlanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileImageUploadPlanModel value)  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileImageUploadPlanModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileId,  PresignedUploadModel upload,  String expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileId,  PresignedUploadModel upload,  String expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileId,  PresignedUploadModel upload,  String expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileImageUploadPlanModel() when $default != null:
return $default(_that.fileId,_that.upload,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class _ProfileImageUploadPlanModel extends ProfileImageUploadPlanModel {
  const _ProfileImageUploadPlanModel({required this.fileId, required this.upload, required this.expiresAt}): super._();
  factory _ProfileImageUploadPlanModel.fromJson(Map<String, dynamic> json) => _$ProfileImageUploadPlanModelFromJson(json);

@override final  String fileId;
@override final  PresignedUploadModel upload;
@override final  String expiresAt;

/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileImageUploadPlanModelCopyWith<_ProfileImageUploadPlanModel> get copyWith => __$ProfileImageUploadPlanModelCopyWithImpl<_ProfileImageUploadPlanModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileImageUploadPlanModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileImageUploadPlanModel&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fileId,upload,expiresAt);

@override
String toString() {
  return 'ProfileImageUploadPlanModel(fileId: $fileId, upload: $upload, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileImageUploadPlanModelCopyWith<$Res> implements $ProfileImageUploadPlanModelCopyWith<$Res> {
  factory _$ProfileImageUploadPlanModelCopyWith(_ProfileImageUploadPlanModel value, $Res Function(_ProfileImageUploadPlanModel) _then) = __$ProfileImageUploadPlanModelCopyWithImpl;
@override @useResult
$Res call({
 String fileId, PresignedUploadModel upload, String expiresAt
});


@override $PresignedUploadModelCopyWith<$Res> get upload;

}
/// @nodoc
class __$ProfileImageUploadPlanModelCopyWithImpl<$Res>
    implements _$ProfileImageUploadPlanModelCopyWith<$Res> {
  __$ProfileImageUploadPlanModelCopyWithImpl(this._self, this._then);

  final _ProfileImageUploadPlanModel _self;
  final $Res Function(_ProfileImageUploadPlanModel) _then;

/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,Object? upload = null,Object? expiresAt = null,}) {
  return _then(_ProfileImageUploadPlanModel(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as PresignedUploadModel,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ProfileImageUploadPlanModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresignedUploadModelCopyWith<$Res> get upload {
  
  return $PresignedUploadModelCopyWith<$Res>(_self.upload, (value) {
    return _then(_self.copyWith(upload: value));
  });
}
}


/// @nodoc
mixin _$PresignedUploadModel {

 String get method; String get url;@JsonKey(fromJson: _headersFromJson, toJson: _headersToJson) Map<String, String> get headers;
/// Create a copy of PresignedUploadModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresignedUploadModelCopyWith<PresignedUploadModel> get copyWith => _$PresignedUploadModelCopyWithImpl<PresignedUploadModel>(this as PresignedUploadModel, _$identity);

  /// Serializes this PresignedUploadModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresignedUploadModel&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'PresignedUploadModel(method: $method, url: $url, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $PresignedUploadModelCopyWith<$Res>  {
  factory $PresignedUploadModelCopyWith(PresignedUploadModel value, $Res Function(PresignedUploadModel) _then) = _$PresignedUploadModelCopyWithImpl;
@useResult
$Res call({
 String method, String url,@JsonKey(fromJson: _headersFromJson, toJson: _headersToJson) Map<String, String> headers
});




}
/// @nodoc
class _$PresignedUploadModelCopyWithImpl<$Res>
    implements $PresignedUploadModelCopyWith<$Res> {
  _$PresignedUploadModelCopyWithImpl(this._self, this._then);

  final PresignedUploadModel _self;
  final $Res Function(PresignedUploadModel) _then;

/// Create a copy of PresignedUploadModel
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


/// Adds pattern-matching-related methods to [PresignedUploadModel].
extension PresignedUploadModelPatterns on PresignedUploadModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresignedUploadModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresignedUploadModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresignedUploadModel value)  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresignedUploadModel value)?  $default,){
final _that = this;
switch (_that) {
case _PresignedUploadModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  String url, @JsonKey(fromJson: _headersFromJson, toJson: _headersToJson)  Map<String, String> headers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresignedUploadModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  String url, @JsonKey(fromJson: _headersFromJson, toJson: _headersToJson)  Map<String, String> headers)  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  String url, @JsonKey(fromJson: _headersFromJson, toJson: _headersToJson)  Map<String, String> headers)?  $default,) {final _that = this;
switch (_that) {
case _PresignedUploadModel() when $default != null:
return $default(_that.method,_that.url,_that.headers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _PresignedUploadModel extends PresignedUploadModel {
  const _PresignedUploadModel({required this.method, required this.url, @JsonKey(fromJson: _headersFromJson, toJson: _headersToJson) required final  Map<String, String> headers}): _headers = headers,super._();
  factory _PresignedUploadModel.fromJson(Map<String, dynamic> json) => _$PresignedUploadModelFromJson(json);

@override final  String method;
@override final  String url;
 final  Map<String, String> _headers;
@override@JsonKey(fromJson: _headersFromJson, toJson: _headersToJson) Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}


/// Create a copy of PresignedUploadModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresignedUploadModelCopyWith<_PresignedUploadModel> get copyWith => __$PresignedUploadModelCopyWithImpl<_PresignedUploadModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresignedUploadModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresignedUploadModel&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'PresignedUploadModel(method: $method, url: $url, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$PresignedUploadModelCopyWith<$Res> implements $PresignedUploadModelCopyWith<$Res> {
  factory _$PresignedUploadModelCopyWith(_PresignedUploadModel value, $Res Function(_PresignedUploadModel) _then) = __$PresignedUploadModelCopyWithImpl;
@override @useResult
$Res call({
 String method, String url,@JsonKey(fromJson: _headersFromJson, toJson: _headersToJson) Map<String, String> headers
});




}
/// @nodoc
class __$PresignedUploadModelCopyWithImpl<$Res>
    implements _$PresignedUploadModelCopyWith<$Res> {
  __$PresignedUploadModelCopyWithImpl(this._self, this._then);

  final _PresignedUploadModel _self;
  final $Res Function(_PresignedUploadModel) _then;

/// Create a copy of PresignedUploadModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? url = null,Object? headers = null,}) {
  return _then(_PresignedUploadModel(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
