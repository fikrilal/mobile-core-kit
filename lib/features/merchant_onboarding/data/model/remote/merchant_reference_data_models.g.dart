// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_reference_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MerchantReferenceDataModel _$MerchantReferenceDataModelFromJson(
  Map<String, dynamic> json,
) => _MerchantReferenceDataModel(
  businessTypes: (json['businessTypes'] as List<dynamic>)
      .map(
        (e) =>
            MerchantBusinessTypeOptionModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  industries: (json['industries'] as List<dynamic>)
      .map(
        (e) => MerchantLabeledOptionModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  monthlySalesRanges: (json['monthlySalesRanges'] as List<dynamic>)
      .map(
        (e) => MerchantLabeledOptionModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  ownerRoles: (json['ownerRoles'] as List<dynamic>)
      .map(
        (e) => MerchantOwnerRoleOptionModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  banks: (json['banks'] as List<dynamic>)
      .map((e) => MerchantBankOptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  accountHolderTypes: (json['accountHolderTypes'] as List<dynamic>)
      .map(
        (e) => MerchantAccountHolderTypeOptionModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  payoutSchedules: (json['payoutSchedules'] as List<dynamic>)
      .map(
        (e) => MerchantLabeledOptionModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  termsVersion: json['termsVersion'] as String,
);

Map<String, dynamic> _$MerchantReferenceDataModelToJson(
  _MerchantReferenceDataModel instance,
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

_MerchantBusinessTypeOptionModel _$MerchantBusinessTypeOptionModelFromJson(
  Map<String, dynamic> json,
) => _MerchantBusinessTypeOptionModel(
  id: json['id'] as String,
  label: json['label'] as String,
  requiresRegistrationNumber: json['requiresRegistrationNumber'] as bool,
);

Map<String, dynamic> _$MerchantBusinessTypeOptionModelToJson(
  _MerchantBusinessTypeOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'requiresRegistrationNumber': instance.requiresRegistrationNumber,
};

_MerchantLabeledOptionModel _$MerchantLabeledOptionModelFromJson(
  Map<String, dynamic> json,
) => _MerchantLabeledOptionModel(
  id: json['id'] as String,
  label: json['label'] as String,
);

Map<String, dynamic> _$MerchantLabeledOptionModelToJson(
  _MerchantLabeledOptionModel instance,
) => <String, dynamic>{'id': instance.id, 'label': instance.label};

_MerchantOwnerRoleOptionModel _$MerchantOwnerRoleOptionModelFromJson(
  Map<String, dynamic> json,
) => _MerchantOwnerRoleOptionModel(
  id: json['id'] as String,
  label: json['label'] as String,
  contributesOwnership: json['contributesOwnership'] as bool,
);

Map<String, dynamic> _$MerchantOwnerRoleOptionModelToJson(
  _MerchantOwnerRoleOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'contributesOwnership': instance.contributesOwnership,
};

_MerchantBankOptionModel _$MerchantBankOptionModelFromJson(
  Map<String, dynamic> json,
) => _MerchantBankOptionModel(
  id: json['id'] as String,
  label: json['label'] as String,
  supportedPayoutScheduleIds:
      (json['supportedPayoutScheduleIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$MerchantBankOptionModelToJson(
  _MerchantBankOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'supportedPayoutScheduleIds': instance.supportedPayoutScheduleIds,
};

_MerchantAccountHolderTypeOptionModel
_$MerchantAccountHolderTypeOptionModelFromJson(Map<String, dynamic> json) =>
    _MerchantAccountHolderTypeOptionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      requiresOwnerReference: json['requiresOwnerReference'] as bool,
    );

Map<String, dynamic> _$MerchantAccountHolderTypeOptionModelToJson(
  _MerchantAccountHolderTypeOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'requiresOwnerReference': instance.requiresOwnerReference,
};
