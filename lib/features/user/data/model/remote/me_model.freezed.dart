// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MeModel {

 String get id; String get email; bool get emailVerified; List<String> get roles; List<String> get authMethods; MeProfileModel get profile; AccountDeletionModel? get accountDeletion;
/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeModelCopyWith<MeModel> get copyWith => _$MeModelCopyWithImpl<MeModel>(this as MeModel, _$identity);

  /// Serializes this MeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.authMethods, authMethods)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.accountDeletion, accountDeletion) || other.accountDeletion == accountDeletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(authMethods),profile,accountDeletion);

@override
String toString() {
  return 'MeModel(id: $id, email: $email, emailVerified: $emailVerified, roles: $roles, authMethods: $authMethods, profile: $profile, accountDeletion: $accountDeletion)';
}


}

/// @nodoc
abstract mixin class $MeModelCopyWith<$Res>  {
  factory $MeModelCopyWith(MeModel value, $Res Function(MeModel) _then) = _$MeModelCopyWithImpl;
@useResult
$Res call({
 String id, String email, bool emailVerified, List<String> roles, List<String> authMethods, MeProfileModel profile, AccountDeletionModel? accountDeletion
});


$MeProfileModelCopyWith<$Res> get profile;$AccountDeletionModelCopyWith<$Res>? get accountDeletion;

}
/// @nodoc
class _$MeModelCopyWithImpl<$Res>
    implements $MeModelCopyWith<$Res> {
  _$MeModelCopyWithImpl(this._self, this._then);

  final MeModel _self;
  final $Res Function(MeModel) _then;

/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? roles = null,Object? authMethods = null,Object? profile = null,Object? accountDeletion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,authMethods: null == authMethods ? _self.authMethods : authMethods // ignore: cast_nullable_to_non_nullable
as List<String>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MeProfileModel,accountDeletion: freezed == accountDeletion ? _self.accountDeletion : accountDeletion // ignore: cast_nullable_to_non_nullable
as AccountDeletionModel?,
  ));
}
/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeProfileModelCopyWith<$Res> get profile {
  
  return $MeProfileModelCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountDeletionModelCopyWith<$Res>? get accountDeletion {
    if (_self.accountDeletion == null) {
    return null;
  }

  return $AccountDeletionModelCopyWith<$Res>(_self.accountDeletion!, (value) {
    return _then(_self.copyWith(accountDeletion: value));
  });
}
}


/// Adds pattern-matching-related methods to [MeModel].
extension MeModelPatterns on MeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeModel value)  $default,){
final _that = this;
switch (_that) {
case _MeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  MeProfileModel profile,  AccountDeletionModel? accountDeletion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeModel() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  MeProfileModel profile,  AccountDeletionModel? accountDeletion)  $default,) {final _that = this;
switch (_that) {
case _MeModel():
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  bool emailVerified,  List<String> roles,  List<String> authMethods,  MeProfileModel profile,  AccountDeletionModel? accountDeletion)?  $default,) {final _that = this;
switch (_that) {
case _MeModel() when $default != null:
return $default(_that.id,_that.email,_that.emailVerified,_that.roles,_that.authMethods,_that.profile,_that.accountDeletion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeModel extends MeModel {
  const _MeModel({required this.id, required this.email, required this.emailVerified, required final  List<String> roles, required final  List<String> authMethods, required this.profile, this.accountDeletion}): _roles = roles,_authMethods = authMethods,super._();
  factory _MeModel.fromJson(Map<String, dynamic> json) => _$MeModelFromJson(json);

@override final  String id;
@override final  String email;
@override final  bool emailVerified;
 final  List<String> _roles;
@override List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

 final  List<String> _authMethods;
@override List<String> get authMethods {
  if (_authMethods is EqualUnmodifiableListView) return _authMethods;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authMethods);
}

@override final  MeProfileModel profile;
@override final  AccountDeletionModel? accountDeletion;

/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeModelCopyWith<_MeModel> get copyWith => __$MeModelCopyWithImpl<_MeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._authMethods, _authMethods)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.accountDeletion, accountDeletion) || other.accountDeletion == accountDeletion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,emailVerified,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_authMethods),profile,accountDeletion);

@override
String toString() {
  return 'MeModel(id: $id, email: $email, emailVerified: $emailVerified, roles: $roles, authMethods: $authMethods, profile: $profile, accountDeletion: $accountDeletion)';
}


}

/// @nodoc
abstract mixin class _$MeModelCopyWith<$Res> implements $MeModelCopyWith<$Res> {
  factory _$MeModelCopyWith(_MeModel value, $Res Function(_MeModel) _then) = __$MeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, bool emailVerified, List<String> roles, List<String> authMethods, MeProfileModel profile, AccountDeletionModel? accountDeletion
});


