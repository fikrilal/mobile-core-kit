// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_role_option_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OwnerRoleOptionEntity {

 String get id; String get label; bool get contributesOwnership;
/// Create a copy of OwnerRoleOptionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerRoleOptionEntityCopyWith<OwnerRoleOptionEntity> get copyWith => _$OwnerRoleOptionEntityCopyWithImpl<OwnerRoleOptionEntity>(this as OwnerRoleOptionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwnerRoleOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'OwnerRoleOptionEntity(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class $OwnerRoleOptionEntityCopyWith<$Res>  {
  factory $OwnerRoleOptionEntityCopyWith(OwnerRoleOptionEntity value, $Res Function(OwnerRoleOptionEntity) _then) = _$OwnerRoleOptionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class _$OwnerRoleOptionEntityCopyWithImpl<$Res>
    implements $OwnerRoleOptionEntityCopyWith<$Res> {
  _$OwnerRoleOptionEntityCopyWithImpl(this._self, this._then);

  final OwnerRoleOptionEntity _self;
  final $Res Function(OwnerRoleOptionEntity) _then;

/// Create a copy of OwnerRoleOptionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? contributesOwnership = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contributesOwnership: null == contributesOwnership ? _self.contributesOwnership : contributesOwnership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OwnerRoleOptionEntity].
extension OwnerRoleOptionEntityPatterns on OwnerRoleOptionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OwnerRoleOptionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OwnerRoleOptionEntity value)  $default,){
final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OwnerRoleOptionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  bool contributesOwnership)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.contributesOwnership);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  bool contributesOwnership)  $default,) {final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity():
return $default(_that.id,_that.label,_that.contributesOwnership);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  bool contributesOwnership)?  $default,) {final _that = this;
switch (_that) {
case _OwnerRoleOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.contributesOwnership);case _:
  return null;

}
}

}

/// @nodoc


class _OwnerRoleOptionEntity implements OwnerRoleOptionEntity {
  const _OwnerRoleOptionEntity({required this.id, required this.label, required this.contributesOwnership});
  

@override final  String id;
@override final  String label;
@override final  bool contributesOwnership;

/// Create a copy of OwnerRoleOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwnerRoleOptionEntityCopyWith<_OwnerRoleOptionEntity> get copyWith => __$OwnerRoleOptionEntityCopyWithImpl<_OwnerRoleOptionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwnerRoleOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'OwnerRoleOptionEntity(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class _$OwnerRoleOptionEntityCopyWith<$Res> implements $OwnerRoleOptionEntityCopyWith<$Res> {
  factory _$OwnerRoleOptionEntityCopyWith(_OwnerRoleOptionEntity value, $Res Function(_OwnerRoleOptionEntity) _then) = __$OwnerRoleOptionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class __$OwnerRoleOptionEntityCopyWithImpl<$Res>
    implements _$OwnerRoleOptionEntityCopyWith<$Res> {
  __$OwnerRoleOptionEntityCopyWithImpl(this._self, this._then);

  final _OwnerRoleOptionEntity _self;
  final $Res Function(_OwnerRoleOptionEntity) _then;

/// Create a copy of OwnerRoleOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? contributesOwnership = null,}) {
  return _then(_OwnerRoleOptionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contributesOwnership: null == contributesOwnership ? _self.contributesOwnership : contributesOwnership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
