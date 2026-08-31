// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_reference_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MerchantReferenceDataDto _$MerchantReferenceDataDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantReferenceDataDto(
  businessTypes: (json['businessTypes'] as List<dynamic>)
      .map(
        (e) =>
            MerchantBusinessTypeOptionDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  industries: (json['industries'] as List<dynamic>)
      .map((e) => MerchantLabeledOptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  monthlySalesRanges: (json['monthlySalesRanges'] as List<dynamic>)
      .map((e) => MerchantLabeledOptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  ownerRoles: (json['ownerRoles'] as List<dynamic>)
      .map(
        (e) => MerchantOwnerRoleOptionDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  banks: (json['banks'] as List<dynamic>)
      .map((e) => MerchantBankOptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  accountHolderTypes: (json['accountHolderTypes'] as List<dynamic>)
      .map(
        (e) => MerchantAccountHolderTypeOptionDto.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  payoutSchedules: (json['payoutSchedules'] as List<dynamic>)
      .map((e) => MerchantLabeledOptionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  termsVersion: json['termsVersion'] as String,
);

Map<String, dynamic> _$MerchantReferenceDataDtoToJson(
  _MerchantReferenceDataDto instance,
) => <String, dynamic>{
  'businessTypes': instance.businessTypes,
  'industries': instance.industries,
  'monthlySalesRanges': instance.monthlySalesRanges,
  'ownerRoles': instance.ownerRoles,
  'banks': instance.banks,
  'accountHolderTypes': instance.accountHolderTypes,
  'payoutSchedules': instance.payoutSchedules,
  'termsVersion': instance.termsVersion,
};

_MerchantBusinessTypeOptionDto _$MerchantBusinessTypeOptionDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantBusinessTypeOptionDto(
  id: json['id'] as String,
  label: json['label'] as String,
  requiresRegistrationNumber: json['requiresRegistrationNumber'] as bool,
);

Map<String, dynamic> _$MerchantBusinessTypeOptionDtoToJson(
  _MerchantBusinessTypeOptionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'requiresRegistrationNumber': instance.requiresRegistrationNumber,
};

_MerchantLabeledOptionDto _$MerchantLabeledOptionDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantLabeledOptionDto(
  id: json['id'] as String,
  label: json['label'] as String,
);

Map<String, dynamic> _$MerchantLabeledOptionDtoToJson(
  _MerchantLabeledOptionDto instance,
) => <String, dynamic>{'id': instance.id, 'label': instance.label};

_MerchantOwnerRoleOptionDto _$MerchantOwnerRoleOptionDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantOwnerRoleOptionDto(
  id: json['id'] as String,
  label: json['label'] as String,
  contributesOwnership: json['contributesOwnership'] as bool,
);

Map<String, dynamic> _$MerchantOwnerRoleOptionDtoToJson(
  _MerchantOwnerRoleOptionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'contributesOwnership': instance.contributesOwnership,
};

_MerchantBankOptionDto _$MerchantBankOptionDtoFromJson(
  Map<String, dynamic> json,
) => _MerchantBankOptionDto(
  id: json['id'] as String,
  label: json['label'] as String,
  supportedPayoutScheduleIds:
      (json['supportedPayoutScheduleIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$MerchantBankOptionDtoToJson(
  _MerchantBankOptionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'supportedPayoutScheduleIds': instance.supportedPayoutScheduleIds,
};

_MerchantAccountHolderTypeOptionDto
_$MerchantAccountHolderTypeOptionDtoFromJson(Map<String, dynamic> json) =>
    _MerchantAccountHolderTypeOptionDto(
      id: json['id'] as String,
      label: json['label'] as String,
      requiresOwnerReference: json['requiresOwnerReference'] as bool,
    );

Map<String, dynamic> _$MerchantAccountHolderTypeOptionDtoToJson(
  _MerchantAccountHolderTypeOptionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'requiresOwnerReference': instance.requiresOwnerReference,
};
