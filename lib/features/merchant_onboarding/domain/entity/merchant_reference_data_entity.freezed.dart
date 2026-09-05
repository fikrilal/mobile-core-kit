// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merchant_reference_data_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MerchantReferenceDataEntity {

 List<BusinessTypeOptionEntity> get businessTypes; List<ReferenceOptionEntity> get industries; List<ReferenceOptionEntity> get monthlySalesRanges; List<OwnerRoleOptionEntity> get ownerRoles; List<BankOptionEntity> get banks; List<AccountHolderTypeOptionEntity> get holderTypes; List<ReferenceOptionEntity> get payoutSchedules; String get termsVersion;
/// Create a copy of MerchantReferenceDataEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantReferenceDataEntityCopyWith<MerchantReferenceDataEntity> get copyWith => _$MerchantReferenceDataEntityCopyWithImpl<MerchantReferenceDataEntity>(this as MerchantReferenceDataEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantReferenceDataEntity&&const DeepCollectionEquality().equals(other.businessTypes, businessTypes)&&const DeepCollectionEquality().equals(other.industries, industries)&&const DeepCollectionEquality().equals(other.monthlySalesRanges, monthlySalesRanges)&&const DeepCollectionEquality().equals(other.ownerRoles, ownerRoles)&&const DeepCollectionEquality().equals(other.banks, banks)&&const DeepCollectionEquality().equals(other.holderTypes, holderTypes)&&const DeepCollectionEquality().equals(other.payoutSchedules, payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(businessTypes),const DeepCollectionEquality().hash(industries),const DeepCollectionEquality().hash(monthlySalesRanges),const DeepCollectionEquality().hash(ownerRoles),const DeepCollectionEquality().hash(banks),const DeepCollectionEquality().hash(holderTypes),const DeepCollectionEquality().hash(payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataEntity(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, holderTypes: $holderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $MerchantReferenceDataEntityCopyWith<$Res>  {
  factory $MerchantReferenceDataEntityCopyWith(MerchantReferenceDataEntity value, $Res Function(MerchantReferenceDataEntity) _then) = _$MerchantReferenceDataEntityCopyWithImpl;
@useResult
$Res call({
 List<BusinessTypeOptionEntity> businessTypes, List<ReferenceOptionEntity> industries, List<ReferenceOptionEntity> monthlySalesRanges, List<OwnerRoleOptionEntity> ownerRoles, List<BankOptionEntity> banks, List<AccountHolderTypeOptionEntity> holderTypes, List<ReferenceOptionEntity> payoutSchedules, String termsVersion
});




}
/// @nodoc
class _$MerchantReferenceDataEntityCopyWithImpl<$Res>
    implements $MerchantReferenceDataEntityCopyWith<$Res> {
  _$MerchantReferenceDataEntityCopyWithImpl(this._self, this._then);

  final MerchantReferenceDataEntity _self;
  final $Res Function(MerchantReferenceDataEntity) _then;

/// Create a copy of MerchantReferenceDataEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? holderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_self.copyWith(
businessTypes: null == businessTypes ? _self.businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<BusinessTypeOptionEntity>,industries: null == industries ? _self.industries : industries // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,monthlySalesRanges: null == monthlySalesRanges ? _self.monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,ownerRoles: null == ownerRoles ? _self.ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<OwnerRoleOptionEntity>,banks: null == banks ? _self.banks : banks // ignore: cast_nullable_to_non_nullable
as List<BankOptionEntity>,holderTypes: null == holderTypes ? _self.holderTypes : holderTypes // ignore: cast_nullable_to_non_nullable
as List<AccountHolderTypeOptionEntity>,payoutSchedules: null == payoutSchedules ? _self.payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantReferenceDataEntity].
extension MerchantReferenceDataEntityPatterns on MerchantReferenceDataEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantReferenceDataEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantReferenceDataEntity value)  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantReferenceDataEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BusinessTypeOptionEntity> businessTypes,  List<ReferenceOptionEntity> industries,  List<ReferenceOptionEntity> monthlySalesRanges,  List<OwnerRoleOptionEntity> ownerRoles,  List<BankOptionEntity> banks,  List<AccountHolderTypeOptionEntity> holderTypes,  List<ReferenceOptionEntity> payoutSchedules,  String termsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity() when $default != null:
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.holderTypes,_that.payoutSchedules,_that.termsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BusinessTypeOptionEntity> businessTypes,  List<ReferenceOptionEntity> industries,  List<ReferenceOptionEntity> monthlySalesRanges,  List<OwnerRoleOptionEntity> ownerRoles,  List<BankOptionEntity> banks,  List<AccountHolderTypeOptionEntity> holderTypes,  List<ReferenceOptionEntity> payoutSchedules,  String termsVersion)  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity():
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.holderTypes,_that.payoutSchedules,_that.termsVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BusinessTypeOptionEntity> businessTypes,  List<ReferenceOptionEntity> industries,  List<ReferenceOptionEntity> monthlySalesRanges,  List<OwnerRoleOptionEntity> ownerRoles,  List<BankOptionEntity> banks,  List<AccountHolderTypeOptionEntity> holderTypes,  List<ReferenceOptionEntity> payoutSchedules,  String termsVersion)?  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataEntity() when $default != null:
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.holderTypes,_that.payoutSchedules,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc


