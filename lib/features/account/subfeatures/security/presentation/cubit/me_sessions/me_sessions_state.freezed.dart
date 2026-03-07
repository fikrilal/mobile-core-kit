// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_sessions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MeSessionsState {

 MeSessionsStatus get status; List<MeSessionEntity> get sessions; String? get nextCursor; int? get limit; bool get hasMore; AuthFailure? get failure; MeSessionRevokeStatus get revokeStatus; String? get pendingRevokeSessionId; String? get lastRevokedSessionId; AuthFailure? get revokeFailure;
/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeSessionsStateCopyWith<MeSessionsState> get copyWith => _$MeSessionsStateCopyWithImpl<MeSessionsState>(this as MeSessionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeSessionsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.revokeStatus, revokeStatus) || other.revokeStatus == revokeStatus)&&(identical(other.pendingRevokeSessionId, pendingRevokeSessionId) || other.pendingRevokeSessionId == pendingRevokeSessionId)&&(identical(other.lastRevokedSessionId, lastRevokedSessionId) || other.lastRevokedSessionId == lastRevokedSessionId)&&(identical(other.revokeFailure, revokeFailure) || other.revokeFailure == revokeFailure));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(sessions),nextCursor,limit,hasMore,failure,revokeStatus,pendingRevokeSessionId,lastRevokedSessionId,revokeFailure);

@override
String toString() {
  return 'MeSessionsState(status: $status, sessions: $sessions, nextCursor: $nextCursor, limit: $limit, hasMore: $hasMore, failure: $failure, revokeStatus: $revokeStatus, pendingRevokeSessionId: $pendingRevokeSessionId, lastRevokedSessionId: $lastRevokedSessionId, revokeFailure: $revokeFailure)';
}


}

/// @nodoc
abstract mixin class $MeSessionsStateCopyWith<$Res>  {
  factory $MeSessionsStateCopyWith(MeSessionsState value, $Res Function(MeSessionsState) _then) = _$MeSessionsStateCopyWithImpl;
@useResult
$Res call({
 MeSessionsStatus status, List<MeSessionEntity> sessions, String? nextCursor, int? limit, bool hasMore, AuthFailure? failure, MeSessionRevokeStatus revokeStatus, String? pendingRevokeSessionId, String? lastRevokedSessionId, AuthFailure? revokeFailure
});


$AuthFailureCopyWith<$Res>? get failure;$AuthFailureCopyWith<$Res>? get revokeFailure;

}
/// @nodoc
class _$MeSessionsStateCopyWithImpl<$Res>
    implements $MeSessionsStateCopyWith<$Res> {
  _$MeSessionsStateCopyWithImpl(this._self, this._then);

  final MeSessionsState _self;
  final $Res Function(MeSessionsState) _then;

/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? sessions = null,Object? nextCursor = freezed,Object? limit = freezed,Object? hasMore = null,Object? failure = freezed,Object? revokeStatus = null,Object? pendingRevokeSessionId = freezed,Object? lastRevokedSessionId = freezed,Object? revokeFailure = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MeSessionsStatus,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<MeSessionEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,revokeStatus: null == revokeStatus ? _self.revokeStatus : revokeStatus // ignore: cast_nullable_to_non_nullable
as MeSessionRevokeStatus,pendingRevokeSessionId: freezed == pendingRevokeSessionId ? _self.pendingRevokeSessionId : pendingRevokeSessionId // ignore: cast_nullable_to_non_nullable
as String?,lastRevokedSessionId: freezed == lastRevokedSessionId ? _self.lastRevokedSessionId : lastRevokedSessionId // ignore: cast_nullable_to_non_nullable
as String?,revokeFailure: freezed == revokeFailure ? _self.revokeFailure : revokeFailure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}
/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get revokeFailure {
    if (_self.revokeFailure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.revokeFailure!, (value) {
    return _then(_self.copyWith(revokeFailure: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeSessionsState].
extension MeSessionsStatePatterns on MeSessionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeSessionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeSessionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeSessionsState value)  $default,){
final _that = this;
switch (_that) {
case _MeSessionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeSessionsState value)?  $default,){
final _that = this;
switch (_that) {
case _MeSessionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MeSessionsStatus status,  List<MeSessionEntity> sessions,  String? nextCursor,  int? limit,  bool hasMore,  AuthFailure? failure,  MeSessionRevokeStatus revokeStatus,  String? pendingRevokeSessionId,  String? lastRevokedSessionId,  AuthFailure? revokeFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeSessionsState() when $default != null:
return $default(_that.status,_that.sessions,_that.nextCursor,_that.limit,_that.hasMore,_that.failure,_that.revokeStatus,_that.pendingRevokeSessionId,_that.lastRevokedSessionId,_that.revokeFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MeSessionsStatus status,  List<MeSessionEntity> sessions,  String? nextCursor,  int? limit,  bool hasMore,  AuthFailure? failure,  MeSessionRevokeStatus revokeStatus,  String? pendingRevokeSessionId,  String? lastRevokedSessionId,  AuthFailure? revokeFailure)  $default,) {final _that = this;
switch (_that) {
case _MeSessionsState():
return $default(_that.status,_that.sessions,_that.nextCursor,_that.limit,_that.hasMore,_that.failure,_that.revokeStatus,_that.pendingRevokeSessionId,_that.lastRevokedSessionId,_that.revokeFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MeSessionsStatus status,  List<MeSessionEntity> sessions,  String? nextCursor,  int? limit,  bool hasMore,  AuthFailure? failure,  MeSessionRevokeStatus revokeStatus,  String? pendingRevokeSessionId,  String? lastRevokedSessionId,  AuthFailure? revokeFailure)?  $default,) {final _that = this;
switch (_that) {
case _MeSessionsState() when $default != null:
return $default(_that.status,_that.sessions,_that.nextCursor,_that.limit,_that.hasMore,_that.failure,_that.revokeStatus,_that.pendingRevokeSessionId,_that.lastRevokedSessionId,_that.revokeFailure);case _:
  return null;

}
}

}

/// @nodoc


class _MeSessionsState extends MeSessionsState {
  const _MeSessionsState({this.status = MeSessionsStatus.initial, final  List<MeSessionEntity> sessions = const <MeSessionEntity>[], this.nextCursor, this.limit, this.hasMore = false, this.failure, this.revokeStatus = MeSessionRevokeStatus.idle, this.pendingRevokeSessionId, this.lastRevokedSessionId, this.revokeFailure}): _sessions = sessions,super._();
  

@override@JsonKey() final  MeSessionsStatus status;
 final  List<MeSessionEntity> _sessions;
@override@JsonKey() List<MeSessionEntity> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override final  String? nextCursor;
@override final  int? limit;
@override@JsonKey() final  bool hasMore;
@override final  AuthFailure? failure;
@override@JsonKey() final  MeSessionRevokeStatus revokeStatus;
@override final  String? pendingRevokeSessionId;
@override final  String? lastRevokedSessionId;
@override final  AuthFailure? revokeFailure;

/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeSessionsStateCopyWith<_MeSessionsState> get copyWith => __$MeSessionsStateCopyWithImpl<_MeSessionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeSessionsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.revokeStatus, revokeStatus) || other.revokeStatus == revokeStatus)&&(identical(other.pendingRevokeSessionId, pendingRevokeSessionId) || other.pendingRevokeSessionId == pendingRevokeSessionId)&&(identical(other.lastRevokedSessionId, lastRevokedSessionId) || other.lastRevokedSessionId == lastRevokedSessionId)&&(identical(other.revokeFailure, revokeFailure) || other.revokeFailure == revokeFailure));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_sessions),nextCursor,limit,hasMore,failure,revokeStatus,pendingRevokeSessionId,lastRevokedSessionId,revokeFailure);

