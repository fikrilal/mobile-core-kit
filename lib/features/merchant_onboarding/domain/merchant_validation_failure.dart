/// A deterministic, framework-free validation failure with a stable machine
/// code and an optional form path such as `business.legalName` or
/// `owners.<ownerRowId>.email`.
class MerchantValidationFailure {
  const MerchantValidationFailure({required this.code, this.path});

  final String code;
  final String? path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MerchantValidationFailure &&
          other.code == code &&
          other.path == path;

  @override
  int get hashCode => Object.hash(code, path);

  @override
  String toString() => 'MerchantValidationFailure($code, $path)';
}

/// Stable demo validation codes. Paths follow the blueprint:
/// step field order first, then owner row order, then aggregate-level paths.
abstract final class MerchantValidationCodes {
  // Step 1 — business profile.
  static const businessLegalNameRequired = 'business.legal_name.required';
  static const businessLegalNameInvalid = 'business.legal_name.invalid';
  static const businessTypeRequired = 'business.type.required';
  static const businessTypeUnsupported = 'business.type.unsupported';
  static const businessRegistrationRequired = 'business.registration.required';
  static const businessRegistrationInvalid = 'business.registration.invalid';
  static const businessIndustryRequired = 'business.industry.required';
  static const businessIndustryUnsupported = 'business.industry.unsupported';
  static const businessSalesRangeRequired = 'business.sales_range.required';
  static const businessSalesRangeUnsupported =
      'business.sales_range.unsupported';
  static const contactEmailRequired = 'contact.email.required';
  static const contactEmailInvalid = 'contact.email.invalid';
  static const contactPhoneRequired = 'contact.phone.required';
  static const contactPhoneInvalid = 'contact.phone.invalid';

  // Step 2 — owners.
  static const ownersRequired = 'owners.required';
  static const ownersLimitExceeded = 'owners.limit.exceeded';
  static const ownerNameRequired = 'owner.name.required';
  static const ownerNameInvalid = 'owner.name.invalid';
  static const ownerRoleRequired = 'owner.role.required';
  static const ownerRoleUnsupported = 'owner.role.unsupported';
  static const ownerPercentageRequired = 'owner.percentage.required';
  static const ownerPercentageNotAllowed = 'owner.percentage.not_allowed';
  static const ownerPercentageInvalid = 'owner.percentage.invalid';
  static const ownerEmailRequired = 'owner.email.required';
  static const ownerEmailInvalid = 'owner.email.invalid';
  static const ownersEmailDuplicate = 'owners.email.duplicate';
  static const ownersRowIdDuplicate = 'owners.row_id.duplicate';
  static const ownersPrimaryInvalid = 'owners.primary.invalid';
  static const ownersTotalInvalid = 'owners.total.invalid';

  // Step 3 — settlement.
  static const settlementBankRequired = 'settlement.bank.required';
  static const settlementBankUnsupported = 'settlement.bank.unsupported';
  static const settlementHolderNameRequired =
      'settlement.account_holder_name.required';
  static const settlementHolderNameInvalid =
      'settlement.account_holder_name.invalid';
  static const settlementAccountNumberRequired =
      'settlement.account_number.required';
  static const settlementAccountNumberInvalid =
      'settlement.account_number.invalid';
  static const settlementHolderTypeRequired = 'settlement.holder_type.required';
  static const settlementHolderTypeUnsupported =
      'settlement.holder_type.unsupported';
  static const settlementOwnerRequired = 'settlement.owner.required';
  static const settlementOwnerUnknown = 'settlement.owner.unknown';
  static const settlementOwnerNotAllowed = 'settlement.owner.not_allowed';
  static const settlementScheduleRequired = 'settlement.schedule.required';
  static const settlementScheduleUnsupported =
      'settlement.schedule.unsupported';
  static const settlementScheduleUnsupportedByBank =
      'settlement.schedule.unsupported_by_bank';

  // Step 4 — declarations.
  static const declarationsInformationAccurateRequired =
      'declarations.information_accurate.required';
  static const declarationsAuthorizedToSubmitRequired =
      'declarations.authorized_to_submit.required';
  static const declarationsTermsAcceptedRequired =
      'declarations.terms_accepted.required';
  static const declarationsTermsVersionStale =
      'declarations.terms_version.stale';

  // Form-level.
  static const referenceUnavailable = 'reference.unavailable';
}
