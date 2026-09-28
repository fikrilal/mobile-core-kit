// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_option_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReferenceOptionEntity {

 String get id; String get label;
/// Create a copy of ReferenceOptionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceOptionEntityCopyWith<ReferenceOptionEntity> get copyWith => _$ReferenceOptionEntityCopyWithImpl<ReferenceOptionEntity>(this as ReferenceOptionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferenceOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'ReferenceOptionEntity(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class $ReferenceOptionEntityCopyWith<$Res>  {
  factory $ReferenceOptionEntityCopyWith(ReferenceOptionEntity value, $Res Function(ReferenceOptionEntity) _then) = _$ReferenceOptionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$ReferenceOptionEntityCopyWithImpl<$Res>
    implements $ReferenceOptionEntityCopyWith<$Res> {
  _$ReferenceOptionEntityCopyWithImpl(this._self, this._then);

  final ReferenceOptionEntity _self;
  final $Res Function(ReferenceOptionEntity) _then;

/// Create a copy of ReferenceOptionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferenceOptionEntity].
extension ReferenceOptionEntityPatterns on ReferenceOptionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferenceOptionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferenceOptionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferenceOptionEntity value)  $default,){
final _that = this;
switch (_that) {
case _ReferenceOptionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferenceOptionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ReferenceOptionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferenceOptionEntity() when $default != null:
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label)  $default,) {final _that = this;
switch (_that) {
case _ReferenceOptionEntity():
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ReferenceOptionEntity() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ReferenceOptionEntity implements ReferenceOptionEntity {
  const _ReferenceOptionEntity({required this.id, required this.label});
  

@override final  String id;
@override final  String label;

/// Create a copy of ReferenceOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceOptionEntityCopyWith<_ReferenceOptionEntity> get copyWith => __$ReferenceOptionEntityCopyWithImpl<_ReferenceOptionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferenceOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'ReferenceOptionEntity(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ReferenceOptionEntityCopyWith<$Res> implements $ReferenceOptionEntityCopyWith<$Res> {
  factory _$ReferenceOptionEntityCopyWith(_ReferenceOptionEntity value, $Res Function(_ReferenceOptionEntity) _then) = __$ReferenceOptionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class __$ReferenceOptionEntityCopyWithImpl<$Res>
    implements _$ReferenceOptionEntityCopyWith<$Res> {
  __$ReferenceOptionEntityCopyWithImpl(this._self, this._then);

  final _ReferenceOptionEntity _self;
  final $Res Function(_ReferenceOptionEntity) _then;

/// Create a copy of ReferenceOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_ReferenceOptionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
