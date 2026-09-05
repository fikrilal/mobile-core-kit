import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/account_holder_type_option_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/bank_option_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/business_type_option_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/owner_role_option_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/reference_option_entity.dart';

export 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/account_holder_type_option_entity.dart';
export 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/bank_option_entity.dart';
export 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/business_type_option_entity.dart';
export 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/owner_role_option_entity.dart';
export 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/reference_option_entity.dart';

part 'merchant_reference_data_entity.freezed.dart';

@freezed
abstract class MerchantReferenceDataEntity with _$MerchantReferenceDataEntity {
  const factory MerchantReferenceDataEntity({
    required List<BusinessTypeOptionEntity> businessTypes,
    required List<ReferenceOptionEntity> industries,
    required List<ReferenceOptionEntity> monthlySalesRanges,
    required List<OwnerRoleOptionEntity> ownerRoles,
    required List<BankOptionEntity> banks,
    required List<AccountHolderTypeOptionEntity> holderTypes,
    required List<ReferenceOptionEntity> payoutSchedules,
    required String termsVersion,
  }) = _MerchantReferenceDataEntity;

  const MerchantReferenceDataEntity._();

  BusinessTypeOptionEntity? businessTypeById(String? id) =>
      id == null ? null : businessTypes.where((o) => o.id == id).firstOrNull;

  ReferenceOptionEntity? industryById(String? id) =>
      id == null ? null : industries.where((o) => o.id == id).firstOrNull;

  ReferenceOptionEntity? monthlySalesRangeById(String? id) => id == null
      ? null
      : monthlySalesRanges.where((o) => o.id == id).firstOrNull;

  OwnerRoleOptionEntity? ownerRoleById(String? id) =>
      id == null ? null : ownerRoles.where((o) => o.id == id).firstOrNull;

  BankOptionEntity? bankById(String? id) =>
      id == null ? null : banks.where((o) => o.id == id).firstOrNull;

  AccountHolderTypeOptionEntity? holderTypeById(String? id) =>
      id == null ? null : holderTypes.where((o) => o.id == id).firstOrNull;

  ReferenceOptionEntity? payoutScheduleById(String? id) =>
      id == null ? null : payoutSchedules.where((o) => o.id == id).firstOrNull;

  bool industryExists(String? id) => industryById(id) != null;

  bool monthlySalesRangeExists(String? id) => monthlySalesRangeById(id) != null;

  bool payoutScheduleExists(String? id) => payoutScheduleById(id) != null;
}
