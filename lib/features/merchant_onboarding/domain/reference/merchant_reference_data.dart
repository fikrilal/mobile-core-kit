import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

class ReferenceOption {
  const ReferenceOption({required this.id, required this.label});

  final String id;
  final String label;
}

class BusinessTypeOption {
  const BusinessTypeOption({
    required this.id,
    required this.label,
    required this.requiresRegistrationNumber,
  });

  final String id;
  final String label;
  final bool requiresRegistrationNumber;
}

class OwnerRoleOption {
  const OwnerRoleOption({
    required this.id,
    required this.label,
    required this.contributesOwnership,
  });

  final String id;
  final String label;
  final bool contributesOwnership;
}

class BankOption {
  BankOption({
    required this.id,
    required this.label,
    required Set<String> supportedScheduleIds,
  }) : supportedScheduleIds = Set.unmodifiable(supportedScheduleIds);

  final String id;
  final String label;
  final Set<String> supportedScheduleIds;
}

class AccountHolderTypeOption {
  const AccountHolderTypeOption({
    required this.id,
    required this.label,
    required this.requiresOwnerReference,
  });

  final String id;
  final String label;
  final bool requiresOwnerReference;
}

class MerchantReferenceData {
  MerchantReferenceData({
    required List<BusinessTypeOption> businessTypes,
    required List<ReferenceOption> industries,
    required List<ReferenceOption> monthlySalesRanges,
    required List<OwnerRoleOption> ownerRoles,
    required List<BankOption> banks,
    required List<AccountHolderTypeOption> holderTypes,
    required List<ReferenceOption> payoutSchedules,
    required this.termsVersion,
  }) : businessTypes = List.unmodifiable(businessTypes),
       industries = List.unmodifiable(industries),
       monthlySalesRanges = List.unmodifiable(monthlySalesRanges),
       ownerRoles = List.unmodifiable(ownerRoles),
       banks = List.unmodifiable(banks),
       holderTypes = List.unmodifiable(holderTypes),
       payoutSchedules = List.unmodifiable(payoutSchedules);

  final List<BusinessTypeOption> businessTypes;
  final List<ReferenceOption> industries;
  final List<ReferenceOption> monthlySalesRanges;
  final List<OwnerRoleOption> ownerRoles;
  final List<BankOption> banks;
  final List<AccountHolderTypeOption> holderTypes;
  final List<ReferenceOption> payoutSchedules;
  final String termsVersion;

  BusinessTypeOption? businessTypeById(String? id) =>
      id == null ? null : _single(businessTypes.where((o) => o.id == id));

  ReferenceOption? industryById(String? id) =>
      id == null ? null : _single(industries.where((o) => o.id == id));

  ReferenceOption? monthlySalesRangeById(String? id) =>
      id == null ? null : _single(monthlySalesRanges.where((o) => o.id == id));

  OwnerRoleOption? ownerRoleById(String? id) =>
      id == null ? null : _single(ownerRoles.where((o) => o.id == id));

  BankOption? bankById(String? id) =>
      id == null ? null : _single(banks.where((o) => o.id == id));

  AccountHolderTypeOption? holderTypeById(String? id) =>
      id == null ? null : _single(holderTypes.where((o) => o.id == id));

  ReferenceOption? payoutScheduleById(String? id) =>
      id == null ? null : _single(payoutSchedules.where((o) => o.id == id));

  bool industryExists(String? id) => industryById(id) != null;

  bool monthlySalesRangeExists(String? id) => monthlySalesRangeById(id) != null;

  bool payoutScheduleExists(String? id) => payoutScheduleById(id) != null;

  static T? _single<T>(Iterable<T> values) =>
      values.isEmpty ? null : values.first;
}

abstract class MerchantReferenceId {
  const MerchantReferenceId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MerchantReferenceId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class BusinessTypeId extends MerchantReferenceId {
  const BusinessTypeId._(super.value);

  static Either<MerchantValidationFailure, BusinessTypeId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeRequired,
          path: 'business.businessTypeId',
        ),
      );
    }
    if (reference.businessTypeById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessTypeUnsupported,
          path: 'business.businessTypeId',
        ),
      );
    }
    return right(BusinessTypeId._(id));
  }
}

class IndustryId extends MerchantReferenceId {
  const IndustryId._(super.value);

  static Either<MerchantValidationFailure, IndustryId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryRequired,
          path: 'business.industryId',
        ),
      );
    }
    if (!reference.industryExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessIndustryUnsupported,
          path: 'business.industryId',
        ),
      );
    }
    return right(IndustryId._(id));
  }
}

class MonthlySalesRangeId extends MerchantReferenceId {
  const MonthlySalesRangeId._(super.value);

  static Either<MerchantValidationFailure, MonthlySalesRangeId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeRequired,
          path: 'business.monthlySalesRangeId',
        ),
      );
    }
    if (!reference.monthlySalesRangeExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.businessSalesRangeUnsupported,
          path: 'business.monthlySalesRangeId',
        ),
      );
    }
    return right(MonthlySalesRangeId._(id));
  }
}

class OwnerRoleId extends MerchantReferenceId {
  const OwnerRoleId._(super.value);

  static Either<MerchantValidationFailure, OwnerRoleId> create(
    String? raw,
    MerchantReferenceData reference, {
    required String path,
  }) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerRoleRequired,
          path: path,
        ),
      );
    }
    if (reference.ownerRoleById(id) == null) {
      return left(
        MerchantValidationFailure(
          code: MerchantValidationCodes.ownerRoleUnsupported,
          path: path,
        ),
      );
    }
    return right(OwnerRoleId._(id));
  }
}

class BankId extends MerchantReferenceId {
  const BankId._(super.value);

  static Either<MerchantValidationFailure, BankId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankRequired,
          path: 'settlement.bankId',
        ),
      );
    }
    if (reference.bankById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementBankUnsupported,
          path: 'settlement.bankId',
        ),
      );
    }
    return right(BankId._(id));
  }
}

class AccountHolderTypeId extends MerchantReferenceId {
  const AccountHolderTypeId._(super.value);

  static Either<MerchantValidationFailure, AccountHolderTypeId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeRequired,
          path: 'settlement.holderTypeId',
        ),
      );
    }
    if (reference.holderTypeById(id) == null) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementHolderTypeUnsupported,
          path: 'settlement.holderTypeId',
        ),
      );
    }
    return right(AccountHolderTypeId._(id));
  }
}

class PayoutScheduleId extends MerchantReferenceId {
  const PayoutScheduleId._(super.value);

  static Either<MerchantValidationFailure, PayoutScheduleId> create(
    String? raw,
    MerchantReferenceData reference,
  ) {
    final id = raw?.trim() ?? '';
    if (id.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleRequired,
          path: 'settlement.payoutScheduleId',
        ),
      );
    }
    if (!reference.payoutScheduleExists(id)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementScheduleUnsupported,
          path: 'settlement.payoutScheduleId',
        ),
      );
    }
    return right(PayoutScheduleId._(id));
  }
}
