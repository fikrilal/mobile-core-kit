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
mixin _$MerchantOnboardingSubmitRequestDto {

 MerchantBusinessInputDto get business; List<MerchantOwnerInputDto> get owners; MerchantSettlementInputDto get settlement; MerchantDeclarationsInputDto get declarations;
/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOnboardingSubmitRequestDtoCopyWith<MerchantOnboardingSubmitRequestDto> get copyWith => _$MerchantOnboardingSubmitRequestDtoCopyWithImpl<MerchantOnboardingSubmitRequestDto>(this as MerchantOnboardingSubmitRequestDto, _$identity);

  /// Serializes this MerchantOnboardingSubmitRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOnboardingSubmitRequestDto&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other.owners, owners)&&(identical(other.settlement, settlement) || other.settlement == settlement)&&(identical(other.declarations, declarations) || other.declarations == declarations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,business,const DeepCollectionEquality().hash(owners),settlement,declarations);

@override
String toString() {
  return 'MerchantOnboardingSubmitRequestDto(business: $business, owners: $owners, settlement: $settlement, declarations: $declarations)';
}


}

/// @nodoc
abstract mixin class $MerchantOnboardingSubmitRequestDtoCopyWith<$Res>  {
  factory $MerchantOnboardingSubmitRequestDtoCopyWith(MerchantOnboardingSubmitRequestDto value, $Res Function(MerchantOnboardingSubmitRequestDto) _then) = _$MerchantOnboardingSubmitRequestDtoCopyWithImpl;
@useResult
$Res call({
 MerchantBusinessInputDto business, List<MerchantOwnerInputDto> owners, MerchantSettlementInputDto settlement, MerchantDeclarationsInputDto declarations
});


$MerchantBusinessInputDtoCopyWith<$Res> get business;$MerchantSettlementInputDtoCopyWith<$Res> get settlement;$MerchantDeclarationsInputDtoCopyWith<$Res> get declarations;

}
/// @nodoc
class _$MerchantOnboardingSubmitRequestDtoCopyWithImpl<$Res>
    implements $MerchantOnboardingSubmitRequestDtoCopyWith<$Res> {
  _$MerchantOnboardingSubmitRequestDtoCopyWithImpl(this._self, this._then);

  final MerchantOnboardingSubmitRequestDto _self;
  final $Res Function(MerchantOnboardingSubmitRequestDto) _then;

/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? business = null,Object? owners = null,Object? settlement = null,Object? declarations = null,}) {
  return _then(_self.copyWith(
business: null == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as MerchantBusinessInputDto,owners: null == owners ? _self.owners : owners // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerInputDto>,settlement: null == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSettlementInputDto,declarations: null == declarations ? _self.declarations : declarations // ignore: cast_nullable_to_non_nullable
as MerchantDeclarationsInputDto,
  ));
}
/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantBusinessInputDtoCopyWith<$Res> get business {
  
  return $MerchantBusinessInputDtoCopyWith<$Res>(_self.business, (value) {
    return _then(_self.copyWith(business: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSettlementInputDtoCopyWith<$Res> get settlement {
  
  return $MerchantSettlementInputDtoCopyWith<$Res>(_self.settlement, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputDtoCopyWith<$Res> get declarations {
  
  return $MerchantDeclarationsInputDtoCopyWith<$Res>(_self.declarations, (value) {
    return _then(_self.copyWith(declarations: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantOnboardingSubmitRequestDto].
extension MerchantOnboardingSubmitRequestDtoPatterns on MerchantOnboardingSubmitRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOnboardingSubmitRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOnboardingSubmitRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOnboardingSubmitRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MerchantBusinessInputDto business,  List<MerchantOwnerInputDto> owners,  MerchantSettlementInputDto settlement,  MerchantDeclarationsInputDto declarations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MerchantBusinessInputDto business,  List<MerchantOwnerInputDto> owners,  MerchantSettlementInputDto settlement,  MerchantDeclarationsInputDto declarations)  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MerchantBusinessInputDto business,  List<MerchantOwnerInputDto> owners,  MerchantSettlementInputDto settlement,  MerchantDeclarationsInputDto declarations)?  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingSubmitRequestDto() when $default != null:
return $default(_that.business,_that.owners,_that.settlement,_that.declarations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOnboardingSubmitRequestDto implements MerchantOnboardingSubmitRequestDto {
  const _MerchantOnboardingSubmitRequestDto({required this.business, required final  List<MerchantOwnerInputDto> owners, required this.settlement, required this.declarations}): _owners = owners;
  factory _MerchantOnboardingSubmitRequestDto.fromJson(Map<String, dynamic> json) => _$MerchantOnboardingSubmitRequestDtoFromJson(json);

@override final  MerchantBusinessInputDto business;
 final  List<MerchantOwnerInputDto> _owners;
@override List<MerchantOwnerInputDto> get owners {
  if (_owners is EqualUnmodifiableListView) return _owners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_owners);
}

@override final  MerchantSettlementInputDto settlement;
@override final  MerchantDeclarationsInputDto declarations;

/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOnboardingSubmitRequestDtoCopyWith<_MerchantOnboardingSubmitRequestDto> get copyWith => __$MerchantOnboardingSubmitRequestDtoCopyWithImpl<_MerchantOnboardingSubmitRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOnboardingSubmitRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOnboardingSubmitRequestDto&&(identical(other.business, business) || other.business == business)&&const DeepCollectionEquality().equals(other._owners, _owners)&&(identical(other.settlement, settlement) || other.settlement == settlement)&&(identical(other.declarations, declarations) || other.declarations == declarations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,business,const DeepCollectionEquality().hash(_owners),settlement,declarations);

@override
String toString() {
  return 'MerchantOnboardingSubmitRequestDto(business: $business, owners: $owners, settlement: $settlement, declarations: $declarations)';
}


}

/// @nodoc
abstract mixin class _$MerchantOnboardingSubmitRequestDtoCopyWith<$Res> implements $MerchantOnboardingSubmitRequestDtoCopyWith<$Res> {
  factory _$MerchantOnboardingSubmitRequestDtoCopyWith(_MerchantOnboardingSubmitRequestDto value, $Res Function(_MerchantOnboardingSubmitRequestDto) _then) = __$MerchantOnboardingSubmitRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 MerchantBusinessInputDto business, List<MerchantOwnerInputDto> owners, MerchantSettlementInputDto settlement, MerchantDeclarationsInputDto declarations
});


@override $MerchantBusinessInputDtoCopyWith<$Res> get business;@override $MerchantSettlementInputDtoCopyWith<$Res> get settlement;@override $MerchantDeclarationsInputDtoCopyWith<$Res> get declarations;

}
/// @nodoc
class __$MerchantOnboardingSubmitRequestDtoCopyWithImpl<$Res>
    implements _$MerchantOnboardingSubmitRequestDtoCopyWith<$Res> {
  __$MerchantOnboardingSubmitRequestDtoCopyWithImpl(this._self, this._then);

  final _MerchantOnboardingSubmitRequestDto _self;
  final $Res Function(_MerchantOnboardingSubmitRequestDto) _then;

/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? business = null,Object? owners = null,Object? settlement = null,Object? declarations = null,}) {
  return _then(_MerchantOnboardingSubmitRequestDto(
business: null == business ? _self.business : business // ignore: cast_nullable_to_non_nullable
as MerchantBusinessInputDto,owners: null == owners ? _self._owners : owners // ignore: cast_nullable_to_non_nullable
as List<MerchantOwnerInputDto>,settlement: null == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSettlementInputDto,declarations: null == declarations ? _self.declarations : declarations // ignore: cast_nullable_to_non_nullable
as MerchantDeclarationsInputDto,
  ));
}

/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantBusinessInputDtoCopyWith<$Res> get business {
  
  return $MerchantBusinessInputDtoCopyWith<$Res>(_self.business, (value) {
    return _then(_self.copyWith(business: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSettlementInputDtoCopyWith<$Res> get settlement {
  
  return $MerchantSettlementInputDtoCopyWith<$Res>(_self.settlement, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}/// Create a copy of MerchantOnboardingSubmitRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputDtoCopyWith<$Res> get declarations {
  
  return $MerchantDeclarationsInputDtoCopyWith<$Res>(_self.declarations, (value) {
    return _then(_self.copyWith(declarations: value));
  });
}
}


/// @nodoc
mixin _$MerchantBusinessInputDto {

 String get legalName; String get businessTypeId; String? get registrationNumber; String get industryId; String get monthlySalesRangeId; String get contactEmail; String get contactPhone;
/// Create a copy of MerchantBusinessInputDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantBusinessInputDtoCopyWith<MerchantBusinessInputDto> get copyWith => _$MerchantBusinessInputDtoCopyWithImpl<MerchantBusinessInputDto>(this as MerchantBusinessInputDto, _$identity);

  /// Serializes this MerchantBusinessInputDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantBusinessInputDto&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessTypeId, businessTypeId) || other.businessTypeId == businessTypeId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.industryId, industryId) || other.industryId == industryId)&&(identical(other.monthlySalesRangeId, monthlySalesRangeId) || other.monthlySalesRangeId == monthlySalesRangeId)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,legalName,businessTypeId,registrationNumber,industryId,monthlySalesRangeId,contactEmail,contactPhone);

@override
String toString() {
  return 'MerchantBusinessInputDto(legalName: $legalName, businessTypeId: $businessTypeId, registrationNumber: $registrationNumber, industryId: $industryId, monthlySalesRangeId: $monthlySalesRangeId, contactEmail: $contactEmail, contactPhone: $contactPhone)';
}


}

/// @nodoc
abstract mixin class $MerchantBusinessInputDtoCopyWith<$Res>  {
  factory $MerchantBusinessInputDtoCopyWith(MerchantBusinessInputDto value, $Res Function(MerchantBusinessInputDto) _then) = _$MerchantBusinessInputDtoCopyWithImpl;
@useResult
$Res call({
 String legalName, String businessTypeId, String? registrationNumber, String industryId, String monthlySalesRangeId, String contactEmail, String contactPhone
});




}
/// @nodoc
class _$MerchantBusinessInputDtoCopyWithImpl<$Res>
    implements $MerchantBusinessInputDtoCopyWith<$Res> {
  _$MerchantBusinessInputDtoCopyWithImpl(this._self, this._then);

  final MerchantBusinessInputDto _self;
  final $Res Function(MerchantBusinessInputDto) _then;

/// Create a copy of MerchantBusinessInputDto
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


/// Adds pattern-matching-related methods to [MerchantBusinessInputDto].
extension MerchantBusinessInputDtoPatterns on MerchantBusinessInputDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantBusinessInputDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantBusinessInputDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantBusinessInputDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessInputDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantBusinessInputDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantBusinessInputDto() when $default != null:
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
case _MerchantBusinessInputDto() when $default != null:
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
case _MerchantBusinessInputDto():
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
case _MerchantBusinessInputDto() when $default != null:
return $default(_that.legalName,_that.businessTypeId,_that.registrationNumber,_that.industryId,_that.monthlySalesRangeId,_that.contactEmail,_that.contactPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantBusinessInputDto implements MerchantBusinessInputDto {
  const _MerchantBusinessInputDto({required this.legalName, required this.businessTypeId, this.registrationNumber, required this.industryId, required this.monthlySalesRangeId, required this.contactEmail, required this.contactPhone});
  factory _MerchantBusinessInputDto.fromJson(Map<String, dynamic> json) => _$MerchantBusinessInputDtoFromJson(json);

@override final  String legalName;
@override final  String businessTypeId;
@override final  String? registrationNumber;
@override final  String industryId;
@override final  String monthlySalesRangeId;
@override final  String contactEmail;
@override final  String contactPhone;

/// Create a copy of MerchantBusinessInputDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantBusinessInputDtoCopyWith<_MerchantBusinessInputDto> get copyWith => __$MerchantBusinessInputDtoCopyWithImpl<_MerchantBusinessInputDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantBusinessInputDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantBusinessInputDto&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.businessTypeId, businessTypeId) || other.businessTypeId == businessTypeId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.industryId, industryId) || other.industryId == industryId)&&(identical(other.monthlySalesRangeId, monthlySalesRangeId) || other.monthlySalesRangeId == monthlySalesRangeId)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,legalName,businessTypeId,registrationNumber,industryId,monthlySalesRangeId,contactEmail,contactPhone);

@override
String toString() {
  return 'MerchantBusinessInputDto(legalName: $legalName, businessTypeId: $businessTypeId, registrationNumber: $registrationNumber, industryId: $industryId, monthlySalesRangeId: $monthlySalesRangeId, contactEmail: $contactEmail, contactPhone: $contactPhone)';
}


}

/// @nodoc
abstract mixin class _$MerchantBusinessInputDtoCopyWith<$Res> implements $MerchantBusinessInputDtoCopyWith<$Res> {
  factory _$MerchantBusinessInputDtoCopyWith(_MerchantBusinessInputDto value, $Res Function(_MerchantBusinessInputDto) _then) = __$MerchantBusinessInputDtoCopyWithImpl;
@override @useResult
$Res call({
 String legalName, String businessTypeId, String? registrationNumber, String industryId, String monthlySalesRangeId, String contactEmail, String contactPhone
});




}
/// @nodoc
class __$MerchantBusinessInputDtoCopyWithImpl<$Res>
    implements _$MerchantBusinessInputDtoCopyWith<$Res> {
  __$MerchantBusinessInputDtoCopyWithImpl(this._self, this._then);

  final _MerchantBusinessInputDto _self;
  final $Res Function(_MerchantBusinessInputDto) _then;

/// Create a copy of MerchantBusinessInputDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? legalName = null,Object? businessTypeId = null,Object? registrationNumber = freezed,Object? industryId = null,Object? monthlySalesRangeId = null,Object? contactEmail = null,Object? contactPhone = null,}) {
  return _then(_MerchantBusinessInputDto(
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
mixin _$MerchantOwnerInputDto {

 String get ownerRowId; String get fullName; String get roleId; int? get ownershipBasisPoints; String get email; bool get isPrimaryContact;
/// Create a copy of MerchantOwnerInputDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOwnerInputDtoCopyWith<MerchantOwnerInputDto> get copyWith => _$MerchantOwnerInputDtoCopyWithImpl<MerchantOwnerInputDto>(this as MerchantOwnerInputDto, _$identity);

  /// Serializes this MerchantOwnerInputDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOwnerInputDto&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.ownershipBasisPoints, ownershipBasisPoints) || other.ownershipBasisPoints == ownershipBasisPoints)&&(identical(other.email, email) || other.email == email)&&(identical(other.isPrimaryContact, isPrimaryContact) || other.isPrimaryContact == isPrimaryContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerRowId,fullName,roleId,ownershipBasisPoints,email,isPrimaryContact);

@override
String toString() {
  return 'MerchantOwnerInputDto(ownerRowId: $ownerRowId, fullName: $fullName, roleId: $roleId, ownershipBasisPoints: $ownershipBasisPoints, email: $email, isPrimaryContact: $isPrimaryContact)';
}


}

/// @nodoc
abstract mixin class $MerchantOwnerInputDtoCopyWith<$Res>  {
  factory $MerchantOwnerInputDtoCopyWith(MerchantOwnerInputDto value, $Res Function(MerchantOwnerInputDto) _then) = _$MerchantOwnerInputDtoCopyWithImpl;
@useResult
$Res call({
 String ownerRowId, String fullName, String roleId, int? ownershipBasisPoints, String email, bool isPrimaryContact
});




}
/// @nodoc
class _$MerchantOwnerInputDtoCopyWithImpl<$Res>
    implements $MerchantOwnerInputDtoCopyWith<$Res> {
  _$MerchantOwnerInputDtoCopyWithImpl(this._self, this._then);

  final MerchantOwnerInputDto _self;
  final $Res Function(MerchantOwnerInputDto) _then;

/// Create a copy of MerchantOwnerInputDto
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


/// Adds pattern-matching-related methods to [MerchantOwnerInputDto].
extension MerchantOwnerInputDtoPatterns on MerchantOwnerInputDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOwnerInputDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOwnerInputDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOwnerInputDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerInputDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOwnerInputDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOwnerInputDto() when $default != null:
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
case _MerchantOwnerInputDto() when $default != null:
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
case _MerchantOwnerInputDto():
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
case _MerchantOwnerInputDto() when $default != null:
return $default(_that.ownerRowId,_that.fullName,_that.roleId,_that.ownershipBasisPoints,_that.email,_that.isPrimaryContact);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantOwnerInputDto implements MerchantOwnerInputDto {
  const _MerchantOwnerInputDto({required this.ownerRowId, required this.fullName, required this.roleId, this.ownershipBasisPoints, required this.email, required this.isPrimaryContact});
  factory _MerchantOwnerInputDto.fromJson(Map<String, dynamic> json) => _$MerchantOwnerInputDtoFromJson(json);

@override final  String ownerRowId;
@override final  String fullName;
@override final  String roleId;
@override final  int? ownershipBasisPoints;
@override final  String email;
@override final  bool isPrimaryContact;

/// Create a copy of MerchantOwnerInputDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOwnerInputDtoCopyWith<_MerchantOwnerInputDto> get copyWith => __$MerchantOwnerInputDtoCopyWithImpl<_MerchantOwnerInputDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantOwnerInputDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOwnerInputDto&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.ownershipBasisPoints, ownershipBasisPoints) || other.ownershipBasisPoints == ownershipBasisPoints)&&(identical(other.email, email) || other.email == email)&&(identical(other.isPrimaryContact, isPrimaryContact) || other.isPrimaryContact == isPrimaryContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerRowId,fullName,roleId,ownershipBasisPoints,email,isPrimaryContact);

@override
String toString() {
  return 'MerchantOwnerInputDto(ownerRowId: $ownerRowId, fullName: $fullName, roleId: $roleId, ownershipBasisPoints: $ownershipBasisPoints, email: $email, isPrimaryContact: $isPrimaryContact)';
}


}

/// @nodoc
abstract mixin class _$MerchantOwnerInputDtoCopyWith<$Res> implements $MerchantOwnerInputDtoCopyWith<$Res> {
  factory _$MerchantOwnerInputDtoCopyWith(_MerchantOwnerInputDto value, $Res Function(_MerchantOwnerInputDto) _then) = __$MerchantOwnerInputDtoCopyWithImpl;
@override @useResult
$Res call({
 String ownerRowId, String fullName, String roleId, int? ownershipBasisPoints, String email, bool isPrimaryContact
});




}
/// @nodoc
class __$MerchantOwnerInputDtoCopyWithImpl<$Res>
    implements _$MerchantOwnerInputDtoCopyWith<$Res> {
  __$MerchantOwnerInputDtoCopyWithImpl(this._self, this._then);

  final _MerchantOwnerInputDto _self;
  final $Res Function(_MerchantOwnerInputDto) _then;

/// Create a copy of MerchantOwnerInputDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerRowId = null,Object? fullName = null,Object? roleId = null,Object? ownershipBasisPoints = freezed,Object? email = null,Object? isPrimaryContact = null,}) {
  return _then(_MerchantOwnerInputDto(
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
mixin _$MerchantSettlementInputDto {

 String get bankId; String get accountHolderName; String get accountNumber; String get holderTypeId; String? get ownerRowId; String get payoutScheduleId;
/// Create a copy of MerchantSettlementInputDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSettlementInputDtoCopyWith<MerchantSettlementInputDto> get copyWith => _$MerchantSettlementInputDtoCopyWithImpl<MerchantSettlementInputDto>(this as MerchantSettlementInputDto, _$identity);

  /// Serializes this MerchantSettlementInputDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSettlementInputDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.holderTypeId, holderTypeId) || other.holderTypeId == holderTypeId)&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.payoutScheduleId, payoutScheduleId) || other.payoutScheduleId == payoutScheduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountHolderName,accountNumber,holderTypeId,ownerRowId,payoutScheduleId);

@override
String toString() {
  return 'MerchantSettlementInputDto(bankId: $bankId, accountHolderName: $accountHolderName, accountNumber: $accountNumber, holderTypeId: $holderTypeId, ownerRowId: $ownerRowId, payoutScheduleId: $payoutScheduleId)';
}


}

/// @nodoc
abstract mixin class $MerchantSettlementInputDtoCopyWith<$Res>  {
  factory $MerchantSettlementInputDtoCopyWith(MerchantSettlementInputDto value, $Res Function(MerchantSettlementInputDto) _then) = _$MerchantSettlementInputDtoCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountHolderName, String accountNumber, String holderTypeId, String? ownerRowId, String payoutScheduleId
});




}
/// @nodoc
class _$MerchantSettlementInputDtoCopyWithImpl<$Res>
    implements $MerchantSettlementInputDtoCopyWith<$Res> {
  _$MerchantSettlementInputDtoCopyWithImpl(this._self, this._then);

  final MerchantSettlementInputDto _self;
  final $Res Function(MerchantSettlementInputDto) _then;

/// Create a copy of MerchantSettlementInputDto
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


/// Adds pattern-matching-related methods to [MerchantSettlementInputDto].
extension MerchantSettlementInputDtoPatterns on MerchantSettlementInputDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSettlementInputDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSettlementInputDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSettlementInputDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSettlementInputDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSettlementInputDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSettlementInputDto() when $default != null:
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
case _MerchantSettlementInputDto() when $default != null:
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
case _MerchantSettlementInputDto():
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
case _MerchantSettlementInputDto() when $default != null:
return $default(_that.bankId,_that.accountHolderName,_that.accountNumber,_that.holderTypeId,_that.ownerRowId,_that.payoutScheduleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSettlementInputDto implements MerchantSettlementInputDto {
  const _MerchantSettlementInputDto({required this.bankId, required this.accountHolderName, required this.accountNumber, required this.holderTypeId, this.ownerRowId, required this.payoutScheduleId});
  factory _MerchantSettlementInputDto.fromJson(Map<String, dynamic> json) => _$MerchantSettlementInputDtoFromJson(json);

@override final  String bankId;
@override final  String accountHolderName;
@override final  String accountNumber;
@override final  String holderTypeId;
@override final  String? ownerRowId;
@override final  String payoutScheduleId;

/// Create a copy of MerchantSettlementInputDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSettlementInputDtoCopyWith<_MerchantSettlementInputDto> get copyWith => __$MerchantSettlementInputDtoCopyWithImpl<_MerchantSettlementInputDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSettlementInputDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSettlementInputDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.holderTypeId, holderTypeId) || other.holderTypeId == holderTypeId)&&(identical(other.ownerRowId, ownerRowId) || other.ownerRowId == ownerRowId)&&(identical(other.payoutScheduleId, payoutScheduleId) || other.payoutScheduleId == payoutScheduleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountHolderName,accountNumber,holderTypeId,ownerRowId,payoutScheduleId);

@override
String toString() {
  return 'MerchantSettlementInputDto(bankId: $bankId, accountHolderName: $accountHolderName, accountNumber: $accountNumber, holderTypeId: $holderTypeId, ownerRowId: $ownerRowId, payoutScheduleId: $payoutScheduleId)';
}


}

/// @nodoc
abstract mixin class _$MerchantSettlementInputDtoCopyWith<$Res> implements $MerchantSettlementInputDtoCopyWith<$Res> {
  factory _$MerchantSettlementInputDtoCopyWith(_MerchantSettlementInputDto value, $Res Function(_MerchantSettlementInputDto) _then) = __$MerchantSettlementInputDtoCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountHolderName, String accountNumber, String holderTypeId, String? ownerRowId, String payoutScheduleId
});




}
/// @nodoc
class __$MerchantSettlementInputDtoCopyWithImpl<$Res>
    implements _$MerchantSettlementInputDtoCopyWith<$Res> {
  __$MerchantSettlementInputDtoCopyWithImpl(this._self, this._then);

  final _MerchantSettlementInputDto _self;
  final $Res Function(_MerchantSettlementInputDto) _then;

/// Create a copy of MerchantSettlementInputDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountHolderName = null,Object? accountNumber = null,Object? holderTypeId = null,Object? ownerRowId = freezed,Object? payoutScheduleId = null,}) {
  return _then(_MerchantSettlementInputDto(
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
mixin _$MerchantDeclarationsInputDto {

 bool get informationAccurate; bool get authorizedToSubmit; bool get termsAccepted; String get termsVersion;
/// Create a copy of MerchantDeclarationsInputDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantDeclarationsInputDtoCopyWith<MerchantDeclarationsInputDto> get copyWith => _$MerchantDeclarationsInputDtoCopyWithImpl<MerchantDeclarationsInputDto>(this as MerchantDeclarationsInputDto, _$identity);

  /// Serializes this MerchantDeclarationsInputDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantDeclarationsInputDto&&(identical(other.informationAccurate, informationAccurate) || other.informationAccurate == informationAccurate)&&(identical(other.authorizedToSubmit, authorizedToSubmit) || other.authorizedToSubmit == authorizedToSubmit)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,informationAccurate,authorizedToSubmit,termsAccepted,termsVersion);

@override
String toString() {
  return 'MerchantDeclarationsInputDto(informationAccurate: $informationAccurate, authorizedToSubmit: $authorizedToSubmit, termsAccepted: $termsAccepted, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class $MerchantDeclarationsInputDtoCopyWith<$Res>  {
  factory $MerchantDeclarationsInputDtoCopyWith(MerchantDeclarationsInputDto value, $Res Function(MerchantDeclarationsInputDto) _then) = _$MerchantDeclarationsInputDtoCopyWithImpl;
@useResult
$Res call({
 bool informationAccurate, bool authorizedToSubmit, bool termsAccepted, String termsVersion
});




}
/// @nodoc
class _$MerchantDeclarationsInputDtoCopyWithImpl<$Res>
    implements $MerchantDeclarationsInputDtoCopyWith<$Res> {
  _$MerchantDeclarationsInputDtoCopyWithImpl(this._self, this._then);

  final MerchantDeclarationsInputDto _self;
  final $Res Function(MerchantDeclarationsInputDto) _then;

/// Create a copy of MerchantDeclarationsInputDto
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


/// Adds pattern-matching-related methods to [MerchantDeclarationsInputDto].
extension MerchantDeclarationsInputDtoPatterns on MerchantDeclarationsInputDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantDeclarationsInputDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantDeclarationsInputDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantDeclarationsInputDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantDeclarationsInputDto() when $default != null:
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
case _MerchantDeclarationsInputDto() when $default != null:
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
case _MerchantDeclarationsInputDto():
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
case _MerchantDeclarationsInputDto() when $default != null:
return $default(_that.informationAccurate,_that.authorizedToSubmit,_that.termsAccepted,_that.termsVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantDeclarationsInputDto implements MerchantDeclarationsInputDto {
  const _MerchantDeclarationsInputDto({required this.informationAccurate, required this.authorizedToSubmit, required this.termsAccepted, required this.termsVersion});
  factory _MerchantDeclarationsInputDto.fromJson(Map<String, dynamic> json) => _$MerchantDeclarationsInputDtoFromJson(json);

@override final  bool informationAccurate;
@override final  bool authorizedToSubmit;
@override final  bool termsAccepted;
@override final  String termsVersion;

/// Create a copy of MerchantDeclarationsInputDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantDeclarationsInputDtoCopyWith<_MerchantDeclarationsInputDto> get copyWith => __$MerchantDeclarationsInputDtoCopyWithImpl<_MerchantDeclarationsInputDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantDeclarationsInputDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantDeclarationsInputDto&&(identical(other.informationAccurate, informationAccurate) || other.informationAccurate == informationAccurate)&&(identical(other.authorizedToSubmit, authorizedToSubmit) || other.authorizedToSubmit == authorizedToSubmit)&&(identical(other.termsAccepted, termsAccepted) || other.termsAccepted == termsAccepted)&&(identical(other.termsVersion, termsVersion) || other.termsVersion == termsVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,informationAccurate,authorizedToSubmit,termsAccepted,termsVersion);

@override
String toString() {
  return 'MerchantDeclarationsInputDto(informationAccurate: $informationAccurate, authorizedToSubmit: $authorizedToSubmit, termsAccepted: $termsAccepted, termsVersion: $termsVersion)';
}


}

/// @nodoc
abstract mixin class _$MerchantDeclarationsInputDtoCopyWith<$Res> implements $MerchantDeclarationsInputDtoCopyWith<$Res> {
  factory _$MerchantDeclarationsInputDtoCopyWith(_MerchantDeclarationsInputDto value, $Res Function(_MerchantDeclarationsInputDto) _then) = __$MerchantDeclarationsInputDtoCopyWithImpl;
@override @useResult
$Res call({
 bool informationAccurate, bool authorizedToSubmit, bool termsAccepted, String termsVersion
});




}
/// @nodoc
class __$MerchantDeclarationsInputDtoCopyWithImpl<$Res>
    implements _$MerchantDeclarationsInputDtoCopyWith<$Res> {
  __$MerchantDeclarationsInputDtoCopyWithImpl(this._self, this._then);

  final _MerchantDeclarationsInputDto _self;
  final $Res Function(_MerchantDeclarationsInputDto) _then;

/// Create a copy of MerchantDeclarationsInputDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? informationAccurate = null,Object? authorizedToSubmit = null,Object? termsAccepted = null,Object? termsVersion = null,}) {
  return _then(_MerchantDeclarationsInputDto(
informationAccurate: null == informationAccurate ? _self.informationAccurate : informationAccurate // ignore: cast_nullable_to_non_nullable
as bool,authorizedToSubmit: null == authorizedToSubmit ? _self.authorizedToSubmit : authorizedToSubmit // ignore: cast_nullable_to_non_nullable
as bool,termsAccepted: null == termsAccepted ? _self.termsAccepted : termsAccepted // ignore: cast_nullable_to_non_nullable
as bool,termsVersion: null == termsVersion ? _self.termsVersion : termsVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MerchantSubmitResultDto {

 String get applicationId; String get submittedAt; MerchantSubmitSettlementDto? get settlement;
/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSubmitResultDtoCopyWith<MerchantSubmitResultDto> get copyWith => _$MerchantSubmitResultDtoCopyWithImpl<MerchantSubmitResultDto>(this as MerchantSubmitResultDto, _$identity);

  /// Serializes this MerchantSubmitResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSubmitResultDto&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.settlement, settlement) || other.settlement == settlement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationId,submittedAt,settlement);

@override
String toString() {
  return 'MerchantSubmitResultDto(applicationId: $applicationId, submittedAt: $submittedAt, settlement: $settlement)';
}


}

/// @nodoc
abstract mixin class $MerchantSubmitResultDtoCopyWith<$Res>  {
  factory $MerchantSubmitResultDtoCopyWith(MerchantSubmitResultDto value, $Res Function(MerchantSubmitResultDto) _then) = _$MerchantSubmitResultDtoCopyWithImpl;
@useResult
$Res call({
 String applicationId, String submittedAt, MerchantSubmitSettlementDto? settlement
});


$MerchantSubmitSettlementDtoCopyWith<$Res>? get settlement;

}
/// @nodoc
class _$MerchantSubmitResultDtoCopyWithImpl<$Res>
    implements $MerchantSubmitResultDtoCopyWith<$Res> {
  _$MerchantSubmitResultDtoCopyWithImpl(this._self, this._then);

  final MerchantSubmitResultDto _self;
  final $Res Function(MerchantSubmitResultDto) _then;

/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? applicationId = null,Object? submittedAt = null,Object? settlement = freezed,}) {
  return _then(_self.copyWith(
applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,settlement: freezed == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSubmitSettlementDto?,
  ));
}
/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementDtoCopyWith<$Res>? get settlement {
    if (_self.settlement == null) {
    return null;
  }

  return $MerchantSubmitSettlementDtoCopyWith<$Res>(_self.settlement!, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantSubmitResultDto].
extension MerchantSubmitResultDtoPatterns on MerchantSubmitResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSubmitResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSubmitResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSubmitResultDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitResultDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSubmitResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementDto? settlement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantSubmitResultDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementDto? settlement)  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitResultDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String applicationId,  String submittedAt,  MerchantSubmitSettlementDto? settlement)?  $default,) {final _that = this;
switch (_that) {
case _MerchantSubmitResultDto() when $default != null:
return $default(_that.applicationId,_that.submittedAt,_that.settlement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSubmitResultDto implements MerchantSubmitResultDto {
  const _MerchantSubmitResultDto({required this.applicationId, required this.submittedAt, this.settlement});
  factory _MerchantSubmitResultDto.fromJson(Map<String, dynamic> json) => _$MerchantSubmitResultDtoFromJson(json);

@override final  String applicationId;
@override final  String submittedAt;
@override final  MerchantSubmitSettlementDto? settlement;

/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSubmitResultDtoCopyWith<_MerchantSubmitResultDto> get copyWith => __$MerchantSubmitResultDtoCopyWithImpl<_MerchantSubmitResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSubmitResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSubmitResultDto&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.settlement, settlement) || other.settlement == settlement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,applicationId,submittedAt,settlement);

@override
String toString() {
  return 'MerchantSubmitResultDto(applicationId: $applicationId, submittedAt: $submittedAt, settlement: $settlement)';
}


}

/// @nodoc
abstract mixin class _$MerchantSubmitResultDtoCopyWith<$Res> implements $MerchantSubmitResultDtoCopyWith<$Res> {
  factory _$MerchantSubmitResultDtoCopyWith(_MerchantSubmitResultDto value, $Res Function(_MerchantSubmitResultDto) _then) = __$MerchantSubmitResultDtoCopyWithImpl;
@override @useResult
$Res call({
 String applicationId, String submittedAt, MerchantSubmitSettlementDto? settlement
});


@override $MerchantSubmitSettlementDtoCopyWith<$Res>? get settlement;

}
/// @nodoc
class __$MerchantSubmitResultDtoCopyWithImpl<$Res>
    implements _$MerchantSubmitResultDtoCopyWith<$Res> {
  __$MerchantSubmitResultDtoCopyWithImpl(this._self, this._then);

  final _MerchantSubmitResultDto _self;
  final $Res Function(_MerchantSubmitResultDto) _then;

/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? applicationId = null,Object? submittedAt = null,Object? settlement = freezed,}) {
  return _then(_MerchantSubmitResultDto(
applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,settlement: freezed == settlement ? _self.settlement : settlement // ignore: cast_nullable_to_non_nullable
as MerchantSubmitSettlementDto?,
  ));
}

/// Create a copy of MerchantSubmitResultDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementDtoCopyWith<$Res>? get settlement {
    if (_self.settlement == null) {
    return null;
  }

  return $MerchantSubmitSettlementDtoCopyWith<$Res>(_self.settlement!, (value) {
    return _then(_self.copyWith(settlement: value));
  });
}
}


/// @nodoc
mixin _$MerchantSubmitSettlementDto {

 String get bankId; String get accountNumberLast4;
/// Create a copy of MerchantSubmitSettlementDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantSubmitSettlementDtoCopyWith<MerchantSubmitSettlementDto> get copyWith => _$MerchantSubmitSettlementDtoCopyWithImpl<MerchantSubmitSettlementDto>(this as MerchantSubmitSettlementDto, _$identity);

  /// Serializes this MerchantSubmitSettlementDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantSubmitSettlementDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberLast4, accountNumberLast4) || other.accountNumberLast4 == accountNumberLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberLast4);

@override
String toString() {
  return 'MerchantSubmitSettlementDto(bankId: $bankId, accountNumberLast4: $accountNumberLast4)';
}


}

/// @nodoc
abstract mixin class $MerchantSubmitSettlementDtoCopyWith<$Res>  {
  factory $MerchantSubmitSettlementDtoCopyWith(MerchantSubmitSettlementDto value, $Res Function(MerchantSubmitSettlementDto) _then) = _$MerchantSubmitSettlementDtoCopyWithImpl;
@useResult
$Res call({
 String bankId, String accountNumberLast4
});




}
/// @nodoc
class _$MerchantSubmitSettlementDtoCopyWithImpl<$Res>
    implements $MerchantSubmitSettlementDtoCopyWith<$Res> {
  _$MerchantSubmitSettlementDtoCopyWithImpl(this._self, this._then);

  final MerchantSubmitSettlementDto _self;
  final $Res Function(MerchantSubmitSettlementDto) _then;

/// Create a copy of MerchantSubmitSettlementDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bankId = null,Object? accountNumberLast4 = null,}) {
  return _then(_self.copyWith(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberLast4: null == accountNumberLast4 ? _self.accountNumberLast4 : accountNumberLast4 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MerchantSubmitSettlementDto].
extension MerchantSubmitSettlementDtoPatterns on MerchantSubmitSettlementDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantSubmitSettlementDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantSubmitSettlementDto value)  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantSubmitSettlementDto value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantSubmitSettlementDto() when $default != null:
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
case _MerchantSubmitSettlementDto() when $default != null:
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
case _MerchantSubmitSettlementDto():
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
case _MerchantSubmitSettlementDto() when $default != null:
return $default(_that.bankId,_that.accountNumberLast4);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MerchantSubmitSettlementDto implements MerchantSubmitSettlementDto {
  const _MerchantSubmitSettlementDto({required this.bankId, required this.accountNumberLast4});
  factory _MerchantSubmitSettlementDto.fromJson(Map<String, dynamic> json) => _$MerchantSubmitSettlementDtoFromJson(json);

@override final  String bankId;
@override final  String accountNumberLast4;

/// Create a copy of MerchantSubmitSettlementDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantSubmitSettlementDtoCopyWith<_MerchantSubmitSettlementDto> get copyWith => __$MerchantSubmitSettlementDtoCopyWithImpl<_MerchantSubmitSettlementDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MerchantSubmitSettlementDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantSubmitSettlementDto&&(identical(other.bankId, bankId) || other.bankId == bankId)&&(identical(other.accountNumberLast4, accountNumberLast4) || other.accountNumberLast4 == accountNumberLast4));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bankId,accountNumberLast4);

@override
String toString() {
  return 'MerchantSubmitSettlementDto(bankId: $bankId, accountNumberLast4: $accountNumberLast4)';
}


}

/// @nodoc
abstract mixin class _$MerchantSubmitSettlementDtoCopyWith<$Res> implements $MerchantSubmitSettlementDtoCopyWith<$Res> {
  factory _$MerchantSubmitSettlementDtoCopyWith(_MerchantSubmitSettlementDto value, $Res Function(_MerchantSubmitSettlementDto) _then) = __$MerchantSubmitSettlementDtoCopyWithImpl;
@override @useResult
$Res call({
 String bankId, String accountNumberLast4
});




}
/// @nodoc
class __$MerchantSubmitSettlementDtoCopyWithImpl<$Res>
    implements _$MerchantSubmitSettlementDtoCopyWith<$Res> {
  __$MerchantSubmitSettlementDtoCopyWithImpl(this._self, this._then);

  final _MerchantSubmitSettlementDto _self;
  final $Res Function(_MerchantSubmitSettlementDto) _then;

/// Create a copy of MerchantSubmitSettlementDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bankId = null,Object? accountNumberLast4 = null,}) {
  return _then(_MerchantSubmitSettlementDto(
bankId: null == bankId ? _self.bankId : bankId // ignore: cast_nullable_to_non_nullable
as String,accountNumberLast4: null == accountNumberLast4 ? _self.accountNumberLast4 : accountNumberLast4 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
