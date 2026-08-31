// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merchant_reference_data_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MerchantReferenceDataDto {

 List<MerchantBusinessTypeOptionDto> get businessTypes; List<MerchantLabeledOptionDto> get industries; List<MerchantLabeledOptionDto> get monthlySalesRanges; List<MerchantOwnerRoleOptionDto> get ownerRoles; List<MerchantBankOptionDto> get banks; List<MerchantAccountHolderTypeOptionDto> get accountHolderTypes; List<MerchantLabeledOptionDto> get payoutSchedules; String get termsVersion;
/// Create a copy of MerchantReferenceDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantReferenceDataDtoCopyWith<MerchantReferenceDataDto> get copyWith => _$MerchantReferenceDataDtoCopyWithImpl<MerchantReferenceDataDto>(this as MerchantReferenceDataDto, _$identity);

  /// Serializes this MerchantReferenceDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantReferenceDataDto&&const DeepCollectionEquality().equals(other.businessTypes, businessTypes)&&const DeepCollectionEquality().equals(other.industries, industries)&&const DeepCollectionEquality().equals(other.monthlySalesRanges, monthlySalesRanges)&&const DeepCollectionEquality().equals(other.ownerRoles, ownerRoles)&&const DeepCollectionEquality().equals(other.banks, banks)&&const DeepCollectionEquality().equals(other.accountHolderTypes, accountHolderTypes)&&const DeepCollectionEquality().equals(other.payoutSchedules, payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(businessTypes),const DeepCollectionEquality().hash(industries),const DeepCollectionEquality().hash(monthlySalesRanges),const DeepCollectionEquality().hash(ownerRoles),const DeepCollectionEquality().hash(banks),const DeepCollectionEquality().hash(accountHolderTypes),const DeepCollectionEquality().hash(payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataDto(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, accountHolderTypes: $accountHolderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $MerchantReferenceDataDtoCopyWith<$Res>  {
  factory $MerchantReferenceDataDtoCopyWith(MerchantReferenceDataDto value, $Res Function(MerchantReferenceDataDto) _then) = _$MerchantReferenceDataDtoCopyWithImpl;
