// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merchant_onboarding_submit_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MerchantOnboardingSubmitRequestModel {

 MerchantBusinessInputModel get business; List<MerchantOwnerInputModel> get owners; MerchantSettlementInputModel get settlement; MerchantDeclarationsInputModel get declarations;
/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOnboardingSubmitRequestModelCopyWith<MerchantOnboardingSubmitRequestModel> get copyWith => _$MerchantOnboardingSubmitRequestModelCopyWithImpl<MerchantOnboardingSubmitRequestModel>(this as MerchantOnboardingSubmitRequestModel, _$identity);

  /// Serializes this MerchantOnboardingSubmitRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOnboardingSubmitRequestModel&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other.owners, owners)&&(identical(other.settlement, settlement) || other.settlement == settlement)&&(identical(other.declarations, declarations) || other.declarations == declarations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,business,const DeepCollectionEquality().hash(owners),settlement,declarations);

@override
String toString() {
  return 'MerchantOnboardingSubmitRequestModel(business: $business, owners: $owners, settlement: $settlement, declarations: $declarations)';
}


}

/// @nodoc
abstract mixin class $MerchantOnboardingSubmitRequestModelCopyWith<$Res>  {
  factory $MerchantOnboardingSubmitRequestModelCopyWith(MerchantOnboardingSubmitRequestModel value, $Res Function(MerchantOnboardingSubmitRequestModel) _then) = _$MerchantOnboardingSubmitRequestModelCopyWithImpl;
@useResult
$Res call({
 MerchantBusinessInputModel business, List<MerchantOwnerInputModel> owners, MerchantSettlementInputModel settlement, MerchantDeclarationsInputModel declarations
});


$MerchantBusinessInputModelCopyWith<$Res> get business;$MerchantSettlementInputModelCopyWith<$Res> get settlement;$MerchantDeclarationsInputModelCopyWith<$Res> get declarations;

}
/// @nodoc
class _$MerchantOnboardingSubmitRequestModelCopyWithImpl<$Res>
    implements $MerchantOnboardingSubmitRequestModelCopyWith<$Res> {
  _$MerchantOnboardingSubmitRequestModelCopyWithImpl(this._self, this._then);

  final MerchantOnboardingSubmitRequestModel _self;
  final $Res Function(MerchantOnboardingSubmitRequestModel) _then;

/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? business = null,Object? owners = null,Object? settlement = null,Object? declarations = null,}) {
  return _then(_self.copyWith(
business: null == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as MerchantBusinessInputModel,owners: null == owners ? _self.owners : owners // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerInputModel>,settlement: null == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSettlementInputModel,declarations: null == declarations ? _self.declarations : declarations // ignore: cast_nullable_to_non_nullable
as MerchantDeclarationsInputModel,
  ));
}
/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantBusinessInputModelCopyWith<$Res> get business {
  
  return $MerchantBusinessInputModelCopyWith<$Res>(_self.business, (value) {
    return _then(_self.copyWith(business: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSettlementInputModelCopyWith<$Res> get settlement {
  
  return $MerchantSettlementInputModelCopyWith<$Res>(_self.settlement, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputModelCopyWith<$Res> get declarations {
  
  return $MerchantDeclarationsInputModelCopyWith<$Res>(_self.declarations, (value) {
    return _then(_self.copyWith(declarations: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantOnboardingSubmitRequestModel].
extension MerchantOnboardingSubmitRequestModelPatterns on MerchantOnboardingSubmitRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOnboardingSubmitRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOnboardingSubmitRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOnboardingSubmitRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MerchantBusinessInputModel business,  List<MerchantOwnerInputModel> owners,  MerchantSettlementInputModel settlement,  MerchantDeclarationsInputModel declarations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel() when $default != null:
return $default(_that.business,_that.owners,_that.settlement,_that.declarations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MerchantBusinessInputModel business,  List<MerchantOwnerInputModel> owners,  MerchantSettlementInputModel settlement,  MerchantDeclarationsInputModel declarations)  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel():
return $default(_that.business,_that.owners,_that.settlement,_that.declarations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MerchantBusinessInputModel business,  List<MerchantOwnerInputModel> owners,  MerchantSettlementInputModel settlement,  MerchantDeclarationsInputModel declarations)?  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestModel() when $default != null:
return $default(_that.business,_that.owners,_that.settlement,_that.declarations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOnboardingSubmitRequestModel extends MerchantOnboardingSubmitRequestModel {
  const _MerchantOnboardingSubmitRequestModel({required this.business, required final  List<MerchantOwnerInputModel> owners, required this.settlement, required this.declarations}): _owners = owners,super._();
  factory _MerchantOnboardingSubmitRequestModel.fromJson(Map<String, dynamic> json) => _$MerchantOnboardingSubmitRequestModelFromJson(json);

@override final  MerchantBusinessInputModel business;
 final  List<MerchantOwnerInputModel> _owners;
@override List<MerchantOwnerInputModel> get owners {
  if (_owners is EqualUnmodifiableListView) return _owners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_owners);
}

@override final  MerchantSettlementInputModel settlement;
@override final  MerchantDeclarationsInputModel declarations;

/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOnboardingSubmitRequestModelCopyWith<_MerchantOnboardingSubmitRequestModel> get copyWith => __$MerchantOnboardingSubmitRequestModelCopyWithImpl<_MerchantOnboardingSubmitRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOnboardingSubmitRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOnboardingSubmitRequestModel&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other._owners, _owners)&&(identical(other.settlement, settlement) || other.settlement == settlement)&&(identical(other.declarations, declarations) || other.declarations == declarations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,business,const DeepCollectionEquality().hash(_owners),settlement,declarations);

@override
String toString() {
  return 'MerchantOnboardingSubmitRequestModel(business: $business, owners: $owners, settlement: $settlement, declarations: $declarations)';
}


}

/// @nodoc
abstract mixin class _$MerchantOnboardingSubmitRequestModelCopyWith<$Res> implements $MerchantOnboardingSubmitRequestModelCopyWith<$Res> {
  factory _$MerchantOnboardingSubmitRequestModelCopyWith(_MerchantOnboardingSubmitRequestModel value, $Res Function(_MerchantOnboardingSubmitRequestModel) _then) = __$MerchantOnboardingSubmitRequestModelCopyWithImpl;
@override @useResult
$Res call({
 MerchantBusinessInputModel business, List<MerchantOwnerInputModel> owners, MerchantSettlementInputModel settlement, MerchantDeclarationsInputModel declarations
});


@override $MerchantBusinessInputModelCopyWith<$Res> get business;@override $MerchantSettlementInputModelCopyWith<$Res> get settlement;@override $MerchantDeclarationsInputModelCopyWith<$Res> get declarations;

}
/// @nodoc
class __$MerchantOnboardingSubmitRequestModelCopyWithImpl<$Res>
    implements _$MerchantOnboardingSubmitRequestModelCopyWith<$Res> {
  __$MerchantOnboardingSubmitRequestModelCopyWithImpl(this._self, this._then);

  final _MerchantOnboardingSubmitRequestModel _self;
  final $Res Function(_MerchantOnboardingSubmitRequestModel) _then;

/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? business = null,Object? owners = null,Object? settlement = null,Object? declarations = null,}) {
  return _then(_MerchantOnboardingSubmitRequestModel(
business: null == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as MerchantBusinessInputModel,owners: null == owners ? _self._owners : owners // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerInputModel>,settlement: null == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSettlementInputModel,declarations: null == declarations ? _self.declarations : declarations // ignore: cast_nullable_to_non_nullable
as MerchantDeclarationsInputModel,
  ));
}

/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantBusinessInputModelCopyWith<$Res> get business {
  
  return $MerchantBusinessInputModelCopyWith<$Res>(_self.business, (value) {
    return _then(_self.copyWith(business: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSettlementInputModelCopyWith<$Res> get settlement {
  
  return $MerchantSettlementInputModelCopyWith<$Res>(_self.settlement, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputModelCopyWith<$Res> get declarations {
  
  return $MerchantDeclarationsInputModelCopyWith<$Res>(_self.declarations, (value) {
    return _then(_self.copyWith(declarations: value));
  });
}
}


/// @nodoc
mixin _$MerchantBusinessInputModel {

 String get legalName; String get businessTypeId; String? get registrationNumber; String get industryId; String get monthlySalesRangeId; String get contactEmail; String get contactPhone;
/// Create a copy of MerchantBusinessInputModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBusinessInputModelCopyWith<MerchantBusinessInputModel> get copyWith => _$MerchantBusinessInputModelCopyWithImpl<MerchantBusinessInputModel>(this as MerchantBusinessInputModel, _$identity);

  /// Serializes this MerchantBusinessInputModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBusinessInputModel&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessTypeId, businessTypeId) || other.businessTypeId == businessTypeId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.industryId, industryId) || other.industryId == industryId)&&(identical(other.monthlySalesRangeId, monthlySalesRangeId) || other.monthlySalesRangeId == monthlySalesRangeId)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,legalName,businessTypeId,registrationNumber,industryId,monthlySalesRangeId,contactEmail,contactPhone);

@override
String toString() {
  return 'MerchantBusinessInputModel(legalName: $legalName, businessTypeId: $businessTypeId, registrationNumber: $registrationNumber, industryId: $industryId, monthlySalesRangeId: $monthlySalesRangeId, contactEmail: $contactEmail, contactPhone: $contactPhone)';
}


}

/// @nodoc
abstract mixin class $MerchantBusinessInputModelCopyWith<$Res>  {
  factory $MerchantBusinessInputModelCopyWith(MerchantBusinessInputModel value, $Res Function(MerchantBusinessInputModel) _then) = _$MerchantBusinessInputModelCopyWithImpl;
@useResult
$Res call({
 String legalName, String businessTypeId, String? registrationNumber, String industryId, String monthlySalesRangeId, String contactEmail, String contactPhone
});




}
/// @nodoc
class _$MerchantBusinessInputModelCopyWithImpl<$Res>
    implements $MerchantBusinessInputModelCopyWith<$Res> {
  _$MerchantBusinessInputModelCopyWithImpl(this._self, this._then);

  final MerchantBusinessInputModel _self;
  final $Res Function(MerchantBusinessInputModel) _then;

/// Create a copy of MerchantBusinessInputModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? legalName = null,Object? businessTypeId = null,Object? registrationNumber = freezed,Object? industryId = null,Object? monthlySalesRangeId = null,Object? contactEmail = null,Object? contactPhone = null,}) {
  return _then(_self.copyWith(
legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,businessTypeId: null == businessTypeId ? _self.businessTypeId : businessTypeId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,industryId: null == industryId ? _self.industryId : industryId // ignore: cast_nullable_to_non_nullable
as String,monthlySalesRangeId: null == monthlySalesRangeId ? _self.monthlySalesRangeId : monthlySalesRangeId // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantBusinessInputModel].
extension MerchantBusinessInputModelPatterns on MerchantBusinessInputModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBusinessInputModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBusinessInputModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBusinessInputModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessInputModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBusinessInputModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessInputModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String legalName,  String businessTypeId,  String? registrationNumber,  String industryId,  String monthlySalesRangeId,  String contactEmail,  String contactPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantBusinessInputModel() when $default != null:
return $default(_that.legalName,_that.businessTypeId,_that.registrationNumber,_that.industryId,_that.monthlySalesRangeId,_that.contactEmail,_that.contactPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String legalName,  String businessTypeId,  String? registrationNumber,  String industryId,  String monthlySalesRangeId,  String contactEmail,  String contactPhone)  $default,) {final _that = this;
switch (_that) {
case _MerchantBusinessInputModel():
return $default(_that.legalName,_that.businessTypeId,_that.registrationNumber,_that.industryId,_that.monthlySalesRangeId,_that.contactEmail,_that.contactPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String legalName,  String businessTypeId,  String? registrationNumber,  String industryId,  String monthlySalesRangeId,  String contactEmail,  String contactPhone)?  $default,) {final _that = this;
switch (_that) {
case _MerchantBusinessInputModel() when $default != null:
return $default(_that.legalName,_that.businessTypeId,_that.registrationNumber,_that.industryId,_that.monthlySalesRangeId,_that.contactEmail,_that.contactPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBusinessInputModel implements MerchantBusinessInputModel {
  const _MerchantBusinessInputModel({required this.legalName, required this.businessTypeId, this.registrationNumber, required this.industryId, required this.monthlySalesRangeId, required this.contactEmail, required this.contactPhone});
  factory _MerchantBusinessInputModel.fromJson(Map<String, dynamic> json) => _$MerchantBusinessInputModelFromJson(json);

@override final  String legalName;
@override final  String businessTypeId;
@override final  String? registrationNumber;
@override final  String industryId;
@override final  String monthlySalesRangeId;
@override final  String contactEmail;
@override final  String contactPhone;

/// Create a copy of MerchantBusinessInputModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBusinessInputModelCopyWith<_MerchantBusinessInputModel> get copyWith => __$MerchantBusinessInputModelCopyWithImpl<_MerchantBusinessInputModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBusinessInputModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBusinessInputModel&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessTypeId, businessTypeId) || other.businessTypeId == businessTypeId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.industryId, industryId) || other.industryId == industryId)&&(identical(other.monthlySalesRangeId, monthlySalesRangeId) || other.monthlySalesRangeId == monthlySalesRangeId)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,legalName,businessTypeId,registrationNumber,industryId,monthlySalesRangeId,contactEmail,contactPhone);

@override
String toString() {
  return 'MerchantBusinessInputModel(legalName: $legalName, businessTypeId: $businessTypeId, registrationNumber: $registrationNumber, industryId: $industryId, monthlySalesRangeId: $monthlySalesRangeId, contactEmail: $contactEmail, contactPhone: $contactPhone)';
}


}

/// @nodoc
abstract mixin class _$MerchantBusinessInputModelCopyWith<$Res> implements $MerchantBusinessInputModelCopyWith<$Res> {
  factory _$MerchantBusinessInputModelCopyWith(_MerchantBusinessInputModel value, $Res Function(_MerchantBusinessInputModel) _then) = __$MerchantBusinessInputModelCopyWithImpl;
@override @useResult
$Res call({
 String legalName, String businessTypeId, String? registrationNumber, String industryId, String monthlySalesRangeId, String contactEmail, String contactPhone
});




}
/// @nodoc
class __$MerchantBusinessInputModelCopyWithImpl<$Res>
    implements _$MerchantBusinessInputModelCopyWith<$Res> {
  __$MerchantBusinessInputModelCopyWithImpl(this._self, this._then);

  final _MerchantBusinessInputModel _self;
  final $Res Function(_MerchantBusinessInputModel) _then;

/// Create a copy of MerchantBusinessInputModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legalName = null,Object? businessTypeId = null,Object? registrationNumber = freezed,Object? industryId = null,Object? monthlySalesRangeId = null,Object? contactEmail = null,Object? contactPhone = null,}) {
  return _then(_MerchantBusinessInputModel(
legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,businessTypeId: null == businessTypeId ? _self.businessTypeId : businessTypeId // ignore: cast_nullable_to_non_nullable
as String,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,industryId: null == industryId ? _self.industryId : industryId // ignore: cast_nullable_to_non_nullable
as String,monthlySalesRangeId: null == monthlySalesRangeId ? _self.monthlySalesRangeId : monthlySalesRangeId // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantOwnerInputModel {

 String get ownerRowId; String get fullName; String get roleId; int? get ownershipBasisPoints; String get email; bool get isPrimaryContact;
/// Create a copy of MerchantOwnerInputModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOwnerInputModelCopyWith<MerchantOwnerInputModel> get copyWith => _$MerchantOwnerInputModelCopyWithImpl<MerchantOwnerInputModel>(this as MerchantOwnerInputModel, _$identity);

  /// Serializes this MerchantOwnerInputModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOwnerInputModel&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.ownershipBasisPoints, ownershipBasisPoints) || other.ownershipBasisPoints == ownershipBasisPoints)&&(identical(other.email, email) || other.email == email)&&(identical(other.isPrimaryContact, isPrimaryContact) || other.isPrimaryContact == isPrimaryContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerRowId,fullName,roleId,ownershipBasisPoints,email,isPrimaryContact);

@override
String toString() {
  return 'MerchantOwnerInputModel(ownerRowId: $ownerRowId, fullName: $fullName, roleId: $roleId, ownershipBasisPoints: $ownershipBasisPoints, email: $email, isPrimaryContact: $isPrimaryContact)';
}


}

/// @nodoc
abstract mixin class $MerchantOwnerInputModelCopyWith<$Res>  {
  factory $MerchantOwnerInputModelCopyWith(MerchantOwnerInputModel value, $Res Function(MerchantOwnerInputModel) _then) = _$MerchantOwnerInputModelCopyWithImpl;
@useResult
$Res call({
 String ownerRowId, String fullName, String roleId, int? ownershipBasisPoints, String email, bool isPrimaryContact
});




}
/// @nodoc
class _$MerchantOwnerInputModelCopyWithImpl<$Res>
    implements $MerchantOwnerInputModelCopyWith<$Res> {
  _$MerchantOwnerInputModelCopyWithImpl(this._self, this._then);

  final MerchantOwnerInputModel _self;
  final $Res Function(MerchantOwnerInputModel) _then;

/// Create a copy of MerchantOwnerInputModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerRowId = null,Object? fullName = null,Object? roleId = null,Object? ownershipBasisPoints = freezed,Object? email = null,Object? isPrimaryContact = null,}) {
  return _then(_self.copyWith(
ownerRowId: null == ownerRowId ? _self.ownerRowId : ownerRowId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,ownershipBasisPoints: freezed == ownershipBasisPoints ? _self.ownershipBasisPoints : ownershipBasisPoints // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,isPrimaryContact: null == isPrimaryContact ? _self.isPrimaryContact : isPrimaryContact // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantOwnerInputModel].
extension MerchantOwnerInputModelPatterns on MerchantOwnerInputModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOwnerInputModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOwnerInputModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOwnerInputModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerInputModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOwnerInputModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerInputModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ownerRowId,  String fullName,  String roleId,  int? ownershipBasisPoints,  String email,  bool isPrimaryContact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantOwnerInputModel() when $default != null:
return $default(_that.ownerRowId,_that.fullName,_that.roleId,_that.ownershipBasisPoints,_that.email,_that.isPrimaryContact);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ownerRowId,  String fullName,  String roleId,  int? ownershipBasisPoints,  String email,  bool isPrimaryContact)  $default,) {final _that = this;
switch (_that) {
case _MerchantOwnerInputModel():
return $default(_that.ownerRowId,_that.fullName,_that.roleId,_that.ownershipBasisPoints,_that.email,_that.isPrimaryContact);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ownerRowId,  String fullName,  String roleId,  int? ownershipBasisPoints,  String email,  bool isPrimaryContact)?  $default,) {final _that = this;
switch (_that) {
case _MerchantOwnerInputModel() when $default != null:
return $default(_that.ownerRowId,_that.fullName,_that.roleId,_that.ownershipBasisPoints,_that.email,_that.isPrimaryContact);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOwnerInputModel implements MerchantOwnerInputModel {
  const _MerchantOwnerInputModel({required this.ownerRowId, required this.fullName, required this.roleId, this.ownershipBasisPoints, required this.email, required this.isPrimaryContact});
  factory _MerchantOwnerInputModel.fromJson(Map<String, dynamic> json) => _$MerchantOwnerInputModelFromJson(json);

@override final  String ownerRowId;
@override final  String fullName;
@override final  String roleId;
@override final  int? ownershipBasisPoints;
@override final  String email;
@override final  bool isPrimaryContact;

/// Create a copy of MerchantOwnerInputModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOwnerInputModelCopyWith<_MerchantOwnerInputModel> get copyWith => __$MerchantOwnerInputModelCopyWithImpl<_MerchantOwnerInputModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOwnerInputModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOwnerInputModel&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.ownershipBasisPoints, ownershipBasisPoints) || other.ownershipBasisPoints == ownershipBasisPoints)&&(identical(other.email, email) || other.email == email)&&(identical(other.isPrimaryContact, isPrimaryContact) || other.isPrimaryContact == isPrimaryContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerRowId,fullName,roleId,ownershipBasisPoints,email,isPrimaryContact);

@override
String toString() {
  return 'MerchantOwnerInputModel(ownerRowId: $ownerRowId, fullName: $fullName, roleId: $roleId, ownershipBasisPoints: $ownershipBasisPoints, email: $email, isPrimaryContact: $isPrimaryContact)';
}


}

/// @nodoc
abstract mixin class _$MerchantOwnerInputModelCopyWith<$Res> implements $MerchantOwnerInputModelCopyWith<$Res> {
  factory _$MerchantOwnerInputModelCopyWith(_MerchantOwnerInputModel value, $Res Function(_MerchantOwnerInputModel) _then) = __$MerchantOwnerInputModelCopyWithImpl;
@override @useResult
$Res call({
 String ownerRowId, String fullName, String roleId, int? ownershipBasisPoints, String email, bool isPrimaryContact
});




}
/// @nodoc
class __$MerchantOwnerInputModelCopyWithImpl<$Res>
    implements _$MerchantOwnerInputModelCopyWith<$Res> {
  __$MerchantOwnerInputModelCopyWithImpl(this._self, this._then);

  final _MerchantOwnerInputModel _self;
  final $Res Function(_MerchantOwnerInputModel) _then;

/// Create a copy of MerchantOwnerInputModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerRowId = null,Object? fullName = null,Object? roleId = null,Object? ownershipBasisPoints = freezed,Object? email = null,Object? isPrimaryContact = null,}) {
  return _then(_MerchantOwnerInputModel(
ownerRowId: null == ownerRowId ? _self.ownerRowId : ownerRowId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,ownershipBasisPoints: freezed == ownershipBasisPoints ? _self.ownershipBasisPoints : ownershipBasisPoints // ignore: cast_nullable_to_non_nullable
as int?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,isPrimaryContact: null == isPrimaryContact ? _self.isPrimaryContact : isPrimaryContact // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MerchantSettlementInputModel {

 String get bankId; String get accountHolderName; String get accountNumber; String get holderTypeId; String? get ownerRowId; String get payoutScheduleId;
/// Create a copy of MerchantSettlementInputModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSettlementInputModelCopyWith<MerchantSettlementInputModel> get copyWith => _$MerchantSettlementInputModelCopyWithImpl<MerchantSettlementInputModel>(this as MerchantSettlementInputModel, _$identity);

  /// Serializes this MerchantSettlementInputModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSettlementInputModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.holderTypeId, holderTypeId) || other.holderTypeId == holderTypeId)&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.payoutScheduleId, payoutScheduleId) || other.payoutScheduleId == payoutScheduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountHolderName,accountNumber,holderTypeId,ownerRowId,payoutScheduleId);

@override
String toString() {
  return 'MerchantSettlementInputModel(bankId: $bankId, accountHolderName: $accountHolderName, accountNumber: $accountNumber, holderTypeId: $holderTypeId, ownerRowId: $ownerRowId, payoutScheduleId: $payoutScheduleId)';
}


}

/// @nodoc
abstract mixin class $MerchantSettlementInputModelCopyWith<$Res>  {
  factory $MerchantSettlementInputModelCopyWith(MerchantSettlementInputModel value, $Res Function(MerchantSettlementInputModel) _then) = _$MerchantSettlementInputModelCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountHolderName, String accountNumber, String holderTypeId, String? ownerRowId, String payoutScheduleId
});




}
/// @nodoc
class _$MerchantSettlementInputModelCopyWithImpl<$Res>
    implements $MerchantSettlementInputModelCopyWith<$Res> {
  _$MerchantSettlementInputModelCopyWithImpl(this._self, this._then);

  final MerchantSettlementInputModel _self;
  final $Res Function(MerchantSettlementInputModel) _then;

/// Create a copy of MerchantSettlementInputModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountHolderName = null,Object? accountNumber = null,Object? holderTypeId = null,Object? ownerRowId = freezed,Object? payoutScheduleId = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountHolderName: null == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,holderTypeId: null == holderTypeId ? _self.holderTypeId : holderTypeId // ignore: cast_nullable_to_non_nullable
as String,ownerRowId: freezed == ownerRowId ? _self.ownerRowId : ownerRowId // ignore: cast_nullable_to_non_nullable
as String?,payoutScheduleId: null == payoutScheduleId ? _self.payoutScheduleId : payoutScheduleId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantSettlementInputModel].
extension MerchantSettlementInputModelPatterns on MerchantSettlementInputModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSettlementInputModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSettlementInputModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSettlementInputModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSettlementInputModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSettlementInputModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSettlementInputModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bankId,  String accountHolderName,  String accountNumber,  String holderTypeId,  String? ownerRowId,  String payoutScheduleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantSettlementInputModel() when $default != null:
return $default(_that.bankId,_that.accountHolderName,_that.accountNumber,_that.holderTypeId,_that.ownerRowId,_that.payoutScheduleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bankId,  String accountHolderName,  String accountNumber,  String holderTypeId,  String? ownerRowId,  String payoutScheduleId)  $default,) {final _that = this;
switch (_that) {
case _MerchantSettlementInputModel():
return $default(_that.bankId,_that.accountHolderName,_that.accountNumber,_that.holderTypeId,_that.ownerRowId,_that.payoutScheduleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bankId,  String accountHolderName,  String accountNumber,  String holderTypeId,  String? ownerRowId,  String payoutScheduleId)?  $default,) {final _that = this;
switch (_that) {
case _MerchantSettlementInputModel() when $default != null:
return $default(_that.bankId,_that.accountHolderName,_that.accountNumber,_that.holderTypeId,_that.ownerRowId,_that.payoutScheduleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSettlementInputModel implements MerchantSettlementInputModel {
  const _MerchantSettlementInputModel({required this.bankId, required this.accountHolderName, required this.accountNumber, required this.holderTypeId, this.ownerRowId, required this.payoutScheduleId});
  factory _MerchantSettlementInputModel.fromJson(Map<String, dynamic> json) => _$MerchantSettlementInputModelFromJson(json);

@override final  String bankId;
@override final  String accountHolderName;
@override final  String accountNumber;
@override final  String holderTypeId;
@override final  String? ownerRowId;
@override final  String payoutScheduleId;

/// Create a copy of MerchantSettlementInputModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSettlementInputModelCopyWith<_MerchantSettlementInputModel> get copyWith => __$MerchantSettlementInputModelCopyWithImpl<_MerchantSettlementInputModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSettlementInputModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSettlementInputModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.holderTypeId, holderTypeId) || other.holderTypeId == holderTypeId)&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.payoutScheduleId, payoutScheduleId) || other.payoutScheduleId == payoutScheduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountHolderName,accountNumber,holderTypeId,ownerRowId,payoutScheduleId);

@override
String toString() {
  return 'MerchantSettlementInputModel(bankId: $bankId, accountHolderName: $accountHolderName, accountNumber: $accountNumber, holderTypeId: $holderTypeId, ownerRowId: $ownerRowId, payoutScheduleId: $payoutScheduleId)';
}


}

/// @nodoc
abstract mixin class _$MerchantSettlementInputModelCopyWith<$Res> implements $MerchantSettlementInputModelCopyWith<$Res> {
  factory _$MerchantSettlementInputModelCopyWith(_MerchantSettlementInputModel value, $Res Function(_MerchantSettlementInputModel) _then) = __$MerchantSettlementInputModelCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountHolderName, String accountNumber, String holderTypeId, String? ownerRowId, String payoutScheduleId
});




}
/// @nodoc
class __$MerchantSettlementInputModelCopyWithImpl<$Res>
    implements _$MerchantSettlementInputModelCopyWith<$Res> {
  __$MerchantSettlementInputModelCopyWithImpl(this._self, this._then);

  final _MerchantSettlementInputModel _self;
  final $Res Function(_MerchantSettlementInputModel) _then;

/// Create a copy of MerchantSettlementInputModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountHolderName = null,Object? accountNumber = null,Object? holderTypeId = null,Object? ownerRowId = freezed,Object? payoutScheduleId = null,}) {
  return _then(_MerchantSettlementInputModel(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountHolderName: null == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,holderTypeId: null == holderTypeId ? _self.holderTypeId : holderTypeId // ignore: cast_nullable_to_non_nullable
as String,ownerRowId: freezed == ownerRowId ? _self.ownerRowId : ownerRowId // ignore: cast_nullable_to_non_nullable
as String?,payoutScheduleId: null == payoutScheduleId ? _self.payoutScheduleId : payoutScheduleId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantDeclarationsInputModel {

 bool get informationAccurate; bool get authorizedToSubmit; bool get termsAccepted; String get termsVersion;
/// Create a copy of MerchantDeclarationsInputModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputModelCopyWith<MerchantDeclarationsInputModel> get copyWith => _$MerchantDeclarationsInputModelCopyWithImpl<MerchantDeclarationsInputModel>(this as MerchantDeclarationsInputModel, _$identity);

  /// Serializes this MerchantDeclarationsInputModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantDeclarationsInputModel&&(identical(other.informationAccurate, informationAccurate) || other.informationAccurate == informationAccurate)&&(identical(other.authorizedToSubmit, authorizedToSubmit) || other.authorizedToSubmit == authorizedToSubmit)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,informationAccurate,authorizedToSubmit,termsAccepted,termsVersion);

@override
String toString() {
  return 'MerchantDeclarationsInputModel(informationAccurate: $informationAccurate, authorizedToSubmit: $authorizedToSubmit, termsAccepted: $termsAccepted, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $MerchantDeclarationsInputModelCopyWith<$Res>  {
  factory $MerchantDeclarationsInputModelCopyWith(MerchantDeclarationsInputModel value, $Res Function(MerchantDeclarationsInputModel) _then) = _$MerchantDeclarationsInputModelCopyWithImpl;
@useResult
$Res call({
 bool informationAccurate, bool authorizedToSubmit, bool termsAccepted, String termsVersion
});




}
/// @nodoc
class _$MerchantDeclarationsInputModelCopyWithImpl<$Res>
    implements $MerchantDeclarationsInputModelCopyWith<$Res> {
  _$MerchantDeclarationsInputModelCopyWithImpl(this._self, this._then);

  final MerchantDeclarationsInputModel _self;
  final $Res Function(MerchantDeclarationsInputModel) _then;

/// Create a copy of MerchantDeclarationsInputModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? informationAccurate = null,Object? authorizedToSubmit = null,Object? termsAccepted = null,Object? termsVersion = null,}) {
  return _then(_self.copyWith(
informationAccurate: null == informationAccurate ? _self.informationAccurate : informationAccurate // ignore: cast_nullable_to_non_nullable
as bool,authorizedToSubmit: null == authorizedToSubmit ? _self.authorizedToSubmit : authorizedToSubmit // ignore: cast_nullable_to_non_nullable
as bool,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantDeclarationsInputModel].
extension MerchantDeclarationsInputModelPatterns on MerchantDeclarationsInputModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantDeclarationsInputModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantDeclarationsInputModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantDeclarationsInputModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool informationAccurate,  bool authorizedToSubmit,  bool termsAccepted,  String termsVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel() when $default != null:
return $default(_that.informationAccurate,_that.authorizedToSubmit,_that.termsAccepted,_that.termsVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool informationAccurate,  bool authorizedToSubmit,  bool termsAccepted,  String termsVersion)  $default,) {final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel():
return $default(_that.informationAccurate,_that.authorizedToSubmit,_that.termsAccepted,_that.termsVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool informationAccurate,  bool authorizedToSubmit,  bool termsAccepted,  String termsVersion)?  $default,) {final _that = this;
switch (_that) {
case _MerchantDeclarationsInputModel() when $default != null:
return $default(_that.informationAccurate,_that.authorizedToSubmit,_that.termsAccepted,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantDeclarationsInputModel implements MerchantDeclarationsInputModel {
  const _MerchantDeclarationsInputModel({required this.informationAccurate, required this.authorizedToSubmit, required this.termsAccepted, required this.termsVersion});
  factory _MerchantDeclarationsInputModel.fromJson(Map<String, dynamic> json) => _$MerchantDeclarationsInputModelFromJson(json);

@override final  bool informationAccurate;
@override final  bool authorizedToSubmit;
@override final  bool termsAccepted;
@override final  String termsVersion;

/// Create a copy of MerchantDeclarationsInputModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantDeclarationsInputModelCopyWith<_MerchantDeclarationsInputModel> get copyWith => __$MerchantDeclarationsInputModelCopyWithImpl<_MerchantDeclarationsInputModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantDeclarationsInputModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantDeclarationsInputModel&&(identical(other.informationAccurate, informationAccurate) || other.informationAccurate == informationAccurate)&&(identical(other.authorizedToSubmit, authorizedToSubmit) || other.authorizedToSubmit == authorizedToSubmit)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,informationAccurate,authorizedToSubmit,termsAccepted,termsVersion);

@override
String toString() {
  return 'MerchantDeclarationsInputModel(informationAccurate: $informationAccurate, authorizedToSubmit: $authorizedToSubmit, termsAccepted: $termsAccepted, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class _$MerchantDeclarationsInputModelCopyWith<$Res> implements $MerchantDeclarationsInputModelCopyWith<$Res> {
  factory _$MerchantDeclarationsInputModelCopyWith(_MerchantDeclarationsInputModel value, $Res Function(_MerchantDeclarationsInputModel) _then) = __$MerchantDeclarationsInputModelCopyWithImpl;
@override @useResult
$Res call({
 bool informationAccurate, bool authorizedToSubmit, bool termsAccepted, String termsVersion
});




}
/// @nodoc
class __$MerchantDeclarationsInputModelCopyWithImpl<$Res>
    implements _$MerchantDeclarationsInputModelCopyWith<$Res> {
  __$MerchantDeclarationsInputModelCopyWithImpl(this._self, this._then);

  final _MerchantDeclarationsInputModel _self;
  final $Res Function(_MerchantDeclarationsInputModel) _then;

/// Create a copy of MerchantDeclarationsInputModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? informationAccurate = null,Object? authorizedToSubmit = null,Object? termsAccepted = null,Object? termsVersion = null,}) {
  return _then(_MerchantDeclarationsInputModel(
informationAccurate: null == informationAccurate ? _self.informationAccurate : informationAccurate // ignore: cast_nullable_to_non_nullable
as bool,authorizedToSubmit: null == authorizedToSubmit ? _self.authorizedToSubmit : authorizedToSubmit // ignore: cast_nullable_to_non_nullable
as bool,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantSubmitResultModel {

 String get applicationId; String get submittedAt; MerchantSubmitSettlementModel? get settlement;
/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSubmitResultModelCopyWith<MerchantSubmitResultModel> get copyWith => _$MerchantSubmitResultModelCopyWithImpl<MerchantSubmitResultModel>(this as MerchantSubmitResultModel, _$identity);

  /// Serializes this MerchantSubmitResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSubmitResultModel&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.settlement, settlement) || other.settlement == settlement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationId,submittedAt,settlement);

@override
String toString() {
  return 'MerchantSubmitResultModel(applicationId: $applicationId, submittedAt: $submittedAt, settlement: $settlement)';
}


}

/// @nodoc
abstract mixin class $MerchantSubmitResultModelCopyWith<$Res>  {
  factory $MerchantSubmitResultModelCopyWith(MerchantSubmitResultModel value, $Res Function(MerchantSubmitResultModel) _then) = _$MerchantSubmitResultModelCopyWithImpl;
@useResult
$Res call({
 String applicationId, String submittedAt, MerchantSubmitSettlementModel? settlement
});


$MerchantSubmitSettlementModelCopyWith<$Res>? get settlement;

}
/// @nodoc
class _$MerchantSubmitResultModelCopyWithImpl<$Res>
    implements $MerchantSubmitResultModelCopyWith<$Res> {
  _$MerchantSubmitResultModelCopyWithImpl(this._self, this._then);

  final MerchantSubmitResultModel _self;
  final $Res Function(MerchantSubmitResultModel) _then;

/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? applicationId = null,Object? submittedAt = null,Object? settlement = freezed,}) {
  return _then(_self.copyWith(
applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,settlement: freezed == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSubmitSettlementModel?,
  ));
}
/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementModelCopyWith<$Res>? get settlement {
    if (_self.settlement == null) {
    return null;
  }

  return $MerchantSubmitSettlementModelCopyWith<$Res>(_self.settlement!, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantSubmitResultModel].
extension MerchantSubmitResultModelPatterns on MerchantSubmitResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSubmitResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSubmitResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSubmitResultModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSubmitResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementModel? settlement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantSubmitResultModel() when $default != null:
return $default(_that.applicationId,_that.submittedAt,_that.settlement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementModel? settlement)  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitResultModel():
return $default(_that.applicationId,_that.submittedAt,_that.settlement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementModel? settlement)?  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitResultModel() when $default != null:
return $default(_that.applicationId,_that.submittedAt,_that.settlement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSubmitResultModel implements MerchantSubmitResultModel {
  const _MerchantSubmitResultModel({required this.applicationId, required this.submittedAt, this.settlement});
  factory _MerchantSubmitResultModel.fromJson(Map<String, dynamic> json) => _$MerchantSubmitResultModelFromJson(json);

@override final  String applicationId;
@override final  String submittedAt;
@override final  MerchantSubmitSettlementModel? settlement;

/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSubmitResultModelCopyWith<_MerchantSubmitResultModel> get copyWith => __$MerchantSubmitResultModelCopyWithImpl<_MerchantSubmitResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSubmitResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSubmitResultModel&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.settlement, settlement) || other.settlement == settlement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationId,submittedAt,settlement);

@override
String toString() {
  return 'MerchantSubmitResultModel(applicationId: $applicationId, submittedAt: $submittedAt, settlement: $settlement)';
}


}

/// @nodoc
abstract mixin class _$MerchantSubmitResultModelCopyWith<$Res> implements $MerchantSubmitResultModelCopyWith<$Res> {
  factory _$MerchantSubmitResultModelCopyWith(_MerchantSubmitResultModel value, $Res Function(_MerchantSubmitResultModel) _then) = __$MerchantSubmitResultModelCopyWithImpl;
@override @useResult
$Res call({
 String applicationId, String submittedAt, MerchantSubmitSettlementModel? settlement
});


@override $MerchantSubmitSettlementModelCopyWith<$Res>? get settlement;

}
/// @nodoc
class __$MerchantSubmitResultModelCopyWithImpl<$Res>
    implements _$MerchantSubmitResultModelCopyWith<$Res> {
  __$MerchantSubmitResultModelCopyWithImpl(this._self, this._then);

  final _MerchantSubmitResultModel _self;
  final $Res Function(_MerchantSubmitResultModel) _then;

/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? applicationId = null,Object? submittedAt = null,Object? settlement = freezed,}) {
  return _then(_MerchantSubmitResultModel(
applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,settlement: freezed == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSubmitSettlementModel?,
  ));
}

/// Create a copy of MerchantSubmitResultModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementModelCopyWith<$Res>? get settlement {
    if (_self.settlement == null) {
    return null;
  }

  return $MerchantSubmitSettlementModelCopyWith<$Res>(_self.settlement!, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}
}


/// @nodoc
mixin _$MerchantSubmitSettlementModel {

 String get bankId; String get accountNumberLast4;
/// Create a copy of MerchantSubmitSettlementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementModelCopyWith<MerchantSubmitSettlementModel> get copyWith => _$MerchantSubmitSettlementModelCopyWithImpl<MerchantSubmitSettlementModel>(this as MerchantSubmitSettlementModel, _$identity);

  /// Serializes this MerchantSubmitSettlementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSubmitSettlementModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberLast4, accountNumberLast4) || other.accountNumberLast4 == accountNumberLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberLast4);

@override
String toString() {
  return 'MerchantSubmitSettlementModel(bankId: $bankId, accountNumberLast4: $accountNumberLast4)';
}


}

/// @nodoc
abstract mixin class $MerchantSubmitSettlementModelCopyWith<$Res>  {
  factory $MerchantSubmitSettlementModelCopyWith(MerchantSubmitSettlementModel value, $Res Function(MerchantSubmitSettlementModel) _then) = _$MerchantSubmitSettlementModelCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountNumberLast4
});




}
/// @nodoc
class _$MerchantSubmitSettlementModelCopyWithImpl<$Res>
    implements $MerchantSubmitSettlementModelCopyWith<$Res> {
  _$MerchantSubmitSettlementModelCopyWithImpl(this._self, this._then);

  final MerchantSubmitSettlementModel _self;
  final $Res Function(MerchantSubmitSettlementModel) _then;

/// Create a copy of MerchantSubmitSettlementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountNumberLast4 = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberLast4: null == accountNumberLast4 ? _self.accountNumberLast4 : accountNumberLast4 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantSubmitSettlementModel].
extension MerchantSubmitSettlementModelPatterns on MerchantSubmitSettlementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSubmitSettlementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSubmitSettlementModel value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSubmitSettlementModel value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bankId,  String accountNumberLast4)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel() when $default != null:
return $default(_that.bankId,_that.accountNumberLast4);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bankId,  String accountNumberLast4)  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel():
return $default(_that.bankId,_that.accountNumberLast4);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bankId,  String accountNumberLast4)?  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitSettlementModel() when $default != null:
return $default(_that.bankId,_that.accountNumberLast4);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSubmitSettlementModel implements MerchantSubmitSettlementModel {
  const _MerchantSubmitSettlementModel({required this.bankId, required this.accountNumberLast4});
  factory _MerchantSubmitSettlementModel.fromJson(Map<String, dynamic> json) => _$MerchantSubmitSettlementModelFromJson(json);

@override final  String bankId;
@override final  String accountNumberLast4;

/// Create a copy of MerchantSubmitSettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSubmitSettlementModelCopyWith<_MerchantSubmitSettlementModel> get copyWith => __$MerchantSubmitSettlementModelCopyWithImpl<_MerchantSubmitSettlementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSubmitSettlementModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSubmitSettlementModel&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberLast4, accountNumberLast4) || other.accountNumberLast4 == accountNumberLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberLast4);

@override
String toString() {
  return 'MerchantSubmitSettlementModel(bankId: $bankId, accountNumberLast4: $accountNumberLast4)';
}


}

/// @nodoc
abstract mixin class _$MerchantSubmitSettlementModelCopyWith<$Res> implements $MerchantSubmitSettlementModelCopyWith<$Res> {
  factory _$MerchantSubmitSettlementModelCopyWith(_MerchantSubmitSettlementModel value, $Res Function(_MerchantSubmitSettlementModel) _then) = __$MerchantSubmitSettlementModelCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountNumberLast4
});




}
/// @nodoc
class __$MerchantSubmitSettlementModelCopyWithImpl<$Res>
    implements _$MerchantSubmitSettlementModelCopyWith<$Res> {
  __$MerchantSubmitSettlementModelCopyWithImpl(this._self, this._then);

  final _MerchantSubmitSettlementModel _self;
  final $Res Function(_MerchantSubmitSettlementModel) _then;

/// Create a copy of MerchantSubmitSettlementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountNumberLast4 = null,}) {
  return _then(_MerchantSubmitSettlementModel(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberLast4: null == accountNumberLast4 ? _self.accountNumberLast4 : accountNumberLast4 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