@override $MeProfileModelCopyWith<$Res> get profile;@override $AccountDeletionModelCopyWith<$Res>? get accountDeletion;

}
/// @nodoc
class __$MeModelCopyWithImpl<$Res>
    implements _$MeModelCopyWith<$Res> {
  __$MeModelCopyWithImpl(this._self, this._then);

  final _MeModel _self;
  final $Res Function(_MeModel) _then;

/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? emailVerified = null,Object? roles = null,Object? authMethods = null,Object? profile = null,Object? accountDeletion = freezed,}) {
  return _then(_MeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,authMethods: null == authMethods ? _self._authMethods : authMethods // ignore: cast_nullable_to_non_nullable
as List<String>,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MeProfileModel,accountDeletion: freezed == accountDeletion ? _self.accountDeletion : accountDeletion // ignore: cast_nullable_to_non_nullable
as AccountDeletionModel?,
  ));
}

/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MeProfileModelCopyWith<$Res> get profile {
  
  return $MeProfileModelCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of MeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountDeletionModelCopyWith<$Res>? get accountDeletion {
    if (_self.accountDeletion == null) {
    return null;
  }

  return $AccountDeletionModelCopyWith<$Res>(_self.accountDeletion!, (value) {
    return _then(_self.copyWith(accountDeletion: value));
  });
}
}


/// @nodoc
mixin _$MeProfileModel {

 String? get profileImageFileId; String? get displayName; String? get givenName; String? get familyName;
/// Create a copy of MeProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeProfileModelCopyWith<MeProfileModel> get copyWith => _$MeProfileModelCopyWithImpl<MeProfileModel>(this as MeProfileModel, _$identity);

  /// Serializes this MeProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MeProfileModel&&(identical(other.profileImageFileId, profileImageFileId) || other.profileImageFileId == profileImageFileId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileImageFileId,displayName,givenName,familyName);

@override
String toString() {
  return 'MeProfileModel(profileImageFileId: $profileImageFileId, displayName: $displayName, givenName: $givenName, familyName: $familyName)';
}


}

