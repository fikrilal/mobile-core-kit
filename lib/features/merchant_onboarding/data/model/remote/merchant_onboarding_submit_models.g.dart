// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_onboarding_submit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MerchantOnboardingSubmitRequestDto
_$MerchantOnboardingSubmitRequestDtoFromJson(Map<String, dynamic> json) =>
    _MerchantOnboardingSubmitRequestDto(
      business: MerchantBusinessInputDto.fromJson(
        json['business'] as Map<String, dynamic>,
      ),
      owners: (json['owners'] as List<dynamic>)
          .map((e) => MerchantOwnerInputDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      settlement: MerchantSettlementInputDto.fromJson(
        json['settlement'] as Map<String, dynamic>,
      ),
      declarations: MerchantDeclarationsInputDto.fromJson(
        json['declarations'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MerchantOnboardingSubmitRequestDtoToJson(
  _MerchantOnboardingSubmitRequestDto instance,
) => <String, dynamic>{
  'business': instance.business,
  'owners': instance.owners,
  'settlement': instance.settlement,
  'declarations': instance.declarations,
};

_MerchantBusinessInputDto _$MerchantBusinessInputDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantBusinessInputDto(
  legalName: json['legalName'] as String,
  businessTypeId: json['businessTypeId'] as String,
  registrationNumber: json['registrationNumber'] as String?,
  industryId: json['industryId'] as String,
  monthlySalesRangeId: json['monthlySalesRangeId'] as String,
  contactEmail: json['contactEmail'] as String,
  contactPhone: json['contactPhone'] as String,
);

Map<String, dynamic> _$MerchantBusinessInputDtoToJson(
  _MerchantBusinessInputDto instance,
) => <String, dynamic>{
  'legalName': instance.legalName,
  'businessTypeId': instance.businessTypeId,
  'registrationNumber': instance.registrationNumber,
  'industryId': instance.industryId,
  'monthlySalesRangeId': instance.monthlySalesRangeId,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
};

_MerchantOwnerInputDto _$MerchantOwnerInputDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantOwnerInputDto(
  ownerRowId: json['ownerRowId'] as String,
  fullName: json['fullName'] as String,
  roleId: json['roleId'] as String,
  ownershipBasisPoints: (json['ownershipBasisPoints'] as num?)?.toInt(),
  email: json['email'] as String,
  isPrimaryContact: json['isPrimaryContact'] as bool,
);

Map<String, dynamic> _$MerchantOwnerInputDtoToJson(
  _MerchantOwnerInputDto instance,
) => <String, dynamic>{
  'ownerRowId': instance.ownerRowId,
  'fullName': instance.fullName,
  'roleId': instance.roleId,
  'ownershipBasisPoints': instance.ownershipBasisPoints,
  'email': instance.email,
  'isPrimaryContact': instance.isPrimaryContact,
};

_MerchantSettlementInputDto _$MerchantSettlementInputDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantSettlementInputDto(
  bankId: json['bankId'] as String,
  accountHolderName: json['accountHolderName'] as String,
  accountNumber: json['accountNumber'] as String,
  holderTypeId: json['holderTypeId'] as String,
  ownerRowId: json['ownerRowId'] as String?,
  payoutScheduleId: json['payoutScheduleId'] as String,
);

Map<String, dynamic> _$MerchantSettlementInputDtoToJson(
  _MerchantSettlementInputDto instance,
) => <String, dynamic>{
  'bankId': instance.bankId,
  'accountHolderName': instance.accountHolderName,
  'accountNumber': instance.accountNumber,
  'holderTypeId': instance.holderTypeId,
  'ownerRowId': instance.ownerRowId,
  'payoutScheduleId': instance.payoutScheduleId,
};

_MerchantDeclarationsInputDto _$MerchantDeclarationsInputDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantDeclarationsInputDto(
  informationAccurate: json['informationAccurate'] as bool,
  authorizedToSubmit: json['authorizedToSubmit'] as bool,
  termsAccepted: json['termsAccepted'] as bool,
  termsVersion: json['termsVersion'] as String,
);

Map<String, dynamic> _$MerchantDeclarationsInputDtoToJson(
  _MerchantDeclarationsInputDto instance,
) => <String, dynamic>{
  'informationAccurate': instance.informationAccurate,
  'authorizedToSubmit': instance.authorizedToSubmit,
  'termsAccepted': instance.termsAccepted,
  'termsVersion': instance.termsVersion,
};

_MerchantSubmitResultDto _$MerchantSubmitResultDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantSubmitResultDto(
  applicationId: json['applicationId'] as String,
  submittedAt: json['submittedAt'] as String,
  settlement: json['settlement'] == null
      ? null
      : MerchantSubmitSettlementDto.fromJson(
          json['settlement'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MerchantSubmitResultDtoToJson(
  _MerchantSubmitResultDto instance,
) => <String, dynamic>{
  'applicationId': instance.applicationId,
  'submittedAt': instance.submittedAt,
  'settlement': instance.settlement,
};

_MerchantSubmitSettlementDto _$MerchantSubmitSettlementDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantSubmitSettlementDto(
  bankId: json['bankId'] as String,
  accountNumberLast4: json['accountNumberLast4'] as String,
);

Map<String, dynamic> _$MerchantSubmitSettlementDtoToJson(
  _MerchantSubmitSettlementDto instance,
) => <String, dynamic>{
  'bankId': instance.bankId,
  'accountNumberLast4': instance.accountNumberLast4,
};
