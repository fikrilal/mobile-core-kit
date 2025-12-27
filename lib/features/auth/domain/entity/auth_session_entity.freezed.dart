// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionEntity {

 AuthTokensEntity get tokens;/// User can be null when restoring a session from tokens only.
///
/// On app start, the app may restore tokens from secure storage and then
/// hydrate the user via `GET /v1/users/me`.
 UserEntity? get user;
/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionEntityCopyWith<AuthSessionEntity> get copyWith => _$AuthSessionEntityCopyWithImpl<AuthSessionEntity>(this as AuthSessionEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionEntity&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,tokens,user);

@override
String toString() {
  return 'AuthSessionEntity(tokens: $tokens, user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthSessionEntityCopyWith<$Res>  {
  factory $AuthSessionEntityCopyWith(AuthSessionEntity value, $Res Function(AuthSessionEntity) _then) = _$AuthSessionEntityCopyWithImpl;
@useResult
$Res call({
 AuthTokensEntity tokens, UserEntity? user
});


$AuthTokensEntityCopyWith<$Res> get tokens;$UserEntityCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthSessionEntityCopyWithImpl<$Res>
    implements $AuthSessionEntityCopyWith<$Res> {
  _$AuthSessionEntityCopyWithImpl(this._self, this._then);

  final AuthSessionEntity _self;
  final $Res Function(AuthSessionEntity) _then;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokens = null,Object? user = freezed,}) {
  return _then(_self.copyWith(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AuthTokensEntity,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity?,
  ));
}
/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthTokensEntityCopyWith<$Res> get tokens {
  
  return $AuthTokensEntityCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserEntityCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserEntityCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthSessionEntity].
extension AuthSessionEntityPatterns on AuthSessionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSessionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSessionEntity value)  $default,){
final _that = this;
switch (_that) {
case _AuthSessionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSessionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthTokensEntity tokens,  UserEntity? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
return $default(_that.tokens,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthTokensEntity tokens,  UserEntity? user)  $default,) {final _that = this;
switch (_that) {
case _AuthSessionEntity():
return $default(_that.tokens,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthTokensEntity tokens,  UserEntity? user)?  $default,) {final _that = this;
switch (_that) {
case _AuthSessionEntity() when $default != null:
return $default(_that.tokens,_that.user);case _:
  return null;

}
}

}

/// @nodoc


class _AuthSessionEntity implements AuthSessionEntity {
  const _AuthSessionEntity({required this.tokens, this.user});
  

@override final  AuthTokensEntity tokens;
/// User can be null when restoring a session from tokens only.
///
/// On app start, the app may restore tokens from secure storage and then
/// hydrate the user via `GET /v1/users/me`.
@override final  UserEntity? user;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionEntityCopyWith<_AuthSessionEntity> get copyWith => __$AuthSessionEntityCopyWithImpl<_AuthSessionEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSessionEntity&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,tokens,user);

@override
String toString() {
  return 'AuthSessionEntity(tokens: $tokens, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionEntityCopyWith<$Res> implements $AuthSessionEntityCopyWith<$Res> {
  factory _$AuthSessionEntityCopyWith(_AuthSessionEntity value, $Res Function(_AuthSessionEntity) _then) = __$AuthSessionEntityCopyWithImpl;
@override @useResult
$Res call({
 AuthTokensEntity tokens, UserEntity? user
});


@override $AuthTokensEntityCopyWith<$Res> get tokens;@override $UserEntityCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthSessionEntityCopyWithImpl<$Res>
    implements _$AuthSessionEntityCopyWith<$Res> {
  __$AuthSessionEntityCopyWithImpl(this._self, this._then);

  final _AuthSessionEntity _self;
  final $Res Function(_AuthSessionEntity) _then;

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokens = null,Object? user = freezed,}) {
  return _then(_AuthSessionEntity(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AuthTokensEntity,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity?,
  ));
}

/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthTokensEntityCopyWith<$Res> get tokens {
  
  return $AuthTokensEntityCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of AuthSessionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserEntityCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserEntityCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
