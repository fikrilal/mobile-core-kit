// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_onboarding_submit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MerchantOnboardingSubmitRequestModel
_$MerchantOnboardingSubmitRequestModelFromJson(Map<String, dynamic> json) =>
    _MerchantOnboardingSubmitRequestModel(
      business: MerchantBusinessInputModel.fromJson(
        json['business'] as Map<String, dynamic>,
      ),
      owners: (json['owners'] as List<dynamic>)
          .map(
            (e) => MerchantOwnerInputModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      settlement: MerchantSettlementInputModel.fromJson(
        json['settlement'] as Map<String, dynamic>,
      ),
      declarations: MerchantDeclarationsInputModel.fromJson(
        json['declarations'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MerchantOnboardingSubmitRequestModelToJson(
  _MerchantOnboardingSubmitRequestModel instance,
) => <String, dynamic>{
  'business': instance.business,
  'owners': instance.owners,
  'settlement': instance.settlement,
  'declarations': instance.declarations,
};

_MerchantBusinessInputModel _$MerchantBusinessInputModelFromJson(
  Map<String, dynamic> json,
) => _MerchantBusinessInputModel(
  legalName: json['legalName'] as String,
  businessTypeId: json['businessTypeId'] as String,
  registrationNumber: json['registrationNumber'] as String?,
  industryId: json['industryId'] as String,
  monthlySalesRangeId: json['monthlySalesRangeId'] as String,
  contactEmail: json['contactEmail'] as String,
  contactPhone: json['contactPhone'] as String,
);

Map<String, dynamic> _$MerchantBusinessInputModelToJson(
  _MerchantBusinessInputModel instance,
) => <String, dynamic>{
  'legalName': instance.legalName,
  'businessTypeId': instance.businessTypeId,
  'registrationNumber': instance.registrationNumber,
  'industryId': instance.industryId,
  'monthlySalesRangeId': instance.monthlySalesRangeId,
  'contactEmail': instance.contactEmail,
  'contactPhone': instance.contactPhone,
};

_MerchantOwnerInputModel _$MerchantOwnerInputModelFromJson(
  Map<String, dynamic> json,
) => _MerchantOwnerInputModel(
  ownerRowId: json['ownerRowId'] as String,
  fullName: json['fullName'] as String,
  roleId: json['roleId'] as String,
  ownershipBasisPoints: (json['ownershipBasisPoints'] as num?)?.toInt(),
  email: json['email'] as String,
  isPrimaryContact: json['isPrimaryContact'] as bool,
);

Map<String, dynamic> _$MerchantOwnerInputModelToJson(
  _MerchantOwnerInputModel instance,
) => <String, dynamic>{
  'ownerRowId': instance.ownerRowId,
  'fullName': instance.fullName,
  'roleId': instance.roleId,
  'ownershipBasisPoints': instance.ownershipBasisPoints,
  'email': instance.email,
  'isPrimaryContact': instance.isPrimaryContact,
};

_MerchantSettlementInputModel _$MerchantSettlementInputModelFromJson(
  Map<String, dynamic> json,
) => _MerchantSettlementInputModel(
  bankId: json['bankId'] as String,
  accountHolderName: json['accountHolderName'] as String,
  accountNumber: json['accountNumber'] as String,
  holderTypeId: json['holderTypeId'] as String,
  ownerRowId: json['ownerRowId'] as String?,
  payoutScheduleId: json['payoutScheduleId'] as String,
);

Map<String, dynamic> _$MerchantSettlementInputModelToJson(
  _MerchantSettlementInputModel instance,
) => <String, dynamic>{
  'bankId': instance.bankId,
  'accountHolderName': instance.accountHolderName,
  'accountNumber': instance.accountNumber,
  'holderTypeId': instance.holderTypeId,
  'ownerRowId': instance.ownerRowId,
  'payoutScheduleId': instance.payoutScheduleId,
};

_MerchantDeclarationsInputModel _$MerchantDeclarationsInputModelFromJson(
  Map<String, dynamic> json,
) => _MerchantDeclarationsInputModel(
  informationAccurate: json['informationAccurate'] as bool,
  authorizedToSubmit: json['authorizedToSubmit'] as bool,
  termsAccepted: json['termsAccepted'] as bool,
  termsVersion: json['termsVersion'] as String,
);

Map<String, dynamic> _$MerchantDeclarationsInputModelToJson(
  _MerchantDeclarationsInputModel instance,
) => <String, dynamic>{
  'informationAccurate': instance.informationAccurate,
  'authorizedToSubmit': instance.authorizedToSubmit,
  'termsAccepted': instance.termsAccepted,
  'termsVersion': instance.termsVersion,
};

_MerchantSubmitResultModel _$MerchantSubmitResultModelFromJson(
  Map<String, dynamic> json,
) => _MerchantSubmitResultModel(
  applicationId: json['applicationId'] as String,
  submittedAt: json['submittedAt'] as String,
  settlement: json['settlement'] == null
      ? null
      : MerchantSubmitSettlementModel.fromJson(
          json['settlement'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MerchantSubmitResultModelToJson(
  _MerchantSubmitResultModel instance,
) => <String, dynamic>{
  'applicationId': instance.applicationId,
  'submittedAt': instance.submittedAt,
  'settlement': instance.settlement,
};

_MerchantSubmitSettlementModel _$MerchantSubmitSettlementModelFromJson(
  Map<String, dynamic> json,
) => _MerchantSubmitSettlementModel(
  bankId: json['bankId'] as String,
  accountNumberLast4: json['accountNumberLast4'] as String,
);

Map<String, dynamic> _$MerchantSubmitSettlementModelToJson(
  _MerchantSubmitSettlementModel instance,
) => <String, dynamic>{
  'bankId': instance.bankId,
  'accountNumberLast4': instance.accountNumberLast4,
};