@useResult
$Res call({
 List<MerchantBusinessTypeOptionDto> businessTypes, List<MerchantLabeledOptionDto> industries, List<MerchantLabeledOptionDto> monthlySalesRanges, List<MerchantOwnerRoleOptionDto> ownerRoles, List<MerchantBankOptionDto> banks, List<MerchantAccountHolderTypeOptionDto> accountHolderTypes, List<MerchantLabeledOptionDto> payoutSchedules, String termsVersion
});




}
/// @nodoc
class _$MerchantReferenceDataDtoCopyWithImpl<$Res>
    implements $MerchantReferenceDataDtoCopyWith<$Res> {
  _$MerchantReferenceDataDtoCopyWithImpl(this._self, this._then);

  final MerchantReferenceDataDto _self;
  final $Res Function(MerchantReferenceDataDto) _then;

/// Create a copy of MerchantReferenceDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? accountHolderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_self.copyWith(
businessTypes: null == businessTypes ? _self.businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantBusinessTypeOptionDto>,industries: null == industries ? _self.industries : industries // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,monthlySalesRanges: null == monthlySalesRanges ? _self.monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,ownerRoles: null == ownerRoles ? _self.ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerRoleOptionDto>,banks: null == banks ? _self.banks : banks // ignore: cast_nullable_to_non_nullable
as List<MerchantBankOptionDto>,accountHolderTypes: null == accountHolderTypes ? _self.accountHolderTypes : accountHolderTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantAccountHolderTypeOptionDto>,payoutSchedules: null == payoutSchedules ? _self.payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantReferenceDataDto].
extension MerchantReferenceDataDtoPatterns on MerchantReferenceDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantReferenceDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantReferenceDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantReferenceDataDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantReferenceDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MerchantBusinessTypeOptionDto> businessTypes,  List<MerchantLabeledOptionDto> industries,  List<MerchantLabeledOptionDto> monthlySalesRanges,  List<MerchantOwnerRoleOptionDto> ownerRoles,  List<MerchantBankOptionDto> banks,  List<MerchantAccountHolderTypeOptionDto> accountHolderTypes,  List<MerchantLabeledOptionDto> payoutSchedules,  String termsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantReferenceDataDto() when $default != null:
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.accountHolderTypes,_that.payoutSchedules,_that.termsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MerchantBusinessTypeOptionDto> businessTypes,  List<MerchantLabeledOptionDto> industries,  List<MerchantLabeledOptionDto> monthlySalesRanges,  List<MerchantOwnerRoleOptionDto> ownerRoles,  List<MerchantBankOptionDto> banks,  List<MerchantAccountHolderTypeOptionDto> accountHolderTypes,  List<MerchantLabeledOptionDto> payoutSchedules,  String termsVersion)  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataDto():
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.accountHolderTypes,_that.payoutSchedules,_that.termsVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MerchantBusinessTypeOptionDto> businessTypes,  List<MerchantLabeledOptionDto> industries,  List<MerchantLabeledOptionDto> monthlySalesRanges,  List<MerchantOwnerRoleOptionDto> ownerRoles,  List<MerchantBankOptionDto> banks,  List<MerchantAccountHolderTypeOptionDto> accountHolderTypes,  List<MerchantLabeledOptionDto> payoutSchedules,  String termsVersion)?  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataDto() when $default != null:
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.accountHolderTypes,_that.payoutSchedules,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantReferenceDataDto implements MerchantReferenceDataDto {
  const _MerchantReferenceDataDto({required final  List<MerchantBusinessTypeOptionDto> businessTypes, required final  List<MerchantLabeledOptionDto> industries, required final  List<MerchantLabeledOptionDto> monthlySalesRanges, required final  List<MerchantOwnerRoleOptionDto> ownerRoles, required final  List<MerchantBankOptionDto> banks, required final  List<MerchantAccountHolderTypeOptionDto> accountHolderTypes, required final  List<MerchantLabeledOptionDto> payoutSchedules, required this.termsVersion}): _businessTypes = businessTypes,_industries = industries,_monthlySalesRanges = monthlySalesRanges,_ownerRoles = ownerRoles,_banks = banks,_accountHolderTypes = accountHolderTypes,_payoutSchedules = payoutSchedules;
  factory _MerchantReferenceDataDto.fromJson(Map<String, dynamic> json) => _$MerchantReferenceDataDtoFromJson(json);

 final  List<MerchantBusinessTypeOptionDto> _businessTypes;
@override List<MerchantBusinessTypeOptionDto> get businessTypes {
  if (_businessTypes is EqualUnmodifiableListView) return _businessTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_businessTypes);
}

 final  List<MerchantLabeledOptionDto> _industries;
@override List<MerchantLabeledOptionDto> get industries {
  if (_industries is EqualUnmodifiableListView) return _industries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_industries);
}

 final  List<MerchantLabeledOptionDto> _monthlySalesRanges;
@override List<MerchantLabeledOptionDto> get monthlySalesRanges {
  if (_monthlySalesRanges is EqualUnmodifiableListView) return _monthlySalesRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlySalesRanges);
}

 final  List<MerchantOwnerRoleOptionDto> _ownerRoles;
@override List<MerchantOwnerRoleOptionDto> get ownerRoles {
  if (_ownerRoles is EqualUnmodifiableListView) return _ownerRoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownerRoles);
}

 final  List<MerchantBankOptionDto> _banks;
@override List<MerchantBankOptionDto> get banks {
  if (_banks is EqualUnmodifiableListView) return _banks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banks);
}

 final  List<MerchantAccountHolderTypeOptionDto> _accountHolderTypes;
@override List<MerchantAccountHolderTypeOptionDto> get accountHolderTypes {
  if (_accountHolderTypes is EqualUnmodifiableListView) return _accountHolderTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountHolderTypes);
}

 final  List<MerchantLabeledOptionDto> _payoutSchedules;
@override List<MerchantLabeledOptionDto> get payoutSchedules {
  if (_payoutSchedules is EqualUnmodifiableListView) return _payoutSchedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payoutSchedules);
}

@override final  String termsVersion;

