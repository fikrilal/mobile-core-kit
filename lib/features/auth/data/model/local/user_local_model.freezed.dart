// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_local_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserLocalModel {

 String? get id; String? get email; String? get firstName; String? get lastName; bool? get emailVerified;
/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserLocalModelCopyWith<UserLocalModel> get copyWith => _$UserLocalModelCopyWithImpl<UserLocalModel>(this as UserLocalModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserLocalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,emailVerified);

@override
String toString() {
  return 'UserLocalModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, emailVerified: $emailVerified)';
}


}

/// @nodoc
abstract mixin class $UserLocalModelCopyWith<$Res>  {
  factory $UserLocalModelCopyWith(UserLocalModel value, $Res Function(UserLocalModel) _then) = _$UserLocalModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? email, String? firstName, String? lastName, bool? emailVerified
});




}
/// @nodoc
class _$UserLocalModelCopyWithImpl<$Res>
    implements $UserLocalModelCopyWith<$Res> {
  _$UserLocalModelCopyWithImpl(this._self, this._then);

  final UserLocalModel _self;
  final $Res Function(UserLocalModel) _then;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? emailVerified = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserLocalModel].
extension UserLocalModelPatterns on UserLocalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserLocalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserLocalModel value)  $default,){
final _that = this;
switch (_that) {
case _UserLocalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserLocalModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? email,  String? firstName,  String? lastName,  bool? emailVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.emailVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? email,  String? firstName,  String? lastName,  bool? emailVerified)  $default,) {final _that = this;
switch (_that) {
case _UserLocalModel():
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.emailVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? email,  String? firstName,  String? lastName,  bool? emailVerified)?  $default,) {final _that = this;
switch (_that) {
case _UserLocalModel() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.emailVerified);case _:
  return null;

}
}

}

/// @nodoc


class _UserLocalModel extends UserLocalModel {
  const _UserLocalModel({this.id, this.email, this.firstName, this.lastName, this.emailVerified}): super._();
  

@override final  String? id;
@override final  String? email;
@override final  String? firstName;
@override final  String? lastName;
@override final  bool? emailVerified;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserLocalModelCopyWith<_UserLocalModel> get copyWith => __$UserLocalModelCopyWithImpl<_UserLocalModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserLocalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,emailVerified);

@override
String toString() {
  return 'UserLocalModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, emailVerified: $emailVerified)';
}


}

/// @nodoc
abstract mixin class _$UserLocalModelCopyWith<$Res> implements $UserLocalModelCopyWith<$Res> {
  factory _$UserLocalModelCopyWith(_UserLocalModel value, $Res Function(_UserLocalModel) _then) = __$UserLocalModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? email, String? firstName, String? lastName, bool? emailVerified
});




}
/// @nodoc
class __$UserLocalModelCopyWithImpl<$Res>
    implements _$UserLocalModelCopyWith<$Res> {
  __$UserLocalModelCopyWithImpl(this._self, this._then);

  final _UserLocalModel _self;
  final $Res Function(_UserLocalModel) _then;

/// Create a copy of UserLocalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? emailVerified = freezed,}) {
  return _then(_UserLocalModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: freezed == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