@override
String toString() {
  return 'MeSessionsState(status: $status, sessions: $sessions, nextCursor: $nextCursor, limit: $limit, hasMore: $hasMore, failure: $failure, revokeStatus: $revokeStatus, pendingRevokeSessionId: $pendingRevokeSessionId, lastRevokedSessionId: $lastRevokedSessionId, revokeFailure: $revokeFailure)';
}


}

/// @nodoc
abstract mixin class _$MeSessionsStateCopyWith<$Res> implements $MeSessionsStateCopyWith<$Res> {
  factory _$MeSessionsStateCopyWith(_MeSessionsState value, $Res Function(_MeSessionsState) _then) = __$MeSessionsStateCopyWithImpl;
@override @useResult
$Res call({
 MeSessionsStatus status, List<MeSessionEntity> sessions, String? nextCursor, int? limit, bool hasMore, AuthFailure? failure, MeSessionRevokeStatus revokeStatus, String? pendingRevokeSessionId, String? lastRevokedSessionId, AuthFailure? revokeFailure
});


@override $AuthFailureCopyWith<$Res>? get failure;@override $AuthFailureCopyWith<$Res>? get revokeFailure;

}
/// @nodoc
class __$MeSessionsStateCopyWithImpl<$Res>
    implements _$MeSessionsStateCopyWith<$Res> {
  __$MeSessionsStateCopyWithImpl(this._self, this._then);

  final _MeSessionsState _self;
  final $Res Function(_MeSessionsState) _then;

/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? sessions = null,Object? nextCursor = freezed,Object? limit = freezed,Object? hasMore = null,Object? failure = freezed,Object? revokeStatus = null,Object? pendingRevokeSessionId = freezed,Object? lastRevokedSessionId = freezed,Object? revokeFailure = freezed,}) {
  return _then(_MeSessionsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MeSessionsStatus,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<MeSessionEntity>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,revokeStatus: null == revokeStatus ? _self.revokeStatus : revokeStatus // ignore: cast_nullable_to_non_nullable
as MeSessionRevokeStatus,pendingRevokeSessionId: freezed == pendingRevokeSessionId ? _self.pendingRevokeSessionId : pendingRevokeSessionId // ignore: cast_nullable_to_non_nullable
as String?,lastRevokedSessionId: freezed == lastRevokedSessionId ? _self.lastRevokedSessionId : lastRevokedSessionId // ignore: cast_nullable_to_non_nullable
as String?,revokeFailure: freezed == revokeFailure ? _self.revokeFailure : revokeFailure // ignore: cast_nullable_to_non_nullable
as AuthFailure?,
  ));
}

/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}/// Create a copy of MeSessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<$Res>? get revokeFailure {
    if (_self.revokeFailure == null) {
    return null;
  }

  return $AuthFailureCopyWith<$Res>(_self.revokeFailure!, (value) {
    return _then(_self.copyWith(revokeFailure: value));
  });
}
}

// dart format on
