// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'value_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ValueFailure {

 String get failedValue;
/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValueFailureCopyWith<ValueFailure> get copyWith => _$ValueFailureCopyWithImpl<ValueFailure>(this as ValueFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValueFailure&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $ValueFailureCopyWith<$Res>  {
  factory $ValueFailureCopyWith(ValueFailure value, $Res Function(ValueFailure) _then) = _$ValueFailureCopyWithImpl;
@useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$ValueFailureCopyWithImpl<$Res>
    implements $ValueFailureCopyWith<$Res> {
  _$ValueFailureCopyWithImpl(this._self, this._then);

  final ValueFailure _self;
  final $Res Function(ValueFailure) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? failedValue = null,}) {
  return _then(_self.copyWith(
failedValue: null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ValueFailure].
extension ValueFailurePatterns on ValueFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( InvalidEmail value)?  invalidEmail,TResult Function( ShortPassword value)?  shortPassword,TResult Function( MissingLowercase value)?  missingLowercase,TResult Function( MissingUppercase value)?  missingUppercase,TResult Function( MissingNumber value)?  missingNumber,TResult Function( InvalidUsername value)?  invalidUsername,TResult Function( ShortUsername value)?  shortUsername,TResult Function( LongUsername value)?  longUsername,TResult Function( InvalidUsernameFormat value)?  invalidUsernameFormat,TResult Function( PasswordsDoNotMatch value)?  passwordsDoNotMatch,TResult Function( Empty value)?  empty,TResult Function( ShortName value)?  shortName,TResult Function( LongName value)?  longName,required TResult orElse(),}){
final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case ShortPassword() when shortPassword != null:
return shortPassword(_that);case MissingLowercase() when missingLowercase != null:
return missingLowercase(_that);case MissingUppercase() when missingUppercase != null:
return missingUppercase(_that);case MissingNumber() when missingNumber != null:
return missingNumber(_that);case InvalidUsername() when invalidUsername != null:
return invalidUsername(_that);case ShortUsername() when shortUsername != null:
return shortUsername(_that);case LongUsername() when longUsername != null:
return longUsername(_that);case InvalidUsernameFormat() when invalidUsernameFormat != null:
return invalidUsernameFormat(_that);case PasswordsDoNotMatch() when passwordsDoNotMatch != null:
return passwordsDoNotMatch(_that);case Empty() when empty != null:
return empty(_that);case ShortName() when shortName != null:
return shortName(_that);case LongName() when longName != null:
return longName(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( InvalidEmail value)  invalidEmail,required TResult Function( ShortPassword value)  shortPassword,required TResult Function( MissingLowercase value)  missingLowercase,required TResult Function( MissingUppercase value)  missingUppercase,required TResult Function( MissingNumber value)  missingNumber,required TResult Function( InvalidUsername value)  invalidUsername,required TResult Function( ShortUsername value)  shortUsername,required TResult Function( LongUsername value)  longUsername,required TResult Function( InvalidUsernameFormat value)  invalidUsernameFormat,required TResult Function( PasswordsDoNotMatch value)  passwordsDoNotMatch,required TResult Function( Empty value)  empty,required TResult Function( ShortName value)  shortName,required TResult Function( LongName value)  longName,}){
final _that = this;
switch (_that) {
case InvalidEmail():
return invalidEmail(_that);case ShortPassword():
return shortPassword(_that);case MissingLowercase():
return missingLowercase(_that);case MissingUppercase():
return missingUppercase(_that);case MissingNumber():
return missingNumber(_that);case InvalidUsername():
return invalidUsername(_that);case ShortUsername():
return shortUsername(_that);case LongUsername():
return longUsername(_that);case InvalidUsernameFormat():
return invalidUsernameFormat(_that);case PasswordsDoNotMatch():
return passwordsDoNotMatch(_that);case Empty():
return empty(_that);case ShortName():
return shortName(_that);case LongName():
return longName(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( InvalidEmail value)?  invalidEmail,TResult? Function( ShortPassword value)?  shortPassword,TResult? Function( MissingLowercase value)?  missingLowercase,TResult? Function( MissingUppercase value)?  missingUppercase,TResult? Function( MissingNumber value)?  missingNumber,TResult? Function( InvalidUsername value)?  invalidUsername,TResult? Function( ShortUsername value)?  shortUsername,TResult? Function( LongUsername value)?  longUsername,TResult? Function( InvalidUsernameFormat value)?  invalidUsernameFormat,TResult? Function( PasswordsDoNotMatch value)?  passwordsDoNotMatch,TResult? Function( Empty value)?  empty,TResult? Function( ShortName value)?  shortName,TResult? Function( LongName value)?  longName,}){
final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that);case ShortPassword() when shortPassword != null:
return shortPassword(_that);case MissingLowercase() when missingLowercase != null:
return missingLowercase(_that);case MissingUppercase() when missingUppercase != null:
return missingUppercase(_that);case MissingNumber() when missingNumber != null:
return missingNumber(_that);case InvalidUsername() when invalidUsername != null:
return invalidUsername(_that);case ShortUsername() when shortUsername != null:
return shortUsername(_that);case LongUsername() when longUsername != null:
return longUsername(_that);case InvalidUsernameFormat() when invalidUsernameFormat != null:
return invalidUsernameFormat(_that);case PasswordsDoNotMatch() when passwordsDoNotMatch != null:
return passwordsDoNotMatch(_that);case Empty() when empty != null:
return empty(_that);case ShortName() when shortName != null:
return shortName(_that);case LongName() when longName != null:
return longName(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String failedValue)?  invalidEmail,TResult Function( String failedValue)?  shortPassword,TResult Function( String failedValue)?  missingLowercase,TResult Function( String failedValue)?  missingUppercase,TResult Function( String failedValue)?  missingNumber,TResult Function( String failedValue)?  invalidUsername,TResult Function( String failedValue)?  shortUsername,TResult Function( String failedValue)?  longUsername,TResult Function( String failedValue)?  invalidUsernameFormat,TResult Function( String failedValue)?  passwordsDoNotMatch,TResult Function( String failedValue)?  empty,TResult Function( String failedValue)?  shortName,TResult Function( String failedValue)?  longName,required TResult orElse(),}) {final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that.failedValue);case ShortPassword() when shortPassword != null:
return shortPassword(_that.failedValue);case MissingLowercase() when missingLowercase != null:
return missingLowercase(_that.failedValue);case MissingUppercase() when missingUppercase != null:
return missingUppercase(_that.failedValue);case MissingNumber() when missingNumber != null:
return missingNumber(_that.failedValue);case InvalidUsername() when invalidUsername != null:
return invalidUsername(_that.failedValue);case ShortUsername() when shortUsername != null:
return shortUsername(_that.failedValue);case LongUsername() when longUsername != null:
return longUsername(_that.failedValue);case InvalidUsernameFormat() when invalidUsernameFormat != null:
return invalidUsernameFormat(_that.failedValue);case PasswordsDoNotMatch() when passwordsDoNotMatch != null:
return passwordsDoNotMatch(_that.failedValue);case Empty() when empty != null:
return empty(_that.failedValue);case ShortName() when shortName != null:
return shortName(_that.failedValue);case LongName() when longName != null:
return longName(_that.failedValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String failedValue)  invalidEmail,required TResult Function( String failedValue)  shortPassword,required TResult Function( String failedValue)  missingLowercase,required TResult Function( String failedValue)  missingUppercase,required TResult Function( String failedValue)  missingNumber,required TResult Function( String failedValue)  invalidUsername,required TResult Function( String failedValue)  shortUsername,required TResult Function( String failedValue)  longUsername,required TResult Function( String failedValue)  invalidUsernameFormat,required TResult Function( String failedValue)  passwordsDoNotMatch,required TResult Function( String failedValue)  empty,required TResult Function( String failedValue)  shortName,required TResult Function( String failedValue)  longName,}) {final _that = this;
switch (_that) {
case InvalidEmail():
return invalidEmail(_that.failedValue);case ShortPassword():
return shortPassword(_that.failedValue);case MissingLowercase():
return missingLowercase(_that.failedValue);case MissingUppercase():
return missingUppercase(_that.failedValue);case MissingNumber():
return missingNumber(_that.failedValue);case InvalidUsername():
return invalidUsername(_that.failedValue);case ShortUsername():
return shortUsername(_that.failedValue);case LongUsername():
return longUsername(_that.failedValue);case InvalidUsernameFormat():
return invalidUsernameFormat(_that.failedValue);case PasswordsDoNotMatch():
return passwordsDoNotMatch(_that.failedValue);case Empty():
return empty(_that.failedValue);case ShortName():
return shortName(_that.failedValue);case LongName():
return longName(_that.failedValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String failedValue)?  invalidEmail,TResult? Function( String failedValue)?  shortPassword,TResult? Function( String failedValue)?  missingLowercase,TResult? Function( String failedValue)?  missingUppercase,TResult? Function( String failedValue)?  missingNumber,TResult? Function( String failedValue)?  invalidUsername,TResult? Function( String failedValue)?  shortUsername,TResult? Function( String failedValue)?  longUsername,TResult? Function( String failedValue)?  invalidUsernameFormat,TResult? Function( String failedValue)?  passwordsDoNotMatch,TResult? Function( String failedValue)?  empty,TResult? Function( String failedValue)?  shortName,TResult? Function( String failedValue)?  longName,}) {final _that = this;
switch (_that) {
case InvalidEmail() when invalidEmail != null:
return invalidEmail(_that.failedValue);case ShortPassword() when shortPassword != null:
return shortPassword(_that.failedValue);case MissingLowercase() when missingLowercase != null:
return missingLowercase(_that.failedValue);case MissingUppercase() when missingUppercase != null:
return missingUppercase(_that.failedValue);case MissingNumber() when missingNumber != null:
return missingNumber(_that.failedValue);case InvalidUsername() when invalidUsername != null:
return invalidUsername(_that.failedValue);case ShortUsername() when shortUsername != null:
return shortUsername(_that.failedValue);case LongUsername() when longUsername != null:
return longUsername(_that.failedValue);case InvalidUsernameFormat() when invalidUsernameFormat != null:
return invalidUsernameFormat(_that.failedValue);case PasswordsDoNotMatch() when passwordsDoNotMatch != null:
return passwordsDoNotMatch(_that.failedValue);case Empty() when empty != null:
return empty(_that.failedValue);case ShortName() when shortName != null:
return shortName(_that.failedValue);case LongName() when longName != null:
return longName(_that.failedValue);case _:
  return null;

}
}

}