class _MerchantReferenceDataEntity extends MerchantReferenceDataEntity {
  const _MerchantReferenceDataEntity({required final  List<BusinessTypeOptionEntity> businessTypes, required final  List<ReferenceOptionEntity> industries, required final  List<ReferenceOptionEntity> monthlySalesRanges, required final  List<OwnerRoleOptionEntity> ownerRoles, required final  List<BankOptionEntity> banks, required final  List<AccountHolderTypeOptionEntity> holderTypes, required final  List<ReferenceOptionEntity> payoutSchedules, required this.termsVersion}): _businessTypes = businessTypes,_industries = industries,_monthlySalesRanges = monthlySalesRanges,_ownerRoles = ownerRoles,_banks = banks,_holderTypes = holderTypes,_payoutSchedules = payoutSchedules,super._();
  

 final  List<BusinessTypeOptionEntity> _businessTypes;
@override List<BusinessTypeOptionEntity> get businessTypes {
  if (_businessTypes is EqualUnmodifiableListView) return _businessTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_businessTypes);
}

 final  List<ReferenceOptionEntity> _industries;
@override List<ReferenceOptionEntity> get industries {
  if (_industries is EqualUnmodifiableListView) return _industries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_industries);
}

 final  List<ReferenceOptionEntity> _monthlySalesRanges;
@override List<ReferenceOptionEntity> get monthlySalesRanges {
  if (_monthlySalesRanges is EqualUnmodifiableListView) return _monthlySalesRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlySalesRanges);
}

 final  List<OwnerRoleOptionEntity> _ownerRoles;
@override List<OwnerRoleOptionEntity> get ownerRoles {
  if (_ownerRoles is EqualUnmodifiableListView) return _ownerRoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownerRoles);
}

 final  List<BankOptionEntity> _banks;
@override List<BankOptionEntity> get banks {
  if (_banks is EqualUnmodifiableListView) return _banks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banks);
}

 final  List<AccountHolderTypeOptionEntity> _holderTypes;
@override List<AccountHolderTypeOptionEntity> get holderTypes {
  if (_holderTypes is EqualUnmodifiableListView) return _holderTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_holderTypes);
}

 final  List<ReferenceOptionEntity> _payoutSchedules;
@override List<ReferenceOptionEntity> get payoutSchedules {
  if (_payoutSchedules is EqualUnmodifiableListView) return _payoutSchedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payoutSchedules);
}

@override final  String termsVersion;

/// Create a copy of MerchantReferenceDataEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantReferenceDataEntityCopyWith<_MerchantReferenceDataEntity> get copyWith => __$MerchantReferenceDataEntityCopyWithImpl<_MerchantReferenceDataEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantReferenceDataEntity&&const DeepCollectionEquality().equals(other._businessTypes, _businessTypes)&&const DeepCollectionEquality().equals(other._industries, _industries)&&const DeepCollectionEquality().equals(other._monthlySalesRanges, _monthlySalesRanges)&&const DeepCollectionEquality().equals(other._ownerRoles, _ownerRoles)&&const DeepCollectionEquality().equals(other._banks, _banks)&&const DeepCollectionEquality().equals(other._holderTypes, _holderTypes)&&const DeepCollectionEquality().equals(other._payoutSchedules, _payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_businessTypes),const DeepCollectionEquality().hash(_industries),const DeepCollectionEquality().hash(_monthlySalesRanges),const DeepCollectionEquality().hash(_ownerRoles),const DeepCollectionEquality().hash(_banks),const DeepCollectionEquality().hash(_holderTypes),const DeepCollectionEquality().hash(_payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataEntity(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, holderTypes: $holderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class _$MerchantReferenceDataEntityCopyWith<$Res> implements $MerchantReferenceDataEntityCopyWith<$Res> {
  factory _$MerchantReferenceDataEntityCopyWith(_MerchantReferenceDataEntity value, $Res Function(_MerchantReferenceDataEntity) _then) = __$MerchantReferenceDataEntityCopyWithImpl;
@override @useResult
$Res call({
 List<BusinessTypeOptionEntity> businessTypes, List<ReferenceOptionEntity> industries, List<ReferenceOptionEntity> monthlySalesRanges, List<OwnerRoleOptionEntity> ownerRoles, List<BankOptionEntity> banks, List<AccountHolderTypeOptionEntity> holderTypes, List<ReferenceOptionEntity> payoutSchedules, String termsVersion
});




}
/// @nodoc
class __$MerchantReferenceDataEntityCopyWithImpl<$Res>
    implements _$MerchantReferenceDataEntityCopyWith<$Res> {
  __$MerchantReferenceDataEntityCopyWithImpl(this._self, this._then);

  final _MerchantReferenceDataEntity _self;
  final $Res Function(_MerchantReferenceDataEntity) _then;

/// Create a copy of MerchantReferenceDataEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? holderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_MerchantReferenceDataEntity(
businessTypes: null == businessTypes ? _self._businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<BusinessTypeOptionEntity>,industries: null == industries ? _self._industries : industries // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,monthlySalesRanges: null == monthlySalesRanges ? _self._monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,ownerRoles: null == ownerRoles ? _self._ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<OwnerRoleOptionEntity>,banks: null == banks ? _self._banks : banks // ignore: cast_nullable_to_non_nullable
as List<BankOptionEntity>,holderTypes: null == holderTypes ? _self._holderTypes : holderTypes // ignore: cast_nullable_to_non_nullable
as List<AccountHolderTypeOptionEntity>,payoutSchedules: null == payoutSchedules ? _self._payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<ReferenceOptionEntity>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
