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
mixin _$MerchantReferenceDataModel {

 List<MerchantBusinessTypeOptionModel> get businessTypes; List<MerchantLabeledOptionModel> get industries; List<MerchantLabeledOptionModel> get monthlySalesRanges; List<MerchantOwnerRoleOptionModel> get ownerRoles; List<MerchantBankOptionModel> get banks; List<MerchantAccountHolderTypeOptionModel> get accountHolderTypes; List<MerchantLabeledOptionModel> get payoutSchedules; String get termsVersion;
/// Create a copy of MerchantReferenceDataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantReferenceDataModelCopyWith<MerchantReferenceDataModel> get copyWith => _$MerchantReferenceDataModelCopyWithImpl<MerchantReferenceDataModel>(this as MerchantReferenceDataModel, _$identity);

  /// Serializes this MerchantReferenceDataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantReferenceDataModel&&const DeepCollectionEquality().equals(other.businessTypes, businessTypes)&&const DeepCollectionEquality().equals(other.industries, industries)&&const DeepCollectionEquality().equals(other.monthlySalesRanges, monthlySalesRanges)&&const DeepCollectionEquality().equals(other.ownerRoles, ownerRoles)&&const DeepCollectionEquality().equals(other.banks, banks)&&const DeepCollectionEquality().equals(other.accountHolderTypes, accountHolderTypes)&&const DeepCollectionEquality().equals(other.payoutSchedules, payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(businessTypes),const DeepCollectionEquality().hash(industries),const DeepCollectionEquality().hash(monthlySalesRanges),const DeepCollectionEquality().hash(ownerRoles),const DeepCollectionEquality().hash(banks),const DeepCollectionEquality().hash(accountHolderTypes),const DeepCollectionEquality().hash(payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataModel(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, accountHolderTypes: $accountHolderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $MerchantReferenceDataModelCopyWith<$Res>  {
  factory $MerchantReferenceDataModelCopyWith(MerchantReferenceDataModel value, $Res Function(MerchantReferenceDataModel) _then) = _$MerchantReferenceDataModelCopyWithImpl;
@useResult
$Res call({
 List<MerchantBusinessTypeOptionModel> businessTypes, List<MerchantLabeledOptionModel> industries, List<MerchantLabeledOptionModel> monthlySalesRanges, List<MerchantOwnerRoleOptionModel> ownerRoles, List<MerchantBankOptionModel> banks, List<MerchantAccountHolderTypeOptionModel> accountHolderTypes, List<MerchantLabeledOptionModel> payoutSchedules, String termsVersion
});




}
/// @nodoc
class _$MerchantReferenceDataModelCopyWithImpl<$Res>
    implements $MerchantReferenceDataModelCopyWith<$Res> {
  _$MerchantReferenceDataModelCopyWithImpl(this._self, this._then);

  final MerchantReferenceDataModel _self;
  final $Res Function(MerchantReferenceDataModel) _then;

/// Create a copy of MerchantReferenceDataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? accountHolderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_self.copyWith(
businessTypes: null == businessTypes ? _self.businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantBusinessTypeOptionModel>,industries: null == industries ? _self.industries : industries // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,monthlySalesRanges: null == monthlySalesRanges ? _self.monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,ownerRoles: null == ownerRoles ? _self.ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerRoleOptionModel>,banks: null == banks ? _self.banks : banks // ignore: cast_nullable_to_non_nullable
as List<MerchantBankOptionModel>,accountHolderTypes: null == accountHolderTypes ? _self.accountHolderTypes : accountHolderTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantAccountHolderTypeOptionModel>,payoutSchedules: null == payoutSchedules ? _self.payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantReferenceDataModel].
extension MerchantReferenceDataModelPatterns on MerchantReferenceDataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantReferenceDataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantReferenceDataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantReferenceDataModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantReferenceDataModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantReferenceDataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MerchantBusinessTypeOptionModel> businessTypes,  List<MerchantLabeledOptionModel> industries,  List<MerchantLabeledOptionModel> monthlySalesRanges,  List<MerchantOwnerRoleOptionModel> ownerRoles,  List<MerchantBankOptionModel> banks,  List<MerchantAccountHolderTypeOptionModel> accountHolderTypes,  List<MerchantLabeledOptionModel> payoutSchedules,  String termsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantReferenceDataModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MerchantBusinessTypeOptionModel> businessTypes,  List<MerchantLabeledOptionModel> industries,  List<MerchantLabeledOptionModel> monthlySalesRanges,  List<MerchantOwnerRoleOptionModel> ownerRoles,  List<MerchantBankOptionModel> banks,  List<MerchantAccountHolderTypeOptionModel> accountHolderTypes,  List<MerchantLabeledOptionModel> payoutSchedules,  String termsVersion)  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MerchantBusinessTypeOptionModel> businessTypes,  List<MerchantLabeledOptionModel> industries,  List<MerchantLabeledOptionModel> monthlySalesRanges,  List<MerchantOwnerRoleOptionModel> ownerRoles,  List<MerchantBankOptionModel> banks,  List<MerchantAccountHolderTypeOptionModel> accountHolderTypes,  List<MerchantLabeledOptionModel> payoutSchedules,  String termsVersion)?  $default,) {final _that = this;
switch (_that) {
case _MerchantReferenceDataModel() when $default != null:
return $default(_that.businessTypes,_that.industries,_that.monthlySalesRanges,_that.ownerRoles,_that.banks,_that.accountHolderTypes,_that.payoutSchedules,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantReferenceDataModel extends MerchantReferenceDataModel {
  const _MerchantReferenceDataModel({required final  List<MerchantBusinessTypeOptionModel> businessTypes, required final  List<MerchantLabeledOptionModel> industries, required final  List<MerchantLabeledOptionModel> monthlySalesRanges, required final  List<MerchantOwnerRoleOptionModel> ownerRoles, required final  List<MerchantBankOptionModel> banks, required final  List<MerchantAccountHolderTypeOptionModel> accountHolderTypes, required final  List<MerchantLabeledOptionModel> payoutSchedules, required this.termsVersion}): _businessTypes = businessTypes,_industries = industries,_monthlySalesRanges = monthlySalesRanges,_ownerRoles = ownerRoles,_banks = banks,_accountHolderTypes = accountHolderTypes,_payoutSchedules = payoutSchedules,super._();
  factory _MerchantReferenceDataModel.fromJson(Map<String, dynamic> json) => _$MerchantReferenceDataModelFromJson(json);

 final  List<MerchantBusinessTypeOptionModel> _businessTypes;
@override List<MerchantBusinessTypeOptionModel> get businessTypes {
  if (_businessTypes is EqualUnmodifiableListView) return _businessTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_businessTypes);
}

 final  List<MerchantLabeledOptionModel> _industries;
@override List<MerchantLabeledOptionModel> get industries {
  if (_industries is EqualUnmodifiableListView) return _industries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_industries);
}

 final  List<MerchantLabeledOptionModel> _monthlySalesRanges;
@override List<MerchantLabeledOptionModel> get monthlySalesRanges {
  if (_monthlySalesRanges is EqualUnmodifiableListView) return _monthlySalesRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlySalesRanges);
}