/// @nodoc
abstract mixin class $MeProfileModelCopyWith<$Res>  {
  factory $MeProfileModelCopyWith(MeProfileModel value, $Res Function(MeProfileModel) _then) = _$MeProfileModelCopyWithImpl;
@useResult
$Res call({
 String? profileImageFileId, String? displayName, String? givenName, String? familyName
});




}
/// @nodoc
class _$MeProfileModelCopyWithImpl<$Res>
    implements $MeProfileModelCopyWith<$Res> {
  _$MeProfileModelCopyWithImpl(this._self, this._then);

  final MeProfileModel _self;
  final $Res Function(MeProfileModel) _then;

/// Create a copy of MeProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileImageFileId = freezed,Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,}) {
  return _then(_self.copyWith(
profileImageFileId: freezed == profileImageFileId ? _self.profileImageFileId : profileImageFileId // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MeProfileModel].
extension MeProfileModelPatterns on MeProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MeProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MeProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MeProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _MeProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MeProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _MeProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MeProfileModel() when $default != null:
return $default(_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName)  $default,) {final _that = this;
switch (_that) {
case _MeProfileModel():
return $default(_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? profileImageFileId,  String? displayName,  String? givenName,  String? familyName)?  $default,) {final _that = this;
switch (_that) {
case _MeProfileModel() when $default != null:
return $default(_that.profileImageFileId,_that.displayName,_that.givenName,_that.familyName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MeProfileModel extends MeProfileModel {
  const _MeProfileModel({this.profileImageFileId, this.displayName, this.givenName, this.familyName}): super._();
  factory _MeProfileModel.fromJson(Map<String, dynamic> json) => _$MeProfileModelFromJson(json);

@override final  String? profileImageFileId;
@override final  String? displayName;
@override final  String? givenName;
@override final  String? familyName;

/// Create a copy of MeProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeProfileModelCopyWith<_MeProfileModel> get copyWith => __$MeProfileModelCopyWithImpl<_MeProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MeProfileModel&&(identical(other.profileImageFileId, profileImageFileId) || other.profileImageFileId == profileImageFileId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.givenName, givenName) || other.givenName == givenName)&&(identical(other.familyName, familyName) || other.familyName == familyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profileImageFileId,displayName,givenName,familyName);

@override
String toString() {
  return 'MeProfileModel(profileImageFileId: $profileImageFileId, displayName: $displayName, givenName: $givenName, familyName: $familyName)';
}


}

/// @nodoc
abstract mixin class _$MeProfileModelCopyWith<$Res> implements $MeProfileModelCopyWith<$Res> {
  factory _$MeProfileModelCopyWith(_MeProfileModel value, $Res Function(_MeProfileModel) _then) = __$MeProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String? profileImageFileId, String? displayName, String? givenName, String? familyName
});




}
/// @nodoc
class __$MeProfileModelCopyWithImpl<$Res>
    implements _$MeProfileModelCopyWith<$Res> {
  __$MeProfileModelCopyWithImpl(this._self, this._then);

  final _MeProfileModel _self;
  final $Res Function(_MeProfileModel) _then;

/// Create a copy of MeProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileImageFileId = freezed,Object? displayName = freezed,Object? givenName = freezed,Object? familyName = freezed,}) {
  return _then(_MeProfileModel(
profileImageFileId: freezed == profileImageFileId ? _self.profileImageFileId : profileImageFileId // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,givenName: freezed == givenName ? _self.givenName : givenName // ignore: cast_nullable_to_non_nullable
as String?,familyName: freezed == familyName ? _self.familyName : familyName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AccountDeletionModel {

 String get requestedAt; String get scheduledFor;
/// Create a copy of AccountDeletionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeletionModelCopyWith<AccountDeletionModel> get copyWith => _$AccountDeletionModelCopyWithImpl<AccountDeletionModel>(this as AccountDeletionModel, _$identity);

  /// Serializes this AccountDeletionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDeletionModel&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestedAt,scheduledFor);

@override
String toString() {
  return 'AccountDeletionModel(requestedAt: $requestedAt, scheduledFor: $scheduledFor)';
}


}

/// @nodoc
abstract mixin class $AccountDeletionModelCopyWith<$Res>  {
  factory $AccountDeletionModelCopyWith(AccountDeletionModel value, $Res Function(AccountDeletionModel) _then) = _$AccountDeletionModelCopyWithImpl;
@useResult
$Res call({
 String requestedAt, String scheduledFor
});




}
/// @nodoc
class _$AccountDeletionModelCopyWithImpl<$Res>
    implements $AccountDeletionModelCopyWith<$Res> {
  _$AccountDeletionModelCopyWithImpl(this._self, this._then);

  final AccountDeletionModel _self;
  final $Res Function(AccountDeletionModel) _then;

/// Create a copy of AccountDeletionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestedAt = null,Object? scheduledFor = null,}) {
  return _then(_self.copyWith(
requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountDeletionModel].
extension AccountDeletionModelPatterns on AccountDeletionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountDeletionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountDeletionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountDeletionModel value)  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountDeletionModel value)?  $default,){
final _that = this;
switch (_that) {
case _AccountDeletionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestedAt,  String scheduledFor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountDeletionModel() when $default != null:
return $default(_that.requestedAt,_that.scheduledFor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestedAt,  String scheduledFor)  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionModel():
return $default(_that.requestedAt,_that.scheduledFor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestedAt,  String scheduledFor)?  $default,) {final _that = this;
switch (_that) {
case _AccountDeletionModel() when $default != null:
return $default(_that.requestedAt,_that.scheduledFor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountDeletionModel extends AccountDeletionModel {
  const _AccountDeletionModel({required this.requestedAt, required this.scheduledFor}): super._();
  factory _AccountDeletionModel.fromJson(Map<String, dynamic> json) => _$AccountDeletionModelFromJson(json);

@override final  String requestedAt;
@override final  String scheduledFor;

/// Create a copy of AccountDeletionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountDeletionModelCopyWith<_AccountDeletionModel> get copyWith => __$AccountDeletionModelCopyWithImpl<_AccountDeletionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountDeletionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountDeletionModel&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.scheduledFor, scheduledFor) || other.scheduledFor == scheduledFor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,requestedAt,scheduledFor);

@override
String toString() {
  return 'AccountDeletionModel(requestedAt: $requestedAt, scheduledFor: $scheduledFor)';
}


}

/// @nodoc
abstract mixin class _$AccountDeletionModelCopyWith<$Res> implements $AccountDeletionModelCopyWith<$Res> {
  factory _$AccountDeletionModelCopyWith(_AccountDeletionModel value, $Res Function(_AccountDeletionModel) _then) = __$AccountDeletionModelCopyWithImpl;
@override @useResult
$Res call({
 String requestedAt, String scheduledFor
});




}
/// @nodoc
class __$AccountDeletionModelCopyWithImpl<$Res>
    implements _$AccountDeletionModelCopyWith<$Res> {
  __$AccountDeletionModelCopyWithImpl(this._self, this._then);

  final _AccountDeletionModel _self;
  final $Res Function(_AccountDeletionModel) _then;

/// Create a copy of AccountDeletionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestedAt = null,Object? scheduledFor = null,}) {
  return _then(_AccountDeletionModel(
requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String,scheduledFor: null == scheduledFor ? _self.scheduledFor : scheduledFor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
