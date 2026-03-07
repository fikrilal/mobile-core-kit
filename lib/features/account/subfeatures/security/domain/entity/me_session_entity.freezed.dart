// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeSessionEntity {

 String get id; String? get deviceId; String? get deviceName; String? get ip; String? get userAgent; DateTime get lastSeenAt; DateTime get createdAt; DateTime get expiresAt; DateTime? get revokedAt; bool get current; MeSessionStatus get status;
/// Create a copy of MeSessionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeSessionEntityCopyWith<MeSessionEntity> get copyWith => _$MeSessionEntityCopyWithImpl<MeSessionEntity>(this as MeSessionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeSessionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,ip,userAgent,lastSeenAt,createdAt,expiresAt,revokedAt,current,status);

@override
String toString() {
  return 'MeSessionEntity(id: $id, deviceId: $deviceId, deviceName: $deviceName, ip: $ip, userAgent: $userAgent, lastSeenAt: $lastSeenAt, createdAt: $createdAt, expiresAt: $expiresAt, revokedAt: $revokedAt, current: $current, status: $status)';
}


}

/// @nodoc
abstract mixin class $MeSessionEntityCopyWith<$Res>  {
  factory $MeSessionEntityCopyWith(MeSessionEntity value, $Res Function(MeSessionEntity) _then) = _$MeSessionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String? deviceId, String? deviceName, String? ip, String? userAgent, DateTime lastSeenAt, DateTime createdAt, DateTime expiresAt, DateTime? revokedAt, bool current, MeSessionStatus status
});




}
/// @nodoc
class _$MeSessionEntityCopyWithImpl<$Res>
    implements $MeSessionEntityCopyWith<$Res> {
  _$MeSessionEntityCopyWithImpl(this._self, this._then);

  final MeSessionEntity _self;
  final $Res Function(MeSessionEntity) _then;

/// Create a copy of MeSessionEntity
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
as MeSessionStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MeSessionEntity].
extension MeSessionEntityPatterns on MeSessionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeSessionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeSessionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeSessionEntity value)  $default,){
final _that = this;
switch (_that) {
case _MeSessionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeSessionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MeSessionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeSessionEntity() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatus status)  $default,) {final _that = this;
switch (_that) {
case _MeSessionEntity():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? deviceId,  String? deviceName,  String? ip,  String? userAgent,  DateTime lastSeenAt,  DateTime createdAt,  DateTime expiresAt,  DateTime? revokedAt,  bool current,  MeSessionStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MeSessionEntity() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.ip,_that.userAgent,_that.lastSeenAt,_that.createdAt,_that.expiresAt,_that.revokedAt,_that.current,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _MeSessionEntity implements MeSessionEntity {
  const _MeSessionEntity({required this.id, this.deviceId, this.deviceName, this.ip, this.userAgent, required this.lastSeenAt, required this.createdAt, required this.expiresAt, this.revokedAt, required this.current, required this.status});
  

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
@override final  MeSessionStatus status;

/// Create a copy of MeSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeSessionEntityCopyWith<_MeSessionEntity> get copyWith => __$MeSessionEntityCopyWithImpl<_MeSessionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeSessionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt)&&(identical(other.current, current) || other.current == current)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,ip,userAgent,lastSeenAt,createdAt,expiresAt,revokedAt,current,status);

@override
String toString() {
  return 'MeSessionEntity(id: $id, deviceId: $deviceId, deviceName: $deviceName, ip: $ip, userAgent: $userAgent, lastSeenAt: $lastSeenAt, createdAt: $createdAt, expiresAt: $expiresAt, revokedAt: $revokedAt, current: $current, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MeSessionEntityCopyWith<$Res> implements $MeSessionEntityCopyWith<$Res> {
  factory _$MeSessionEntityCopyWith(_MeSessionEntity value, $Res Function(_MeSessionEntity) _then) = __$MeSessionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String? deviceId, String? deviceName, String? ip, String? userAgent, DateTime lastSeenAt, DateTime createdAt, DateTime expiresAt, DateTime? revokedAt, bool current, MeSessionStatus status
});




}
/// @nodoc
class __$MeSessionEntityCopyWithImpl<$Res>
    implements _$MeSessionEntityCopyWith<$Res> {
  __$MeSessionEntityCopyWithImpl(this._self, this._then);

  final _MeSessionEntity _self;
  final $Res Function(_MeSessionEntity) _then;

/// Create a copy of MeSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = freezed,Object? deviceName = freezed,Object? ip = freezed,Object? userAgent = freezed,Object? lastSeenAt = null,Object? createdAt = null,Object? expiresAt = null,Object? revokedAt = freezed,Object? current = null,Object? status = null,}) {
  return _then(_MeSessionEntity(
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
as MeSessionStatus,
  ));
}


}

