// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'business_type_option_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BusinessTypeOptionEntity {

 String get id; String get label; bool get requiresRegistrationNumber;
/// Create a copy of BusinessTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessTypeOptionEntityCopyWith<BusinessTypeOptionEntity> get copyWith => _$BusinessTypeOptionEntityCopyWithImpl<BusinessTypeOptionEntity>(this as BusinessTypeOptionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessTypeOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'BusinessTypeOptionEntity(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class $BusinessTypeOptionEntityCopyWith<$Res>  {
  factory $BusinessTypeOptionEntityCopyWith(BusinessTypeOptionEntity value, $Res Function(BusinessTypeOptionEntity) _then) = _$BusinessTypeOptionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class _$BusinessTypeOptionEntityCopyWithImpl<$Res>
    implements $BusinessTypeOptionEntityCopyWith<$Res> {
  _$BusinessTypeOptionEntityCopyWithImpl(this._self, this._then);

  final BusinessTypeOptionEntity _self;
  final $Res Function(BusinessTypeOptionEntity) _then;

/// Create a copy of BusinessTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? requiresRegistrationNumber = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresRegistrationNumber: null == requiresRegistrationNumber ? _self.requiresRegistrationNumber : requiresRegistrationNumber // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessTypeOptionEntity].
extension BusinessTypeOptionEntityPatterns on BusinessTypeOptionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessTypeOptionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessTypeOptionEntity value)  $default,){
final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessTypeOptionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  bool requiresRegistrationNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.requiresRegistrationNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  bool requiresRegistrationNumber)  $default,) {final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity():
return $default(_that.id,_that.label,_that.requiresRegistrationNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  bool requiresRegistrationNumber)?  $default,) {final _that = this;
switch (_that) {
case _BusinessTypeOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.requiresRegistrationNumber);case _:
  return null;

}
}

}

/// @nodoc


class _BusinessTypeOptionEntity implements BusinessTypeOptionEntity {
  const _BusinessTypeOptionEntity({required this.id, required this.label, required this.requiresRegistrationNumber});
  

@override final  String id;
@override final  String label;
@override final  bool requiresRegistrationNumber;

/// Create a copy of BusinessTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessTypeOptionEntityCopyWith<_BusinessTypeOptionEntity> get copyWith => __$BusinessTypeOptionEntityCopyWithImpl<_BusinessTypeOptionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessTypeOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'BusinessTypeOptionEntity(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class _$BusinessTypeOptionEntityCopyWith<$Res> implements $BusinessTypeOptionEntityCopyWith<$Res> {
  factory _$BusinessTypeOptionEntityCopyWith(_BusinessTypeOptionEntity value, $Res Function(_BusinessTypeOptionEntity) _then) = __$BusinessTypeOptionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class __$BusinessTypeOptionEntityCopyWithImpl<$Res>
    implements _$BusinessTypeOptionEntityCopyWith<$Res> {
  __$BusinessTypeOptionEntityCopyWithImpl(this._self, this._then);

  final _BusinessTypeOptionEntity _self;
  final $Res Function(_BusinessTypeOptionEntity) _then;

/// Create a copy of BusinessTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresRegistrationNumber = null,}) {
  return _then(_BusinessTypeOptionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresRegistrationNumber: null == requiresRegistrationNumber ? _self.requiresRegistrationNumber : requiresRegistrationNumber // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
