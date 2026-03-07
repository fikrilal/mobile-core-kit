// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patch_me_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatchMeRequestModel {

 PatchMeProfileModel get profile;
/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchMeRequestModelCopyWith<PatchMeRequestModel> get copyWith => _$PatchMeRequestModelCopyWithImpl<PatchMeRequestModel>(this as PatchMeRequestModel, _$identity);

  /// Serializes this PatchMeRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchMeRequestModel&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'PatchMeRequestModel(profile: $profile)';
}


}

/// @nodoc
abstract mixin class $PatchMeRequestModelCopyWith<$Res>  {
  factory $PatchMeRequestModelCopyWith(PatchMeRequestModel value, $Res Function(PatchMeRequestModel) _then) = _$PatchMeRequestModelCopyWithImpl;
@useResult
$Res call({
 PatchMeProfileModel profile
});


$PatchMeProfileModelCopyWith<$Res> get profile;

}
/// @nodoc
class _$PatchMeRequestModelCopyWithImpl<$Res>
    implements $PatchMeRequestModelCopyWith<$Res> {
  _$PatchMeRequestModelCopyWithImpl(this._self, this._then);

  final PatchMeRequestModel _self;
  final $Res Function(PatchMeRequestModel) _then;

/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as PatchMeProfileModel,
  ));
}
/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchMeProfileModelCopyWith<$Res> get profile {
  
  return $PatchMeProfileModelCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [PatchMeRequestModel].
extension PatchMeRequestModelPatterns on PatchMeRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchMeRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchMeRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchMeRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _PatchMeRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchMeRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _PatchMeRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PatchMeProfileModel profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchMeRequestModel() when $default != null:
return $default(_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PatchMeProfileModel profile)  $default,) {final _that = this;
switch (_that) {
case _PatchMeRequestModel():
return $default(_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PatchMeProfileModel profile)?  $default,) {final _that = this;
switch (_that) {
case _PatchMeRequestModel() when $default != null:
return $default(_that.profile);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class _PatchMeRequestModel extends PatchMeRequestModel {
  const _PatchMeRequestModel({required this.profile}): super._();
  factory _PatchMeRequestModel.fromJson(Map<String, dynamic> json) => _$PatchMeRequestModelFromJson(json);

@override final  PatchMeProfileModel profile;

/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchMeRequestModelCopyWith<_PatchMeRequestModel> get copyWith => __$PatchMeRequestModelCopyWithImpl<_PatchMeRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatchMeRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchMeRequestModel&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'PatchMeRequestModel(profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$PatchMeRequestModelCopyWith<$Res> implements $PatchMeRequestModelCopyWith<$Res> {
  factory _$PatchMeRequestModelCopyWith(_PatchMeRequestModel value, $Res Function(_PatchMeRequestModel) _then) = __$PatchMeRequestModelCopyWithImpl;
@override @useResult
$Res call({
 PatchMeProfileModel profile
});


@override $PatchMeProfileModelCopyWith<$Res> get profile;

}
/// @nodoc
class __$PatchMeRequestModelCopyWithImpl<$Res>
    implements _$PatchMeRequestModelCopyWith<$Res> {
  __$PatchMeRequestModelCopyWithImpl(this._self, this._then);

  final _PatchMeRequestModel _self;
  final $Res Function(_PatchMeRequestModel) _then;

/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,}) {
  return _then(_PatchMeRequestModel(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as PatchMeProfileModel,
  ));
}

/// Create a copy of PatchMeRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchMeProfileModelCopyWith<$Res> get profile {
  
  return $PatchMeProfileModelCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$PatchMeProfileModel {

 String? get displayName; String? get givenName; String? get familyName;
/// Create a copy of PatchMeProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchMeProfileModelCopyWith<PatchMeProfileModel> get copyWith => _$PatchMeProfileModelCopyWithImpl<PatchMeProfileModel>(this as PatchMeProfileModel, _$identity);

  /// Serializes this PatchMeProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchMeProfileModel&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,givenName,familyName);

@override
String toString() {
  return 'PatchMeProfileModel(displayName: $displayName, givenName: $givenName, familyName: $familyName)';
}


}

/// @nodoc
abstract mixin class $PatchMeProfileModelCopyWith<$Res>  {
  factory $PatchMeProfileModelCopyWith(PatchMeProfileModel value, $Res Function(PatchMeProfileModel) _then) = _$PatchMeProfileModelCopyWithImpl;
@useResult
$Res call({
 String? displayName, String? givenName, String? familyName
});




}
/// @nodoc
class _$PatchMeProfileModelCopyWithImpl<$Res>
    implements $PatchMeProfileModelCopyWith<$Res> {
  _$PatchMeProfileModelCopyWithImpl(this._self, this._then);

  final PatchMeProfileModel _self;
  final $Res Function(PatchMeProfileModel) _then;

/// Create a copy of PatchMeProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,}) {
  return _then(_self.copyWith(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatchMeProfileModel].
extension PatchMeProfileModelPatterns on PatchMeProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchMeProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchMeProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchMeProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _PatchMeProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchMeProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _PatchMeProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? displayName,  String? givenName,  String? familyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchMeProfileModel() when $default != null:
return $default(_that.displayName,_that.givenName,_that.familyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? displayName,  String? givenName,  String? familyName)  $default,) {final _that = this;
switch (_that) {
case _PatchMeProfileModel():
return $default(_that.displayName,_that.givenName,_that.familyName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? displayName,  String? givenName,  String? familyName)?  $default,) {final _that = this;
switch (_that) {
case _PatchMeProfileModel() when $default != null:
return $default(_that.displayName,_that.givenName,_that.familyName);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _PatchMeProfileModel extends PatchMeProfileModel {
  const _PatchMeProfileModel({this.displayName, this.givenName, this.familyName}): super._();
  factory _PatchMeProfileModel.fromJson(Map<String, dynamic> json) => _$PatchMeProfileModelFromJson(json);

@override final  String? displayName;
@override final  String? givenName;
@override final  String? familyName;

/// Create a copy of PatchMeProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchMeProfileModelCopyWith<_PatchMeProfileModel> get copyWith => __$PatchMeProfileModelCopyWithImpl<_PatchMeProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatchMeProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchMeProfileModel&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,givenName,familyName);

@override
String toString() {
  return 'PatchMeProfileModel(displayName: $displayName, givenName: $givenName, familyName: $familyName)';
}


}

/// @nodoc
abstract mixin class _$PatchMeProfileModelCopyWith<$Res> implements $PatchMeProfileModelCopyWith<$Res> {
  factory _$PatchMeProfileModelCopyWith(_PatchMeProfileModel value, $Res Function(_PatchMeProfileModel) _then) = __$PatchMeProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String? displayName, String? givenName, String? familyName
});




}
/// @nodoc
class __$PatchMeProfileModelCopyWithImpl<$Res>
    implements _$PatchMeProfileModelCopyWith<$Res> {
  __$PatchMeProfileModelCopyWithImpl(this._self, this._then);

  final _PatchMeProfileModel _self;
  final $Res Function(_PatchMeProfileModel) _then;

/// Create a copy of PatchMeProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,}) {
  return _then(_PatchMeProfileModel(
displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
