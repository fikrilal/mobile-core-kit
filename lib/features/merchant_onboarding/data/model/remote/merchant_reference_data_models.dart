import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';

part 'merchant_reference_data_models.freezed.dart';
part 'merchant_reference_data_models.g.dart';

@freezed
abstract class MerchantReferenceDataModel with _$MerchantReferenceDataModel {
  const factory MerchantReferenceDataModel({
    required List<MerchantBusinessTypeOptionModel> businessTypes,
    required List<MerchantLabeledOptionModel> industries,
    required List<MerchantLabeledOptionModel> monthlySalesRanges,
    required List<MerchantOwnerRoleOptionModel> ownerRoles,
    required List<MerchantBankOptionModel> banks,
    required List<MerchantAccountHolderTypeOptionModel> accountHolderTypes,
    required List<MerchantLabeledOptionModel> payoutSchedules,
    required String termsVersion,
  }) = _MerchantReferenceDataModel;

  const MerchantReferenceDataModel._();

  factory MerchantReferenceDataModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantReferenceDataModelFromJson(json);

  MerchantReferenceDataEntity toDomain() {
    return MerchantReferenceDataEntity(
      businessTypes: [
        for (final option in businessTypes)
          BusinessTypeOptionEntity(
            id: option.id,
            label: option.label,
            requiresRegistrationNumber: option.requiresRegistrationNumber,
          ),
      ],
      industries: [
        for (final option in industries)
          ReferenceOptionEntity(id: option.id, label: option.label),
      ],
      monthlySalesRanges: [
        for (final option in monthlySalesRanges)
          ReferenceOptionEntity(id: option.id, label: option.label),
      ],
      ownerRoles: [
        for (final option in ownerRoles)
          OwnerRoleOptionEntity(
            id: option.id,
            label: option.label,
            contributesOwnership: option.contributesOwnership,
          ),
      ],
      banks: [
        for (final option in banks)
          BankOptionEntity(
            id: option.id,
            label: option.label,
            supportedScheduleIds: option.supportedPayoutScheduleIds.toSet(),
          ),
      ],
      holderTypes: [
        for (final option in accountHolderTypes)
          AccountHolderTypeOptionEntity(
            id: option.id,
            label: option.label,
            requiresOwnerReference: option.requiresOwnerReference,
          ),
      ],
      payoutSchedules: [
        for (final option in payoutSchedules)
          ReferenceOptionEntity(id: option.id, label: option.label),
      ],
      termsVersion: termsVersion,
    );
  }
}

@freezed
abstract class MerchantBusinessTypeOptionModel
    with _$MerchantBusinessTypeOptionModel {
  const factory MerchantBusinessTypeOptionModel({
    required String id,
    required String label,
    required bool requiresRegistrationNumber,
  }) = _MerchantBusinessTypeOptionModel;

  factory MerchantBusinessTypeOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantBusinessTypeOptionModelFromJson(json);
}

@freezed
abstract class MerchantLabeledOptionModel with _$MerchantLabeledOptionModel {
  const factory MerchantLabeledOptionModel({
    required String id,
    required String label,
  }) = _MerchantLabeledOptionModel;

  factory MerchantLabeledOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantLabeledOptionModelFromJson(json);
}

@freezed
abstract class MerchantOwnerRoleOptionModel
    with _$MerchantOwnerRoleOptionModel {
  const factory MerchantOwnerRoleOptionModel({
    required String id,
    required String label,
    required bool contributesOwnership,
  }) = _MerchantOwnerRoleOptionModel;

  factory MerchantOwnerRoleOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantOwnerRoleOptionModelFromJson(json);
}

@freezed
abstract class MerchantBankOptionModel with _$MerchantBankOptionModel {
  const factory MerchantBankOptionModel({
    required String id,
    required String label,
    required List<String> supportedPayoutScheduleIds,
  }) = _MerchantBankOptionModel;

  factory MerchantBankOptionModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantBankOptionModelFromJson(json);
}

@freezed
abstract class MerchantAccountHolderTypeOptionModel
    with _$MerchantAccountHolderTypeOptionModel {
  const factory MerchantAccountHolderTypeOptionModel({
    required String id,
    required String label,
    required bool requiresOwnerReference,
  }) = _MerchantAccountHolderTypeOptionModel;

  factory MerchantAccountHolderTypeOptionModel.fromJson(
    Map<String, dynamic> json,
  ) => _$MerchantAccountHolderTypeOptionModelFromJson(json);
}