/// @nodoc


class InvalidEmail implements ValueFailure {
  const InvalidEmail(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidEmailCopyWith<InvalidEmail> get copyWith => _$InvalidEmailCopyWithImpl<InvalidEmail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidEmail&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.invalidEmail(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $InvalidEmailCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $InvalidEmailCopyWith(InvalidEmail value, $Res Function(InvalidEmail) _then) = _$InvalidEmailCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$InvalidEmailCopyWithImpl<$Res>
    implements $InvalidEmailCopyWith<$Res> {
  _$InvalidEmailCopyWithImpl(this._self, this._then);

  final InvalidEmail _self;
  final $Res Function(InvalidEmail) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(InvalidEmail(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ShortPassword implements ValueFailure {
  const ShortPassword(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShortPasswordCopyWith<ShortPassword> get copyWith => _$ShortPasswordCopyWithImpl<ShortPassword>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShortPassword&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.shortPassword(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $ShortPasswordCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $ShortPasswordCopyWith(ShortPassword value, $Res Function(ShortPassword) _then) = _$ShortPasswordCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$ShortPasswordCopyWithImpl<$Res>
    implements $ShortPasswordCopyWith<$Res> {
  _$ShortPasswordCopyWithImpl(this._self, this._then);

  final ShortPassword _self;
  final $Res Function(ShortPassword) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(ShortPassword(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingLowercase implements ValueFailure {
  const MissingLowercase(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingLowercaseCopyWith<MissingLowercase> get copyWith => _$MissingLowercaseCopyWithImpl<MissingLowercase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingLowercase&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.missingLowercase(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $MissingLowercaseCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $MissingLowercaseCopyWith(MissingLowercase value, $Res Function(MissingLowercase) _then) = _$MissingLowercaseCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$MissingLowercaseCopyWithImpl<$Res>
    implements $MissingLowercaseCopyWith<$Res> {
  _$MissingLowercaseCopyWithImpl(this._self, this._then);

  final MissingLowercase _self;
  final $Res Function(MissingLowercase) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(MissingLowercase(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingUppercase implements ValueFailure {
  const MissingUppercase(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingUppercaseCopyWith<MissingUppercase> get copyWith => _$MissingUppercaseCopyWithImpl<MissingUppercase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingUppercase&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.missingUppercase(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $MissingUppercaseCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $MissingUppercaseCopyWith(MissingUppercase value, $Res Function(MissingUppercase) _then) = _$MissingUppercaseCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$MissingUppercaseCopyWithImpl<$Res>
    implements $MissingUppercaseCopyWith<$Res> {
  _$MissingUppercaseCopyWithImpl(this._self, this._then);

  final MissingUppercase _self;
  final $Res Function(MissingUppercase) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(MissingUppercase(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MissingNumber implements ValueFailure {
  const MissingNumber(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissingNumberCopyWith<MissingNumber> get copyWith => _$MissingNumberCopyWithImpl<MissingNumber>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissingNumber&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.missingNumber(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $MissingNumberCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $MissingNumberCopyWith(MissingNumber value, $Res Function(MissingNumber) _then) = _$MissingNumberCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$MissingNumberCopyWithImpl<$Res>
    implements $MissingNumberCopyWith<$Res> {
  _$MissingNumberCopyWithImpl(this._self, this._then);

  final MissingNumber _self;
  final $Res Function(MissingNumber) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(MissingNumber(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidUsername implements ValueFailure {
  const InvalidUsername(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidUsernameCopyWith<InvalidUsername> get copyWith => _$InvalidUsernameCopyWithImpl<InvalidUsername>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidUsername&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.invalidUsername(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $InvalidUsernameCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $InvalidUsernameCopyWith(InvalidUsername value, $Res Function(InvalidUsername) _then) = _$InvalidUsernameCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$InvalidUsernameCopyWithImpl<$Res>
    implements $InvalidUsernameCopyWith<$Res> {
  _$InvalidUsernameCopyWithImpl(this._self, this._then);

  final InvalidUsername _self;
  final $Res Function(InvalidUsername) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(InvalidUsername(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ShortUsername implements ValueFailure {
  const ShortUsername(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShortUsernameCopyWith<ShortUsername> get copyWith => _$ShortUsernameCopyWithImpl<ShortUsername>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShortUsername&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.shortUsername(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $ShortUsernameCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $ShortUsernameCopyWith(ShortUsername value, $Res Function(ShortUsername) _then) = _$ShortUsernameCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$ShortUsernameCopyWithImpl<$Res>
    implements $ShortUsernameCopyWith<$Res> {
  _$ShortUsernameCopyWithImpl(this._self, this._then);

  final ShortUsername _self;
  final $Res Function(ShortUsername) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(ShortUsername(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LongUsername implements ValueFailure {
  const LongUsername(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LongUsernameCopyWith<LongUsername> get copyWith => _$LongUsernameCopyWithImpl<LongUsername>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LongUsername&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.longUsername(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $LongUsernameCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $LongUsernameCopyWith(LongUsername value, $Res Function(LongUsername) _then) = _$LongUsernameCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$LongUsernameCopyWithImpl<$Res>
    implements $LongUsernameCopyWith<$Res> {
  _$LongUsernameCopyWithImpl(this._self, this._then);

  final LongUsername _self;
  final $Res Function(LongUsername) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(LongUsername(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class InvalidUsernameFormat implements ValueFailure {
  const InvalidUsernameFormat(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvalidUsernameFormatCopyWith<InvalidUsernameFormat> get copyWith => _$InvalidUsernameFormatCopyWithImpl<InvalidUsernameFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidUsernameFormat&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.invalidUsernameFormat(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $InvalidUsernameFormatCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $InvalidUsernameFormatCopyWith(InvalidUsernameFormat value, $Res Function(InvalidUsernameFormat) _then) = _$InvalidUsernameFormatCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$InvalidUsernameFormatCopyWithImpl<$Res>
    implements $InvalidUsernameFormatCopyWith<$Res> {
  _$InvalidUsernameFormatCopyWithImpl(this._self, this._then);

  final InvalidUsernameFormat _self;
  final $Res Function(InvalidUsernameFormat) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(InvalidUsernameFormat(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PasswordsDoNotMatch implements ValueFailure {
  const PasswordsDoNotMatch(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordsDoNotMatchCopyWith<PasswordsDoNotMatch> get copyWith => _$PasswordsDoNotMatchCopyWithImpl<PasswordsDoNotMatch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordsDoNotMatch&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.passwordsDoNotMatch(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $PasswordsDoNotMatchCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $PasswordsDoNotMatchCopyWith(PasswordsDoNotMatch value, $Res Function(PasswordsDoNotMatch) _then) = _$PasswordsDoNotMatchCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$PasswordsDoNotMatchCopyWithImpl<$Res>
    implements $PasswordsDoNotMatchCopyWith<$Res> {
  _$PasswordsDoNotMatchCopyWithImpl(this._self, this._then);

  final PasswordsDoNotMatch _self;
  final $Res Function(PasswordsDoNotMatch) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(PasswordsDoNotMatch(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Empty implements ValueFailure {
  const Empty(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmptyCopyWith<Empty> get copyWith => _$EmptyCopyWithImpl<Empty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Empty&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.empty(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $EmptyCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $EmptyCopyWith(Empty value, $Res Function(Empty) _then) = _$EmptyCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$EmptyCopyWithImpl<$Res>
    implements $EmptyCopyWith<$Res> {
  _$EmptyCopyWithImpl(this._self, this._then);

  final Empty _self;
  final $Res Function(Empty) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(Empty(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ShortName implements ValueFailure {
  const ShortName(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShortNameCopyWith<ShortName> get copyWith => _$ShortNameCopyWithImpl<ShortName>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShortName&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.shortName(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $ShortNameCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $ShortNameCopyWith(ShortName value, $Res Function(ShortName) _then) = _$ShortNameCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$ShortNameCopyWithImpl<$Res>
    implements $ShortNameCopyWith<$Res> {
  _$ShortNameCopyWithImpl(this._self, this._then);

  final ShortName _self;
  final $Res Function(ShortName) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(ShortName(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LongName implements ValueFailure {
  const LongName(this.failedValue);
  

@override final  String failedValue;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LongNameCopyWith<LongName> get copyWith => _$LongNameCopyWithImpl<LongName>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LongName&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'ValueFailure.longName(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $LongNameCopyWith<$Res> implements $ValueFailureCopyWith<$Res> {
  factory $LongNameCopyWith(LongName value, $Res Function(LongName) _then) = _$LongNameCopyWithImpl;
@override @useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$LongNameCopyWithImpl<$Res>
    implements $LongNameCopyWith<$Res> {
  _$LongNameCopyWithImpl(this._self, this._then);

  final LongName _self;
  final $Res Function(LongName) _then;

/// Create a copy of ValueFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(LongName(
null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
