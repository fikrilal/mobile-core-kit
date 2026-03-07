// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_me_sessions_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListMeSessionsRequestModel {

 int? get limit; String? get cursor; String? get sort;
/// Create a copy of ListMeSessionsRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListMeSessionsRequestModelCopyWith<ListMeSessionsRequestModel> get copyWith => _$ListMeSessionsRequestModelCopyWithImpl<ListMeSessionsRequestModel>(this as ListMeSessionsRequestModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListMeSessionsRequestModel&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,limit,cursor,sort);

@override
String toString() {
  return 'ListMeSessionsRequestModel(limit: $limit, cursor: $cursor, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $ListMeSessionsRequestModelCopyWith<$Res>  {
  factory $ListMeSessionsRequestModelCopyWith(ListMeSessionsRequestModel value, $Res Function(ListMeSessionsRequestModel) _then) = _$ListMeSessionsRequestModelCopyWithImpl;
@useResult
$Res call({
 int? limit, String? cursor, String? sort
});




}
/// @nodoc
class _$ListMeSessionsRequestModelCopyWithImpl<$Res>
    implements $ListMeSessionsRequestModelCopyWith<$Res> {
  _$ListMeSessionsRequestModelCopyWithImpl(this._self, this._then);

  final ListMeSessionsRequestModel _self;
  final $Res Function(ListMeSessionsRequestModel) _then;

/// Create a copy of ListMeSessionsRequestModel
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


/// Adds pattern-matching-related methods to [ListMeSessionsRequestModel].
extension ListMeSessionsRequestModelPatterns on ListMeSessionsRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListMeSessionsRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListMeSessionsRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListMeSessionsRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _ListMeSessionsRequestModel() when $default != null:
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
case _ListMeSessionsRequestModel() when $default != null:
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
case _ListMeSessionsRequestModel():
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
case _ListMeSessionsRequestModel() when $default != null:
return $default(_that.limit,_that.cursor,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _ListMeSessionsRequestModel extends ListMeSessionsRequestModel {
  const _ListMeSessionsRequestModel({this.limit, this.cursor, this.sort}): super._();
  

@override final  int? limit;
@override final  String? cursor;
@override final  String? sort;

/// Create a copy of ListMeSessionsRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListMeSessionsRequestModelCopyWith<_ListMeSessionsRequestModel> get copyWith => __$ListMeSessionsRequestModelCopyWithImpl<_ListMeSessionsRequestModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListMeSessionsRequestModel&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,limit,cursor,sort);

@override
String toString() {
  return 'ListMeSessionsRequestModel(limit: $limit, cursor: $cursor, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ListMeSessionsRequestModelCopyWith<$Res> implements $ListMeSessionsRequestModelCopyWith<$Res> {
  factory _$ListMeSessionsRequestModelCopyWith(_ListMeSessionsRequestModel value, $Res Function(_ListMeSessionsRequestModel) _then) = __$ListMeSessionsRequestModelCopyWithImpl;
@override @useResult
$Res call({
 int? limit, String? cursor, String? sort
});




}
/// @nodoc
class __$ListMeSessionsRequestModelCopyWithImpl<$Res>
    implements _$ListMeSessionsRequestModelCopyWith<$Res> {
  __$ListMeSessionsRequestModelCopyWithImpl(this._self, this._then);

  final _ListMeSessionsRequestModel _self;
  final $Res Function(_ListMeSessionsRequestModel) _then;

/// Create a copy of ListMeSessionsRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = freezed,Object? cursor = freezed,Object? sort = freezed,}) {
  return _then(_ListMeSessionsRequestModel(
limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