 final  List<MerchantOwnerRoleOptionModel> _ownerRoles;
@override List<MerchantOwnerRoleOptionModel> get ownerRoles {
  if (_ownerRoles is EqualUnmodifiableListView) return _ownerRoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownerRoles);
}

 final  List<MerchantBankOptionModel> _banks;
@override List<MerchantBankOptionModel> get banks {
  if (_banks is EqualUnmodifiableListView) return _banks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banks);
}

 final  List<MerchantAccountHolderTypeOptionModel> _accountHolderTypes;
@override List<MerchantAccountHolderTypeOptionModel> get accountHolderTypes {
  if (_accountHolderTypes is EqualUnmodifiableListView) return _accountHolderTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accountHolderTypes);
}

 final  List<MerchantLabeledOptionModel> _payoutSchedules;
@override List<MerchantLabeledOptionModel> get payoutSchedules {
  if (_payoutSchedules is EqualUnmodifiableListView) return _payoutSchedules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payoutSchedules);
}

@override final  String termsVersion;

/// Create a copy of MerchantReferenceDataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantReferenceDataModelCopyWith<_MerchantReferenceDataModel> get copyWith => __$MerchantReferenceDataModelCopyWithImpl<_MerchantReferenceDataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantReferenceDataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantReferenceDataModel&&const DeepCollectionEquality().equals(other._businessTypes, _businessTypes)&&const DeepCollectionEquality().equals(other._industries, _industries)&&const DeepCollectionEquality().equals(other._monthlySalesRanges, _monthlySalesRanges)&&const DeepCollectionEquality().equals(other._ownerRoles, _ownerRoles)&&const DeepCollectionEquality().equals(other._banks, _banks)&&const DeepCollectionEquality().equals(other._accountHolderTypes, _accountHolderTypes)&&const DeepCollectionEquality().equals(other._payoutSchedules, _payoutSchedules)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_businessTypes),const DeepCollectionEquality().hash(_industries),const DeepCollectionEquality().hash(_monthlySalesRanges),const DeepCollectionEquality().hash(_ownerRoles),const DeepCollectionEquality().hash(_banks),const DeepCollectionEquality().hash(_accountHolderTypes),const DeepCollectionEquality().hash(_payoutSchedules),termsVersion);

