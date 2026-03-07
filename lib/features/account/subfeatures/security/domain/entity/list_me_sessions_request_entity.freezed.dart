// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_me_sessions_request_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListMeSessionsRequestEntity {

 int? get limit; String? get cursor; String? get sort;
/// Create a copy of ListMeSessionsRequestEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListMeSessionsRequestEntityCopyWith<ListMeSessionsRequestEntity> get copyWith => _$ListMeSessionsRequestEntityCopyWithImpl<ListMeSessionsRequestEntity>(this as ListMeSessionsRequestEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMeSessionsRequestEntity&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,limit,cursor,sort);

@override
String toString() {
  return 'ListMeSessionsRequestEntity(limit: $limit, cursor: $cursor, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $ListMeSessionsRequestEntityCopyWith<$Res>  {
  factory $ListMeSessionsRequestEntityCopyWith(ListMeSessionsRequestEntity value, $Res Function(ListMeSessionsRequestEntity) _then) = _$ListMeSessionsRequestEntityCopyWithImpl;
@useResult
$Res call({
 int? limit, String? cursor, String? sort
});




}
/// @nodoc
class _$ListMeSessionsRequestEntityCopyWithImpl<$Res>
    implements $ListMeSessionsRequestEntityCopyWith<$Res> {
  _$ListMeSessionsRequestEntityCopyWithImpl(this._self, this._then);

  final ListMeSessionsRequestEntity _self;
  final $Res Function(ListMeSessionsRequestEntity) _then;

/// Create a copy of ListMeSessionsRequestEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = freezed,Object? cursor = freezed,Object? sort = freezed,}) {
  return _then(_self.copyWith(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListMeSessionsRequestEntity].
extension ListMeSessionsRequestEntityPatterns on ListMeSessionsRequestEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListMeSessionsRequestEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListMeSessionsRequestEntity value)  $default,){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListMeSessionsRequestEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? limit,  String? cursor,  String? sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity() when $default != null:
return $default(_that.limit,_that.cursor,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? limit,  String? cursor,  String? sort)  $default,) {final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity():
return $default(_that.limit,_that.cursor,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? limit,  String? cursor,  String? sort)?  $default,) {final _that = this;
switch (_that) {
case _ListMeSessionsRequestEntity() when $default != null:
return $default(_that.limit,_that.cursor,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _ListMeSessionsRequestEntity implements ListMeSessionsRequestEntity {
  const _ListMeSessionsRequestEntity({this.limit, this.cursor, this.sort});
  

@override final  int? limit;
@override final  String? cursor;
@override final  String? sort;

/// Create a copy of ListMeSessionsRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListMeSessionsRequestEntityCopyWith<_ListMeSessionsRequestEntity> get copyWith => __$ListMeSessionsRequestEntityCopyWithImpl<_ListMeSessionsRequestEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListMeSessionsRequestEntity&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,limit,cursor,sort);

@override
String toString() {
  return 'ListMeSessionsRequestEntity(limit: $limit, cursor: $cursor, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ListMeSessionsRequestEntityCopyWith<$Res> implements $ListMeSessionsRequestEntityCopyWith<$Res> {
  factory _$ListMeSessionsRequestEntityCopyWith(_ListMeSessionsRequestEntity value, $Res Function(_ListMeSessionsRequestEntity) _then) = __$ListMeSessionsRequestEntityCopyWithImpl;
@override @useResult
$Res call({
 int? limit, String? cursor, String? sort
});




}
/// @nodoc
class __$ListMeSessionsRequestEntityCopyWithImpl<$Res>
    implements _$ListMeSessionsRequestEntityCopyWith<$Res> {
  __$ListMeSessionsRequestEntityCopyWithImpl(this._self, this._then);

  final _ListMeSessionsRequestEntity _self;
  final $Res Function(_ListMeSessionsRequestEntity) _then;

/// Create a copy of ListMeSessionsRequestEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? cursor = freezed,Object? sort = freezed,}) {
  return _then(_ListMeSessionsRequestEntity(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