/// Create a copy of MerchantReferenceDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantReferenceDataDtoCopyWith<_MerchantReferenceDataDto> get copyWith => __$MerchantReferenceDataDtoCopyWithImpl<_MerchantReferenceDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantReferenceDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantReferenceDataDto&&const DeepCollectionEquality().equals(other._businessTypes, _businessTypes)&&const DeepCollectionEquality().equals(other._industries, _industries)&&const DeepCollectionEquality().equals(other._monthlySalesRanges, _monthlySalesRanges)&&const DeepCollectionEquality().equals(other._ownerRoles, _ownerRoles)&&const DeepCollectionEquality().equals(other._banks, _banks)&&const DeepCollectionEquality().equals(other._accountHolderTypes, _accountHolderTypes)&&const DeepCollectionEquality().equals(other._payoutSchedules, _payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_businessTypes),const DeepCollectionEquality().hash(_industries),const DeepCollectionEquality().hash(_monthlySalesRanges),const DeepCollectionEquality().hash(_ownerRoles),const DeepCollectionEquality().hash(_banks),const DeepCollectionEquality().hash(_accountHolderTypes),const DeepCollectionEquality().hash(_payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataDto(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, accountHolderTypes: $accountHolderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class _$MerchantReferenceDataDtoCopyWith<$Res> implements $MerchantReferenceDataDtoCopyWith<$Res> {
  factory _$MerchantReferenceDataDtoCopyWith(_MerchantReferenceDataDto value, $Res Function(_MerchantReferenceDataDto) _then) = __$MerchantReferenceDataDtoCopyWithImpl;