/// @nodoc
mixin _$MeSessionsPageEntity {

 List<MeSessionEntity> get items; String? get nextCursor; int? get limit; bool get hasMore;
/// Create a copy of MeSessionsPageEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeSessionsPageEntityCopyWith<MeSessionsPageEntity> get copyWith => _$MeSessionsPageEntityCopyWithImpl<MeSessionsPageEntity>(this as MeSessionsPageEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeSessionsPageEntity&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor,limit,hasMore);

@override
String toString() {
  return 'MeSessionsPageEntity(items: $items, nextCursor: $nextCursor, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $MeSessionsPageEntityCopyWith<$Res>  {
  factory $MeSessionsPageEntityCopyWith(MeSessionsPageEntity value, $Res Function(MeSessionsPageEntity) _then) = _$MeSessionsPageEntityCopyWithImpl;
@useResult
$Res call({
 List<MeSessionEntity> items, String? nextCursor, int? limit, bool hasMore
});




}
/// @nodoc
class _$MeSessionsPageEntityCopyWithImpl<$Res>
    implements $MeSessionsPageEntityCopyWith<$Res> {
  _$MeSessionsPageEntityCopyWithImpl(this._self, this._then);

  final MeSessionsPageEntity _self;
  final $Res Function(MeSessionsPageEntity) _then;

/// Create a copy of MeSessionsPageEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,Object? limit = freezed,Object? hasMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MeSessionEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MeSessionsPageEntity].
extension MeSessionsPageEntityPatterns on MeSessionsPageEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeSessionsPageEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeSessionsPageEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeSessionsPageEntity value)  $default,){
final _that = this;
switch (_that) {
case _MeSessionsPageEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeSessionsPageEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MeSessionsPageEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MeSessionEntity> items,  String? nextCursor,  int? limit,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeSessionsPageEntity() when $default != null:
return $default(_that.items,_that.nextCursor,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MeSessionEntity> items,  String? nextCursor,  int? limit,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _MeSessionsPageEntity():
return $default(_that.items,_that.nextCursor,_that.limit,_that.hasMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MeSessionEntity> items,  String? nextCursor,  int? limit,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _MeSessionsPageEntity() when $default != null:
return $default(_that.items,_that.nextCursor,_that.limit,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc


class _MeSessionsPageEntity implements MeSessionsPageEntity {
  const _MeSessionsPageEntity({final  List<MeSessionEntity> items = const <MeSessionEntity>[], this.nextCursor, this.limit, this.hasMore = false}): _items = items;
  

 final  List<MeSessionEntity> _items;
@override@JsonKey() List<MeSessionEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? nextCursor;
@override final  int? limit;
@override@JsonKey() final  bool hasMore;

/// Create a copy of MeSessionsPageEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeSessionsPageEntityCopyWith<_MeSessionsPageEntity> get copyWith => __$MeSessionsPageEntityCopyWithImpl<_MeSessionsPageEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeSessionsPageEntity&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor,limit,hasMore);

@override
String toString() {
  return 'MeSessionsPageEntity(items: $items, nextCursor: $nextCursor, limit: $limit, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$MeSessionsPageEntityCopyWith<$Res> implements $MeSessionsPageEntityCopyWith<$Res> {
  factory _$MeSessionsPageEntityCopyWith(_MeSessionsPageEntity value, $Res Function(_MeSessionsPageEntity) _then) = __$MeSessionsPageEntityCopyWithImpl;
@override @useResult
$Res call({
 List<MeSessionEntity> items, String? nextCursor, int? limit, bool hasMore
});




}
/// @nodoc
class __$MeSessionsPageEntityCopyWithImpl<$Res>
    implements _$MeSessionsPageEntityCopyWith<$Res> {
  __$MeSessionsPageEntityCopyWithImpl(this._self, this._then);

  final _MeSessionsPageEntity _self;
  final $Res Function(_MeSessionsPageEntity) _then;

/// Create a copy of MeSessionsPageEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,Object? limit = freezed,Object? hasMore = null,}) {
  return _then(_MeSessionsPageEntity(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MeSessionEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
