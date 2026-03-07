// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeSessionModel {

 String get id; String? get deviceId; String? get deviceName; String? get ip; String? get userAgent; DateTime get lastSeenAt; DateTime get createdAt; DateTime get expiresAt; DateTime? get revokedAt; bool get current; MeSessionStatusModel get status;
/// Create a copy of MeSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeSessionModelCopyWith<MeSessionModel> get copyWith => _$MeSessionModelCopyWithImpl<MeSessionModel>(this as MeSessionModel, _$identity);

  /// Serializes this MeSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,ip,userAgent,lastSeenAt,createdAt,expiresAt,revokedAt,current,status);

@override
String toString() {
  return 'MeSessionModel(id: $id, deviceId: $deviceId, deviceName: $deviceName, ip: $ip, userAgent: $userAgent, lastSeenAt: $lastSeenAt, createdAt: $createdAt, expiresAt: $expiresAt, revokedAt: $revokedAt, current: $current, status: $status)';
}


}

/// @nodoc
abstract mixin class $MeSessionModelCopyWith<$Res>  {
  factory $MeSessionModelCopyWith(MeSessionModel value, $Res Function(MeSessionModel) _then) = _$MeSessionModelCopyWithImpl;
@useResult
$Res call({
 String id, String? deviceId, String? deviceName, String? ip, String? userAgent, DateTime lastSeenAt, DateTime createdAt, DateTime expiresAt, DateTime? revokedAt, bool current, MeSessionStatusModel status
});




}
/// @nodoc
class _$MeSessionModelCopyWithImpl<$Res>
    implements $MeSessionModelCopyWith<$Res> {
  _$MeSessionModelCopyWithImpl(this._self, this._then);

  final MeSessionModel _self;
  final $Res Function(MeSessionModel) _then;

/// Create a copy of MeSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = freezed,Object? deviceName = freezed,Object? ip = freezed,Object? userAgent = freezed,Object? lastSeenAt = null,Object? createdAt = null,Object? expiresAt = null,Object? revokedAt = freezed,Object? current = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,ip: freezed == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MeSessionStatusModel,
  ));
}

}


/// Adds pattern-matching-related methods to [MeSessionModel].
extension MeSessionModelPatterns on MeSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _MeSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatusModel status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeSessionModel() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.ip,_that.userAgent,_that.lastSeenAt,_that.createdAt,_that.expiresAt,_that.revokedAt,_that.current,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatusModel status)  $default,) {final _that = this;
switch (_that) {
case _MeSessionModel():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.ip,_that.userAgent,_that.lastSeenAt,_that.createdAt,_that.expiresAt,_that.revokedAt,_that.current,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatusModel status)?  $default,) {final _that = this;
switch (_that) {
case _MeSessionModel() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.ip,_that.userAgent,_that.lastSeenAt,_that.createdAt,_that.expiresAt,_that.revokedAt,_that.current,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _MeSessionModel extends MeSessionModel {
  const _MeSessionModel({required this.id, this.deviceId, this.deviceName, this.ip, this.userAgent, required this.lastSeenAt, required this.createdAt, required this.expiresAt, this.revokedAt, required this.current, required this.status}): super._();
  factory _MeSessionModel.fromJson(Map<String, dynamic> json) => _$MeSessionModelFromJson(json);

@override final  String id;
@override final  String? deviceId;
@override final  String? deviceName;
@override final  String? ip;
@override final  String? userAgent;
@override final  DateTime lastSeenAt;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override final  DateTime? revokedAt;
@override final  bool current;
@override final  MeSessionStatusModel status;

/// Create a copy of MeSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeSessionModelCopyWith<_MeSessionModel> get copyWith => __$MeSessionModelCopyWithImpl<_MeSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,ip,userAgent,lastSeenAt,createdAt,expiresAt,revokedAt,current,status);

@override
String toString() {
  return 'MeSessionModel(id: $id, deviceId: $deviceId, deviceName: $deviceName, ip: $ip, userAgent: $userAgent, lastSeenAt: $lastSeenAt, createdAt: $createdAt, expiresAt: $expiresAt, revokedAt: $revokedAt, current: $current, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MeSessionModelCopyWith<$Res> implements $MeSessionModelCopyWith<$Res> {
  factory _$MeSessionModelCopyWith(_MeSessionModel value, $Res Function(_MeSessionModel) _then) = __$MeSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? deviceId, String? deviceName, String? ip, String? userAgent, DateTime lastSeenAt, DateTime createdAt, DateTime expiresAt, DateTime? revokedAt, bool current, MeSessionStatusModel status
});




}
/// @nodoc
class __$MeSessionModelCopyWithImpl<$Res>
    implements _$MeSessionModelCopyWith<$Res> {
  __$MeSessionModelCopyWithImpl(this._self, this._then);

  final _MeSessionModel _self;
  final $Res Function(_MeSessionModel) _then;

/// Create a copy of MeSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = freezed,Object? deviceName = freezed,Object? ip = freezed,Object? userAgent = freezed,Object? lastSeenAt = null,Object? createdAt = null,Object? expiresAt = null,Object? revokedAt = freezed,Object? current = null,Object? status = null,}) {
  return _then(_MeSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,ip: freezed == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MeSessionStatusModel,
  ));
}


}

// dart format on
