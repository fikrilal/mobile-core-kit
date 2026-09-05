// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_holder_type_option_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountHolderTypeOptionEntity {

 String get id; String get label; bool get requiresOwnerReference;
/// Create a copy of AccountHolderTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountHolderTypeOptionEntityCopyWith<AccountHolderTypeOptionEntity> get copyWith => _$AccountHolderTypeOptionEntityCopyWithImpl<AccountHolderTypeOptionEntity>(this as AccountHolderTypeOptionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountHolderTypeOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'AccountHolderTypeOptionEntity(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class $AccountHolderTypeOptionEntityCopyWith<$Res>  {
  factory $AccountHolderTypeOptionEntityCopyWith(AccountHolderTypeOptionEntity value, $Res Function(AccountHolderTypeOptionEntity) _then) = _$AccountHolderTypeOptionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class _$AccountHolderTypeOptionEntityCopyWithImpl<$Res>
    implements $AccountHolderTypeOptionEntityCopyWith<$Res> {
  _$AccountHolderTypeOptionEntityCopyWithImpl(this._self, this._then);

  final AccountHolderTypeOptionEntity _self;
  final $Res Function(AccountHolderTypeOptionEntity) _then;

/// Create a copy of AccountHolderTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? requiresOwnerReference = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresOwnerReference: null == requiresOwnerReference ? _self.requiresOwnerReference : requiresOwnerReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountHolderTypeOptionEntity].
extension AccountHolderTypeOptionEntityPatterns on AccountHolderTypeOptionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountHolderTypeOptionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountHolderTypeOptionEntity value)  $default,){
final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountHolderTypeOptionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  bool requiresOwnerReference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.requiresOwnerReference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  bool requiresOwnerReference)  $default,) {final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity():
return $default(_that.id,_that.label,_that.requiresOwnerReference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  bool requiresOwnerReference)?  $default,) {final _that = this;
switch (_that) {
case _AccountHolderTypeOptionEntity() when $default != null:
return $default(_that.id,_that.label,_that.requiresOwnerReference);case _:
  return null;

}
}

}

/// @nodoc


class _AccountHolderTypeOptionEntity implements AccountHolderTypeOptionEntity {
  const _AccountHolderTypeOptionEntity({required this.id, required this.label, required this.requiresOwnerReference});
  

@override final  String id;
@override final  String label;
@override final  bool requiresOwnerReference;

/// Create a copy of AccountHolderTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountHolderTypeOptionEntityCopyWith<_AccountHolderTypeOptionEntity> get copyWith => __$AccountHolderTypeOptionEntityCopyWithImpl<_AccountHolderTypeOptionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountHolderTypeOptionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'AccountHolderTypeOptionEntity(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class _$AccountHolderTypeOptionEntityCopyWith<$Res> implements $AccountHolderTypeOptionEntityCopyWith<$Res> {
  factory _$AccountHolderTypeOptionEntityCopyWith(_AccountHolderTypeOptionEntity value, $Res Function(_AccountHolderTypeOptionEntity) _then) = __$AccountHolderTypeOptionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class __$AccountHolderTypeOptionEntityCopyWithImpl<$Res>
    implements _$AccountHolderTypeOptionEntityCopyWith<$Res> {
  __$AccountHolderTypeOptionEntityCopyWithImpl(this._self, this._then);

  final _AccountHolderTypeOptionEntity _self;
  final $Res Function(_AccountHolderTypeOptionEntity) _then;

/// Create a copy of AccountHolderTypeOptionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresOwnerReference = null,}) {
  return _then(_AccountHolderTypeOptionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresOwnerReference: null == requiresOwnerReference ? _self.requiresOwnerReference : requiresOwnerReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