@override
String toString() {
  return 'MerchantReferenceDataModel(businessTypes: $businessTypes, industries: $industries, monthlySalesRanges: $monthlySalesRanges, ownerRoles: $ownerRoles, banks: $banks, accountHolderTypes: $accountHolderTypes, payoutSchedules: $payoutSchedules, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class _$MerchantReferenceDataModelCopyWith<$Res> implements $MerchantReferenceDataModelCopyWith<$Res> {
  factory _$MerchantReferenceDataModelCopyWith(_MerchantReferenceDataModel value, $Res Function(_MerchantReferenceDataModel) _then) = __$MerchantReferenceDataModelCopyWithImpl;
@override @useResult
$Res call({
 List<MerchantBusinessTypeOptionModel> businessTypes, List<MerchantLabeledOptionModel> industries, List<MerchantLabeledOptionModel> monthlySalesRanges, List<MerchantOwnerRoleOptionModel> ownerRoles, List<MerchantBankOptionModel> banks, List<MerchantAccountHolderTypeOptionModel> accountHolderTypes, List<MerchantLabeledOptionModel> payoutSchedules, String termsVersion
});




}
/// @nodoc
class __$MerchantReferenceDataModelCopyWithImpl<$Res>
    implements _$MerchantReferenceDataModelCopyWith<$Res> {
  __$MerchantReferenceDataModelCopyWithImpl(this._self, this._then);

  final _MerchantReferenceDataModel _self;
  final $Res Function(_MerchantReferenceDataModel) _then;

/// Create a copy of MerchantReferenceDataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessTypes = null,Object? industries = null,Object? monthlySalesRanges = null,Object? ownerRoles = null,Object? banks = null,Object? accountHolderTypes = null,Object? payoutSchedules = null,Object? termsVersion = null,}) {
  return _then(_MerchantReferenceDataModel(
businessTypes: null == businessTypes ? _self._businessTypes : businessTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantBusinessTypeOptionModel>,industries: null == industries ? _self._industries : industries // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,monthlySalesRanges: null == monthlySalesRanges ? _self._monthlySalesRanges : monthlySalesRanges // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,ownerRoles: null == ownerRoles ? _self._ownerRoles : ownerRoles // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerRoleOptionModel>,banks: null == banks ? _self._banks : banks // ignore: cast_nullable_to_non_nullable
as List<MerchantBankOptionModel>,accountHolderTypes: null == accountHolderTypes ? _self._accountHolderTypes : accountHolderTypes // ignore: cast_nullable_to_non_nullable
as List<MerchantAccountHolderTypeOptionModel>,payoutSchedules: null == payoutSchedules ? _self._payoutSchedules : payoutSchedules // ignore: cast_nullable_to_non_nullable
as List<MerchantLabeledOptionModel>,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantBusinessTypeOptionModel {

 String get id; String get label; bool get requiresRegistrationNumber;
/// Create a copy of MerchantBusinessTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBusinessTypeOptionModelCopyWith<MerchantBusinessTypeOptionModel> get copyWith => _$MerchantBusinessTypeOptionModelCopyWithImpl<MerchantBusinessTypeOptionModel>(this as MerchantBusinessTypeOptionModel, _$identity);

  /// Serializes this MerchantBusinessTypeOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBusinessTypeOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'MerchantBusinessTypeOptionModel(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class $MerchantBusinessTypeOptionModelCopyWith<$Res>  {
  factory $MerchantBusinessTypeOptionModelCopyWith(MerchantBusinessTypeOptionModel value, $Res Function(MerchantBusinessTypeOptionModel) _then) = _$MerchantBusinessTypeOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class _$MerchantBusinessTypeOptionModelCopyWithImpl<$Res>
    implements $MerchantBusinessTypeOptionModelCopyWith<$Res> {
  _$MerchantBusinessTypeOptionModelCopyWithImpl(this._self, this._then);

  final MerchantBusinessTypeOptionModel _self;
  final $Res Function(MerchantBusinessTypeOptionModel) _then;

/// Create a copy of MerchantBusinessTypeOptionModel
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


/// Adds pattern-matching-related methods to [MerchantBusinessTypeOptionModel].
extension MerchantBusinessTypeOptionModelPatterns on MerchantBusinessTypeOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBusinessTypeOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBusinessTypeOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBusinessTypeOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessTypeOptionModel() when $default != null:
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
case _MerchantBusinessTypeOptionModel() when $default != null:
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
case _MerchantBusinessTypeOptionModel():
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
case _MerchantBusinessTypeOptionModel() when $default != null:
return $default(_that.id,_that.label,_that.requiresRegistrationNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBusinessTypeOptionModel implements MerchantBusinessTypeOptionModel {
  const _MerchantBusinessTypeOptionModel({required this.id, required this.label, required this.requiresRegistrationNumber});
  factory _MerchantBusinessTypeOptionModel.fromJson(Map<String, dynamic> json) => _$MerchantBusinessTypeOptionModelFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool requiresRegistrationNumber;

/// Create a copy of MerchantBusinessTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBusinessTypeOptionModelCopyWith<_MerchantBusinessTypeOptionModel> get copyWith => __$MerchantBusinessTypeOptionModelCopyWithImpl<_MerchantBusinessTypeOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBusinessTypeOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBusinessTypeOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresRegistrationNumber, requiresRegistrationNumber) || other.requiresRegistrationNumber == requiresRegistrationNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresRegistrationNumber);

@override
String toString() {
  return 'MerchantBusinessTypeOptionModel(id: $id, label: $label, requiresRegistrationNumber: $requiresRegistrationNumber)';
}


}

/// @nodoc
abstract mixin class _$MerchantBusinessTypeOptionModelCopyWith<$Res> implements $MerchantBusinessTypeOptionModelCopyWith<$Res> {
  factory _$MerchantBusinessTypeOptionModelCopyWith(_MerchantBusinessTypeOptionModel value, $Res Function(_MerchantBusinessTypeOptionModel) _then) = __$MerchantBusinessTypeOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresRegistrationNumber
});




}
/// @nodoc
class __$MerchantBusinessTypeOptionModelCopyWithImpl<$Res>
    implements _$MerchantBusinessTypeOptionModelCopyWith<$Res> {
  __$MerchantBusinessTypeOptionModelCopyWithImpl(this._self, this._then);

  final _MerchantBusinessTypeOptionModel _self;
  final $Res Function(_MerchantBusinessTypeOptionModel) _then;

/// Create a copy of MerchantBusinessTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresRegistrationNumber = null,}) {
  return _then(_MerchantBusinessTypeOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresRegistrationNumber: null == requiresRegistrationNumber ? _self.requiresRegistrationNumber : requiresRegistrationNumber // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MerchantLabeledOptionModel {

 String get id; String get label;
/// Create a copy of MerchantLabeledOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantLabeledOptionModelCopyWith<MerchantLabeledOptionModel> get copyWith => _$MerchantLabeledOptionModelCopyWithImpl<MerchantLabeledOptionModel>(this as MerchantLabeledOptionModel, _$identity);

  /// Serializes this MerchantLabeledOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantLabeledOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'MerchantLabeledOptionModel(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class $MerchantLabeledOptionModelCopyWith<$Res>  {
  factory $MerchantLabeledOptionModelCopyWith(MerchantLabeledOptionModel value, $Res Function(MerchantLabeledOptionModel) _then) = _$MerchantLabeledOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class _$MerchantLabeledOptionModelCopyWithImpl<$Res>
    implements $MerchantLabeledOptionModelCopyWith<$Res> {
  _$MerchantLabeledOptionModelCopyWithImpl(this._self, this._then);

  final MerchantLabeledOptionModel _self;
  final $Res Function(MerchantLabeledOptionModel) _then;

/// Create a copy of MerchantLabeledOptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantLabeledOptionModel].
extension MerchantLabeledOptionModelPatterns on MerchantLabeledOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantLabeledOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantLabeledOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantLabeledOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantLabeledOptionModel() when $default != null:
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
case _MerchantLabeledOptionModel() when $default != null:
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
case _MerchantLabeledOptionModel():
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
case _MerchantLabeledOptionModel() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantLabeledOptionModel implements MerchantLabeledOptionModel {
  const _MerchantLabeledOptionModel({required this.id, required this.label});
  factory _MerchantLabeledOptionModel.fromJson(Map<String, dynamic> json) => _$MerchantLabeledOptionModelFromJson(json);

@override final  String id;
@override final  String label;

/// Create a copy of MerchantLabeledOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantLabeledOptionModelCopyWith<_MerchantLabeledOptionModel> get copyWith => __$MerchantLabeledOptionModelCopyWithImpl<_MerchantLabeledOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantLabeledOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantLabeledOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label);

@override
String toString() {
  return 'MerchantLabeledOptionModel(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$MerchantLabeledOptionModelCopyWith<$Res> implements $MerchantLabeledOptionModelCopyWith<$Res> {
  factory _$MerchantLabeledOptionModelCopyWith(_MerchantLabeledOptionModel value, $Res Function(_MerchantLabeledOptionModel) _then) = __$MerchantLabeledOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label
});




}
/// @nodoc
class __$MerchantLabeledOptionModelCopyWithImpl<$Res>
    implements _$MerchantLabeledOptionModelCopyWith<$Res> {
  __$MerchantLabeledOptionModelCopyWithImpl(this._self, this._then);

  final _MerchantLabeledOptionModel _self;
  final $Res Function(_MerchantLabeledOptionModel) _then;

/// Create a copy of MerchantLabeledOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_MerchantLabeledOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantOwnerRoleOptionModel {

 String get id; String get label; bool get contributesOwnership;
/// Create a copy of MerchantOwnerRoleOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOwnerRoleOptionModelCopyWith<MerchantOwnerRoleOptionModel> get copyWith => _$MerchantOwnerRoleOptionModelCopyWithImpl<MerchantOwnerRoleOptionModel>(this as MerchantOwnerRoleOptionModel, _$identity);

  /// Serializes this MerchantOwnerRoleOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOwnerRoleOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'MerchantOwnerRoleOptionModel(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class $MerchantOwnerRoleOptionModelCopyWith<$Res>  {
  factory $MerchantOwnerRoleOptionModelCopyWith(MerchantOwnerRoleOptionModel value, $Res Function(MerchantOwnerRoleOptionModel) _then) = _$MerchantOwnerRoleOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class _$MerchantOwnerRoleOptionModelCopyWithImpl<$Res>
    implements $MerchantOwnerRoleOptionModelCopyWith<$Res> {
  _$MerchantOwnerRoleOptionModelCopyWithImpl(this._self, this._then);

  final MerchantOwnerRoleOptionModel _self;
  final $Res Function(MerchantOwnerRoleOptionModel) _then;

/// Create a copy of MerchantOwnerRoleOptionModel
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


/// Adds pattern-matching-related methods to [MerchantOwnerRoleOptionModel].
extension MerchantOwnerRoleOptionModelPatterns on MerchantOwnerRoleOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOwnerRoleOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOwnerRoleOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOwnerRoleOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerRoleOptionModel() when $default != null:
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
case _MerchantOwnerRoleOptionModel() when $default != null:
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
case _MerchantOwnerRoleOptionModel():
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
case _MerchantOwnerRoleOptionModel() when $default != null:
return $default(_that.id,_that.label,_that.contributesOwnership);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOwnerRoleOptionModel implements MerchantOwnerRoleOptionModel {
  const _MerchantOwnerRoleOptionModel({required this.id, required this.label, required this.contributesOwnership});
  factory _MerchantOwnerRoleOptionModel.fromJson(Map<String, dynamic> json) => _$MerchantOwnerRoleOptionModelFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool contributesOwnership;

/// Create a copy of MerchantOwnerRoleOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOwnerRoleOptionModelCopyWith<_MerchantOwnerRoleOptionModel> get copyWith => __$MerchantOwnerRoleOptionModelCopyWithImpl<_MerchantOwnerRoleOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOwnerRoleOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOwnerRoleOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.contributesOwnership, contributesOwnership) || other.contributesOwnership == contributesOwnership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,contributesOwnership);

@override
String toString() {
  return 'MerchantOwnerRoleOptionModel(id: $id, label: $label, contributesOwnership: $contributesOwnership)';
}


}

/// @nodoc
abstract mixin class _$MerchantOwnerRoleOptionModelCopyWith<$Res> implements $MerchantOwnerRoleOptionModelCopyWith<$Res> {
  factory _$MerchantOwnerRoleOptionModelCopyWith(_MerchantOwnerRoleOptionModel value, $Res Function(_MerchantOwnerRoleOptionModel) _then) = __$MerchantOwnerRoleOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool contributesOwnership
});




}
/// @nodoc
class __$MerchantOwnerRoleOptionModelCopyWithImpl<$Res>
    implements _$MerchantOwnerRoleOptionModelCopyWith<$Res> {
  __$MerchantOwnerRoleOptionModelCopyWithImpl(this._self, this._then);

  final _MerchantOwnerRoleOptionModel _self;
  final $Res Function(_MerchantOwnerRoleOptionModel) _then;

/// Create a copy of MerchantOwnerRoleOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? contributesOwnership = null,}) {
  return _then(_MerchantOwnerRoleOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,contributesOwnership: null == contributesOwnership ? _self.contributesOwnership : contributesOwnership // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MerchantBankOptionModel {

 String get id; String get label; List<String> get supportedPayoutScheduleIds;
/// Create a copy of MerchantBankOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBankOptionModelCopyWith<MerchantBankOptionModel> get copyWith => _$MerchantBankOptionModelCopyWithImpl<MerchantBankOptionModel>(this as MerchantBankOptionModel, _$identity);

  /// Serializes this MerchantBankOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBankOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.supportedPayoutScheduleIds, supportedPayoutScheduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(supportedPayoutScheduleIds));

@override
String toString() {
  return 'MerchantBankOptionModel(id: $id, label: $label, supportedPayoutScheduleIds: $supportedPayoutScheduleIds)';
}


}

/// @nodoc
abstract mixin class $MerchantBankOptionModelCopyWith<$Res>  {
  factory $MerchantBankOptionModelCopyWith(MerchantBankOptionModel value, $Res Function(MerchantBankOptionModel) _then) = _$MerchantBankOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String label, List<String> supportedPayoutScheduleIds
});




}
/// @nodoc
class _$MerchantBankOptionModelCopyWithImpl<$Res>
    implements $MerchantBankOptionModelCopyWith<$Res> {
  _$MerchantBankOptionModelCopyWithImpl(this._self, this._then);

  final MerchantBankOptionModel _self;
  final $Res Function(MerchantBankOptionModel) _then;

/// Create a copy of MerchantBankOptionModel
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


/// Adds pattern-matching-related methods to [MerchantBankOptionModel].
extension MerchantBankOptionModelPatterns on MerchantBankOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBankOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBankOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBankOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBankOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBankOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBankOptionModel() when $default != null:
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
case _MerchantBankOptionModel() when $default != null:
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
case _MerchantBankOptionModel():
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
case _MerchantBankOptionModel() when $default != null:
return $default(_that.id,_that.label,_that.supportedPayoutScheduleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBankOptionModel implements MerchantBankOptionModel {
  const _MerchantBankOptionModel({required this.id, required this.label, required final  List<String> supportedPayoutScheduleIds}): _supportedPayoutScheduleIds = supportedPayoutScheduleIds;
  factory _MerchantBankOptionModel.fromJson(Map<String, dynamic> json) => _$MerchantBankOptionModelFromJson(json);

@override final  String id;
@override final  String label;
 final  List<String> _supportedPayoutScheduleIds;
@override List<String> get supportedPayoutScheduleIds {
  if (_supportedPayoutScheduleIds is EqualUnmodifiableListView) return _supportedPayoutScheduleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supportedPayoutScheduleIds);
}


/// Create a copy of MerchantBankOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBankOptionModelCopyWith<_MerchantBankOptionModel> get copyWith => __$MerchantBankOptionModelCopyWithImpl<_MerchantBankOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBankOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBankOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._supportedPayoutScheduleIds, _supportedPayoutScheduleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,const DeepCollectionEquality().hash(_supportedPayoutScheduleIds));

@override
String toString() {
  return 'MerchantBankOptionModel(id: $id, label: $label, supportedPayoutScheduleIds: $supportedPayoutScheduleIds)';
}


}

/// @nodoc
abstract mixin class _$MerchantBankOptionModelCopyWith<$Res> implements $MerchantBankOptionModelCopyWith<$Res> {
  factory _$MerchantBankOptionModelCopyWith(_MerchantBankOptionModel value, $Res Function(_MerchantBankOptionModel) _then) = __$MerchantBankOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, List<String> supportedPayoutScheduleIds
});




}
/// @nodoc
class __$MerchantBankOptionModelCopyWithImpl<$Res>
    implements _$MerchantBankOptionModelCopyWith<$Res> {
  __$MerchantBankOptionModelCopyWithImpl(this._self, this._then);

  final _MerchantBankOptionModel _self;
  final $Res Function(_MerchantBankOptionModel) _then;

/// Create a copy of MerchantBankOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? supportedPayoutScheduleIds = null,}) {
  return _then(_MerchantBankOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,supportedPayoutScheduleIds: null == supportedPayoutScheduleIds ? _self._supportedPayoutScheduleIds : supportedPayoutScheduleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MerchantAccountHolderTypeOptionModel {

 String get id; String get label; bool get requiresOwnerReference;
/// Create a copy of MerchantAccountHolderTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantAccountHolderTypeOptionModelCopyWith<MerchantAccountHolderTypeOptionModel> get copyWith => _$MerchantAccountHolderTypeOptionModelCopyWithImpl<MerchantAccountHolderTypeOptionModel>(this as MerchantAccountHolderTypeOptionModel, _$identity);

  /// Serializes this MerchantAccountHolderTypeOptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantAccountHolderTypeOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'MerchantAccountHolderTypeOptionModel(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class $MerchantAccountHolderTypeOptionModelCopyWith<$Res>  {
  factory $MerchantAccountHolderTypeOptionModelCopyWith(MerchantAccountHolderTypeOptionModel value, $Res Function(MerchantAccountHolderTypeOptionModel) _then) = _$MerchantAccountHolderTypeOptionModelCopyWithImpl;
@useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class _$MerchantAccountHolderTypeOptionModelCopyWithImpl<$Res>
    implements $MerchantAccountHolderTypeOptionModelCopyWith<$Res> {
  _$MerchantAccountHolderTypeOptionModelCopyWithImpl(this._self, this._then);

  final MerchantAccountHolderTypeOptionModel _self;
  final $Res Function(MerchantAccountHolderTypeOptionModel) _then;

/// Create a copy of MerchantAccountHolderTypeOptionModel
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


/// Adds pattern-matching-related methods to [MerchantAccountHolderTypeOptionModel].
extension MerchantAccountHolderTypeOptionModelPatterns on MerchantAccountHolderTypeOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantAccountHolderTypeOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantAccountHolderTypeOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantAccountHolderTypeOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantAccountHolderTypeOptionModel() when $default != null:
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
case _MerchantAccountHolderTypeOptionModel() when $default != null:
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
case _MerchantAccountHolderTypeOptionModel():
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
case _MerchantAccountHolderTypeOptionModel() when $default != null:
return $default(_that.id,_that.label,_that.requiresOwnerReference);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantAccountHolderTypeOptionModel implements MerchantAccountHolderTypeOptionModel {
  const _MerchantAccountHolderTypeOptionModel({required this.id, required this.label, required this.requiresOwnerReference});
  factory _MerchantAccountHolderTypeOptionModel.fromJson(Map<String, dynamic> json) => _$MerchantAccountHolderTypeOptionModelFromJson(json);

@override final  String id;
@override final  String label;
@override final  bool requiresOwnerReference;

/// Create a copy of MerchantAccountHolderTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantAccountHolderTypeOptionModelCopyWith<_MerchantAccountHolderTypeOptionModel> get copyWith => __$MerchantAccountHolderTypeOptionModelCopyWithImpl<_MerchantAccountHolderTypeOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantAccountHolderTypeOptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantAccountHolderTypeOptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.requiresOwnerReference, requiresOwnerReference) || other.requiresOwnerReference == requiresOwnerReference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,requiresOwnerReference);

@override
String toString() {
  return 'MerchantAccountHolderTypeOptionModel(id: $id, label: $label, requiresOwnerReference: $requiresOwnerReference)';
}


}

/// @nodoc
abstract mixin class _$MerchantAccountHolderTypeOptionModelCopyWith<$Res> implements $MerchantAccountHolderTypeOptionModelCopyWith<$Res> {
  factory _$MerchantAccountHolderTypeOptionModelCopyWith(_MerchantAccountHolderTypeOptionModel value, $Res Function(_MerchantAccountHolderTypeOptionModel) _then) = __$MerchantAccountHolderTypeOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, bool requiresOwnerReference
});




}
/// @nodoc
class __$MerchantAccountHolderTypeOptionModelCopyWithImpl<$Res>
    implements _$MerchantAccountHolderTypeOptionModelCopyWith<$Res> {
  __$MerchantAccountHolderTypeOptionModelCopyWithImpl(this._self, this._then);

  final _MerchantAccountHolderTypeOptionModel _self;
  final $Res Function(_MerchantAccountHolderTypeOptionModel) _then;

/// Create a copy of MerchantAccountHolderTypeOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? requiresOwnerReference = null,}) {
  return _then(_MerchantAccountHolderTypeOptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,requiresOwnerReference: null == requiresOwnerReference ? _self.requiresOwnerReference : requiresOwnerReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