@override @useResult
$Res call({
 List<MerchantBusinessTypeOptionDto> businessTypes, List<MerchantLabeledOptionDto> industries, List<MerchantLabeledOptionDto> monthlySalesRanges, List<MerchantOwnerRoleOptionDto> ownerRoles, List<MerchantBankOptionDto> banks, List<MerchantAccountHolderTypeOptionDto> accountHolderTypes, List<MerchantLabeledOptionDto> payoutSchedules, String termsVersion
});




}
/// @nodoc
class __$MerchantReferenceDataDtoCopyWithImpl<$Res>
    implements _$MerchantReferenceDataDtoCopyWith<$Res> {
  __$MerchantReferenceDataDtoCopyWithImpl(this._self, this._then);

  final _MerchantReferenceDataDto _self;
  final $Res Function(_MerchantReferenceDataDto) _then;

/// Create a copy of MerchantReferenceDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? accountHolderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_MerchantReferenceDataDto(
businessTypes: null == businessTypes ? _self._businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantBusinessTypeOptionDto>,industries: null == industries ? _self._industries : industries // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,monthlySalesRanges: null == monthlySalesRanges ? _self._monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,ownerRoles: null == ownerRoles ? _self._ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerRoleOptionDto>,banks: null == banks ? _self._banks : banks // ignore: cast_nullable_to_non_nullable
as List<MerchantBankOptionDto>,accountHolderTypes: null == accountHolderTypes ? _self._accountHolderTypes : accountHolderTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantAccountHolderTypeOptionDto>,payoutSchedules: null == payoutSchedules ? _self._payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionDto>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantBusinessTypeOptionDto {

 String get id; String get label; bool get requiresRegistrationNumber;
/// Create a copy of MerchantBusinessTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBusinessTypeOptionDtoCopyWith<MerchantBusinessTypeOptionDto> get copyWith => _$MerchantBusinessTypeOptionDtoCopyWithImpl<MerchantBusinessTypeOptionDto>(this as MerchantBusinessTypeOptionDto, _$identity);

  /// Serializes this MerchantBusinessTypeOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBusinessTypeOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'MerchantBusinessTypeOptionDto(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class $MerchantBusinessTypeOptionDtoCopyWith<$Res>  {
  factory $MerchantBusinessTypeOptionDtoCopyWith(MerchantBusinessTypeOptionDto value, $Res Function(MerchantBusinessTypeOptionDto) _then) = _$MerchantBusinessTypeOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class _$MerchantBusinessTypeOptionDtoCopyWithImpl<$Res>
    implements $MerchantBusinessTypeOptionDtoCopyWith<$Res> {
  _$MerchantBusinessTypeOptionDtoCopyWithImpl(this._self, this._then);

  final MerchantBusinessTypeOptionDto _self;
  final $Res Function(MerchantBusinessTypeOptionDto) _then;

/// Create a copy of MerchantBusinessTypeOptionDto
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


/// Adds pattern-matching-related methods to [MerchantBusinessTypeOptionDto].
extension MerchantBusinessTypeOptionDtoPatterns on MerchantBusinessTypeOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBusinessTypeOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBusinessTypeOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBusinessTypeOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionDto() when $default != null:
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
case _MerchantBusinessTypeOptionDto() when $default != null:
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
case _MerchantBusinessTypeOptionDto():
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
case _MerchantBusinessTypeOptionDto() when $default != null:
return $default(_that.id,_that.label,_that.requiresRegistrationNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBusinessTypeOptionDto implements MerchantBusinessTypeOptionDto {
  const _MerchantBusinessTypeOptionDto({required this.id, required this.label, required this.requiresRegistrationNumber});
  factory _MerchantBusinessTypeOptionDto.fromJson(Map<String, dynamic> json) => _$MerchantBusinessTypeOptionDtoFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool requiresRegistrationNumber;

/// Create a copy of MerchantBusinessTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBusinessTypeOptionDtoCopyWith<_MerchantBusinessTypeOptionDto> get copyWith => __$MerchantBusinessTypeOptionDtoCopyWithImpl<_MerchantBusinessTypeOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBusinessTypeOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBusinessTypeOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'MerchantBusinessTypeOptionDto(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class _$MerchantBusinessTypeOptionDtoCopyWith<$Res> implements $MerchantBusinessTypeOptionDtoCopyWith<$Res> {
  factory _$MerchantBusinessTypeOptionDtoCopyWith(_MerchantBusinessTypeOptionDto value, $Res Function(_MerchantBusinessTypeOptionDto) _then) = __$MerchantBusinessTypeOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class __$MerchantBusinessTypeOptionDtoCopyWithImpl<$Res>
    implements _$MerchantBusinessTypeOptionDtoCopyWith<$Res> {
  __$MerchantBusinessTypeOptionDtoCopyWithImpl(this._self, this._then);

  final _MerchantBusinessTypeOptionDto _self;
  final $Res Function(_MerchantBusinessTypeOptionDto) _then;

/// Create a copy of MerchantBusinessTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresRegistrationNumber = null,}) {
  return _then(_MerchantBusinessTypeOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresRegistrationNumber: null == requiresRegistrationNumber ? _self.requiresRegistrationNumber : requiresRegistrationNumber // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MerchantLabeledOptionDto {

 String get id; String get label;
/// Create a copy of MerchantLabeledOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantLabeledOptionDtoCopyWith<MerchantLabeledOptionDto> get copyWith => _$MerchantLabeledOptionDtoCopyWithImpl<MerchantLabeledOptionDto>(this as MerchantLabeledOptionDto, _$identity);

  /// Serializes this MerchantLabeledOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantLabeledOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'MerchantLabeledOptionDto(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class $MerchantLabeledOptionDtoCopyWith<$Res>  {
  factory $MerchantLabeledOptionDtoCopyWith(MerchantLabeledOptionDto value, $Res Function(MerchantLabeledOptionDto) _then) = _$MerchantLabeledOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$MerchantLabeledOptionDtoCopyWithImpl<$Res>
    implements $MerchantLabeledOptionDtoCopyWith<$Res> {
  _$MerchantLabeledOptionDtoCopyWithImpl(this._self, this._then);

  final MerchantLabeledOptionDto _self;
  final $Res Function(MerchantLabeledOptionDto) _then;

/// Create a copy of MerchantLabeledOptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantLabeledOptionDto].
extension MerchantLabeledOptionDtoPatterns on MerchantLabeledOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantLabeledOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantLabeledOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantLabeledOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionDto() when $default != null:
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
case _MerchantLabeledOptionDto() when $default != null:
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
case _MerchantLabeledOptionDto():
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
case _MerchantLabeledOptionDto() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantLabeledOptionDto implements MerchantLabeledOptionDto {
  const _MerchantLabeledOptionDto({required this.id, required this.label});
  factory _MerchantLabeledOptionDto.fromJson(Map<String, dynamic> json) => _$MerchantLabeledOptionDtoFromJson(json);

@override final  String id;
@override final  String label;

/// Create a copy of MerchantLabeledOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantLabeledOptionDtoCopyWith<_MerchantLabeledOptionDto> get copyWith => __$MerchantLabeledOptionDtoCopyWithImpl<_MerchantLabeledOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantLabeledOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantLabeledOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'MerchantLabeledOptionDto(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$MerchantLabeledOptionDtoCopyWith<$Res> implements $MerchantLabeledOptionDtoCopyWith<$Res> {
  factory _$MerchantLabeledOptionDtoCopyWith(_MerchantLabeledOptionDto value, $Res Function(_MerchantLabeledOptionDto) _then) = __$MerchantLabeledOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class __$MerchantLabeledOptionDtoCopyWithImpl<$Res>
    implements _$MerchantLabeledOptionDtoCopyWith<$Res> {
  __$MerchantLabeledOptionDtoCopyWithImpl(this._self, this._then);

  final _MerchantLabeledOptionDto _self;
  final $Res Function(_MerchantLabeledOptionDto) _then;

/// Create a copy of MerchantLabeledOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_MerchantLabeledOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantOwnerRoleOptionDto {

 String get id; String get label; bool get contributesOwnership;
/// Create a copy of MerchantOwnerRoleOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOwnerRoleOptionDtoCopyWith<MerchantOwnerRoleOptionDto> get copyWith => _$MerchantOwnerRoleOptionDtoCopyWithImpl<MerchantOwnerRoleOptionDto>(this as MerchantOwnerRoleOptionDto, _$identity);

  /// Serializes this MerchantOwnerRoleOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOwnerRoleOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'MerchantOwnerRoleOptionDto(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class $MerchantOwnerRoleOptionDtoCopyWith<$Res>  {
  factory $MerchantOwnerRoleOptionDtoCopyWith(MerchantOwnerRoleOptionDto value, $Res Function(MerchantOwnerRoleOptionDto) _then) = _$MerchantOwnerRoleOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class _$MerchantOwnerRoleOptionDtoCopyWithImpl<$Res>
    implements $MerchantOwnerRoleOptionDtoCopyWith<$Res> {
  _$MerchantOwnerRoleOptionDtoCopyWithImpl(this._self, this._then);

  final MerchantOwnerRoleOptionDto _self;
  final $Res Function(MerchantOwnerRoleOptionDto) _then;

/// Create a copy of MerchantOwnerRoleOptionDto
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


/// Adds pattern-matching-related methods to [MerchantOwnerRoleOptionDto].
extension MerchantOwnerRoleOptionDtoPatterns on MerchantOwnerRoleOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOwnerRoleOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOwnerRoleOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOwnerRoleOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionDto() when $default != null:
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
case _MerchantOwnerRoleOptionDto() when $default != null:
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
case _MerchantOwnerRoleOptionDto():
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
case _MerchantOwnerRoleOptionDto() when $default != null:
return $default(_that.id,_that.label,_that.contributesOwnership);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOwnerRoleOptionDto implements MerchantOwnerRoleOptionDto {
  const _MerchantOwnerRoleOptionDto({required this.id, required this.label, required this.contributesOwnership});
  factory _MerchantOwnerRoleOptionDto.fromJson(Map<String, dynamic> json) => _$MerchantOwnerRoleOptionDtoFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool contributesOwnership;

/// Create a copy of MerchantOwnerRoleOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOwnerRoleOptionDtoCopyWith<_MerchantOwnerRoleOptionDto> get copyWith => __$MerchantOwnerRoleOptionDtoCopyWithImpl<_MerchantOwnerRoleOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOwnerRoleOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOwnerRoleOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'MerchantOwnerRoleOptionDto(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class _$MerchantOwnerRoleOptionDtoCopyWith<$Res> implements $MerchantOwnerRoleOptionDtoCopyWith<$Res> {
  factory _$MerchantOwnerRoleOptionDtoCopyWith(_MerchantOwnerRoleOptionDto value, $Res Function(_MerchantOwnerRoleOptionDto) _then) = __$MerchantOwnerRoleOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class __$MerchantOwnerRoleOptionDtoCopyWithImpl<$Res>
    implements _$MerchantOwnerRoleOptionDtoCopyWith<$Res> {
  __$MerchantOwnerRoleOptionDtoCopyWithImpl(this._self, this._then);

  final _MerchantOwnerRoleOptionDto _self;
  final $Res Function(_MerchantOwnerRoleOptionDto) _then;

/// Create a copy of MerchantOwnerRoleOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? contributesOwnership = null,}) {
  return _then(_MerchantOwnerRoleOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contributesOwnership: null == contributesOwnership ? _self.contributesOwnership : contributesOwnership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MerchantBankOptionDto {

 String get id; String get label; List<String> get supportedPayoutScheduleIds;
/// Create a copy of MerchantBankOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBankOptionDtoCopyWith<MerchantBankOptionDto> get copyWith => _$MerchantBankOptionDtoCopyWithImpl<MerchantBankOptionDto>(this as MerchantBankOptionDto, _$identity);

  /// Serializes this MerchantBankOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBankOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.supportedPayoutScheduleIds, supportedPayoutScheduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(supportedPayoutScheduleIds));

@override
String toString() {
  return 'MerchantBankOptionDto(id: $id, label: $label, supportedPayoutScheduleIds: $supportedPayoutScheduleIds)';
}


}

/// @nodoc
abstract mixin class $MerchantBankOptionDtoCopyWith<$Res>  {
  factory $MerchantBankOptionDtoCopyWith(MerchantBankOptionDto value, $Res Function(MerchantBankOptionDto) _then) = _$MerchantBankOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label, List<String> supportedPayoutScheduleIds
});




}
/// @nodoc
class _$MerchantBankOptionDtoCopyWithImpl<$Res>
    implements $MerchantBankOptionDtoCopyWith<$Res> {
  _$MerchantBankOptionDtoCopyWithImpl(this._self, this._then);

  final MerchantBankOptionDto _self;
  final $Res Function(MerchantBankOptionDto) _then;

/// Create a copy of MerchantBankOptionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? supportedPayoutScheduleIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,supportedPayoutScheduleIds: null == supportedPayoutScheduleIds ? _self.supportedPayoutScheduleIds : supportedPayoutScheduleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantBankOptionDto].
extension MerchantBankOptionDtoPatterns on MerchantBankOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBankOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBankOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBankOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBankOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBankOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBankOptionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  List<String> supportedPayoutScheduleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantBankOptionDto() when $default != null:
return $default(_that.id,_that.label,_that.supportedPayoutScheduleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  List<String> supportedPayoutScheduleIds)  $default,) {final _that = this;
switch (_that) {
case _MerchantBankOptionDto():
return $default(_that.id,_that.label,_that.supportedPayoutScheduleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  List<String> supportedPayoutScheduleIds)?  $default,) {final _that = this;
switch (_that) {
case _MerchantBankOptionDto() when $default != null:
return $default(_that.id,_that.label,_that.supportedPayoutScheduleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBankOptionDto implements MerchantBankOptionDto {
  const _MerchantBankOptionDto({required this.id, required this.label, required final  List<String> supportedPayoutScheduleIds}): _supportedPayoutScheduleIds = supportedPayoutScheduleIds;
  factory _MerchantBankOptionDto.fromJson(Map<String, dynamic> json) => _$MerchantBankOptionDtoFromJson(json);

@override final  String id;
@override final  String label;
 final  List<String> _supportedPayoutScheduleIds;
@override List<String> get supportedPayoutScheduleIds {
  if (_supportedPayoutScheduleIds is EqualUnmodifiableListView) return _supportedPayoutScheduleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedPayoutScheduleIds);
}


/// Create a copy of MerchantBankOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBankOptionDtoCopyWith<_MerchantBankOptionDto> get copyWith => __$MerchantBankOptionDtoCopyWithImpl<_MerchantBankOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBankOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBankOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._supportedPayoutScheduleIds, _supportedPayoutScheduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(_supportedPayoutScheduleIds));

@override
String toString() {
  return 'MerchantBankOptionDto(id: $id, label: $label, supportedPayoutScheduleIds: $supportedPayoutScheduleIds)';
}


}

/// @nodoc
abstract mixin class _$MerchantBankOptionDtoCopyWith<$Res> implements $MerchantBankOptionDtoCopyWith<$Res> {
  factory _$MerchantBankOptionDtoCopyWith(_MerchantBankOptionDto value, $Res Function(_MerchantBankOptionDto) _then) = __$MerchantBankOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, List<String> supportedPayoutScheduleIds
});




}
/// @nodoc
class __$MerchantBankOptionDtoCopyWithImpl<$Res>
    implements _$MerchantBankOptionDtoCopyWith<$Res> {
  __$MerchantBankOptionDtoCopyWithImpl(this._self, this._then);

  final _MerchantBankOptionDto _self;
  final $Res Function(_MerchantBankOptionDto) _then;

/// Create a copy of MerchantBankOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? supportedPayoutScheduleIds = null,}) {
  return _then(_MerchantBankOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,supportedPayoutScheduleIds: null == supportedPayoutScheduleIds ? _self._supportedPayoutScheduleIds : supportedPayoutScheduleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MerchantAccountHolderTypeOptionDto {

 String get id; String get label; bool get requiresOwnerReference;
/// Create a copy of MerchantAccountHolderTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantAccountHolderTypeOptionDtoCopyWith<MerchantAccountHolderTypeOptionDto> get copyWith => _$MerchantAccountHolderTypeOptionDtoCopyWithImpl<MerchantAccountHolderTypeOptionDto>(this as MerchantAccountHolderTypeOptionDto, _$identity);

  /// Serializes this MerchantAccountHolderTypeOptionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantAccountHolderTypeOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'MerchantAccountHolderTypeOptionDto(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class $MerchantAccountHolderTypeOptionDtoCopyWith<$Res>  {
  factory $MerchantAccountHolderTypeOptionDtoCopyWith(MerchantAccountHolderTypeOptionDto value, $Res Function(MerchantAccountHolderTypeOptionDto) _then) = _$MerchantAccountHolderTypeOptionDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class _$MerchantAccountHolderTypeOptionDtoCopyWithImpl<$Res>
    implements $MerchantAccountHolderTypeOptionDtoCopyWith<$Res> {
  _$MerchantAccountHolderTypeOptionDtoCopyWithImpl(this._self, this._then);

  final MerchantAccountHolderTypeOptionDto _self;
  final $Res Function(MerchantAccountHolderTypeOptionDto) _then;

/// Create a copy of MerchantAccountHolderTypeOptionDto
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


/// Adds pattern-matching-related methods to [MerchantAccountHolderTypeOptionDto].
extension MerchantAccountHolderTypeOptionDtoPatterns on MerchantAccountHolderTypeOptionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantAccountHolderTypeOptionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantAccountHolderTypeOptionDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantAccountHolderTypeOptionDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionDto() when $default != null:
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
case _MerchantAccountHolderTypeOptionDto() when $default != null:
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
case _MerchantAccountHolderTypeOptionDto():
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
case _MerchantAccountHolderTypeOptionDto() when $default != null:
return $default(_that.id,_that.label,_that.requiresOwnerReference);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantAccountHolderTypeOptionDto implements MerchantAccountHolderTypeOptionDto {
  const _MerchantAccountHolderTypeOptionDto({required this.id, required this.label, required this.requiresOwnerReference});
  factory _MerchantAccountHolderTypeOptionDto.fromJson(Map<String, dynamic> json) => _$MerchantAccountHolderTypeOptionDtoFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool requiresOwnerReference;

/// Create a copy of MerchantAccountHolderTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantAccountHolderTypeOptionDtoCopyWith<_MerchantAccountHolderTypeOptionDto> get copyWith => __$MerchantAccountHolderTypeOptionDtoCopyWithImpl<_MerchantAccountHolderTypeOptionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantAccountHolderTypeOptionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantAccountHolderTypeOptionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'MerchantAccountHolderTypeOptionDto(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class _$MerchantAccountHolderTypeOptionDtoCopyWith<$Res> implements $MerchantAccountHolderTypeOptionDtoCopyWith<$Res> {
  factory _$MerchantAccountHolderTypeOptionDtoCopyWith(_MerchantAccountHolderTypeOptionDto value, $Res Function(_MerchantAccountHolderTypeOptionDto) _then) = __$MerchantAccountHolderTypeOptionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class __$MerchantAccountHolderTypeOptionDtoCopyWithImpl<$Res>
    implements _$MerchantAccountHolderTypeOptionDtoCopyWith<$Res> {
  __$MerchantAccountHolderTypeOptionDtoCopyWithImpl(this._self, this._then);

  final _MerchantAccountHolderTypeOptionDto _self;
  final $Res Function(_MerchantAccountHolderTypeOptionDto) _then;

/// Create a copy of MerchantAccountHolderTypeOptionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresOwnerReference = null,}) {
  return _then(_MerchantAccountHolderTypeOptionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresOwnerReference: null == requiresOwnerReference ? _self.requiresOwnerReference : requiresOwnerReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
