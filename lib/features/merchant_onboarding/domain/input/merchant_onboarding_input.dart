/// Raw, incomplete, and possibly inconsistent draft input for the whole
/// merchant-onboarding flow. This type claims no domain validity; the
/// validated aggregates own that transition.
class MerchantOnboardingInput {
  MerchantOnboardingInput({
    this.business = const BusinessProfileInput(),
    List<OwnerInput>? owners,
    this.settlement = const SettlementInput(),
    this.declarations = const DeclarationsInput(),
  }) : owners = List.unmodifiable(owners ?? const []);

  final BusinessProfileInput business;
  final List<OwnerInput> owners;
  final SettlementInput settlement;
  final DeclarationsInput declarations;

  MerchantOnboardingInput copyWith({
    BusinessProfileInput? business,
    List<OwnerInput>? owners,
    SettlementInput? settlement,
    DeclarationsInput? declarations,
  }) {
    return MerchantOnboardingInput(
      business: business ?? this.business,
      owners: owners ?? this.owners,
      settlement: settlement ?? this.settlement,
      declarations: declarations ?? this.declarations,
    );
  }
}

class BusinessProfileInput {
  const BusinessProfileInput({
    this.legalName = '',
    this.businessTypeId,
    this.registrationNumber = '',
    this.industryId,
    this.monthlySalesRangeId,
    this.contactEmail = '',
    this.contactPhone = '',
  });

  final String legalName;
  final String? businessTypeId;
  final String registrationNumber;
  final String? industryId;
  final String? monthlySalesRangeId;
  final String contactEmail;
  final String contactPhone;

  BusinessProfileInput copyWith({
    String? legalName,
    String? businessTypeId,
    bool clearBusinessTypeId = false,
    String? registrationNumber,
    String? industryId,
    bool clearIndustryId = false,
    String? monthlySalesRangeId,
    bool clearMonthlySalesRangeId = false,
    String? contactEmail,
    String? contactPhone,
  }) {
    return BusinessProfileInput(
      legalName: legalName ?? this.legalName,
      businessTypeId: clearBusinessTypeId
          ? null
          : (businessTypeId ?? this.businessTypeId),
      registrationNumber: registrationNumber ?? this.registrationNumber,
      industryId: clearIndustryId ? null : (industryId ?? this.industryId),
      monthlySalesRangeId: clearMonthlySalesRangeId
          ? null
          : (monthlySalesRangeId ?? this.monthlySalesRangeId),
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}

/// One owners-step row. [ownerRowId] is generated when the row is added and
/// must survive edits, reordering, and deletion of other rows.
class OwnerInput {
  const OwnerInput({
    required this.ownerRowId,
    this.fullName = '',
    this.roleId,
    this.ownershipPercentage = '',
    this.email = '',
    this.isPrimaryContact = false,
  });

  final String ownerRowId;
  final String fullName;
  final String? roleId;
  final String ownershipPercentage;
  final String email;
  final bool isPrimaryContact;

  OwnerInput copyWith({
    String? fullName,
    String? roleId,
    bool clearRoleId = false,
    String? ownershipPercentage,
    bool clearOwnershipPercentage = false,
    String? email,
    bool? isPrimaryContact,
  }) {
    return OwnerInput(
      ownerRowId: ownerRowId,
      fullName: fullName ?? this.fullName,
      roleId: clearRoleId ? null : (roleId ?? this.roleId),
      ownershipPercentage: clearOwnershipPercentage
          ? ''
          : (ownershipPercentage ?? this.ownershipPercentage),
      email: email ?? this.email,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
    );
  }
}

class SettlementInput {
  const SettlementInput({
    this.bankId,
    this.accountHolderName = '',
    this.accountNumber = '',
    this.holderTypeId,
    this.ownerRowId,
    this.payoutScheduleId,
  });

  final String? bankId;
  final String accountHolderName;
  final String accountNumber;
  final String? holderTypeId;
  final String? ownerRowId;
  final String? payoutScheduleId;

  SettlementInput copyWith({
    String? bankId,
    bool clearBankId = false,
    String? accountHolderName,
    String? accountNumber,
    String? holderTypeId,
    bool clearHolderTypeId = false,
    String? ownerRowId,
    bool clearOwnerRowId = false,
    String? payoutScheduleId,
    bool clearPayoutScheduleId = false,
  }) {
    return SettlementInput(
      bankId: clearBankId ? null : (bankId ?? this.bankId),
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      holderTypeId: clearHolderTypeId
          ? null
          : (holderTypeId ?? this.holderTypeId),
      ownerRowId: clearOwnerRowId ? null : (ownerRowId ?? this.ownerRowId),
      payoutScheduleId: clearPayoutScheduleId
          ? null
          : (payoutScheduleId ?? this.payoutScheduleId),
    );
  }
}

class DeclarationsInput {
  const DeclarationsInput({
    this.informationAccurate = false,
    this.authorizedToSubmit = false,
    this.termsAccepted = false,
    this.termsVersion = '',
  });

  final bool informationAccurate;
  final bool authorizedToSubmit;
  final bool termsAccepted;

  /// The terms version the user accepted; must equal the snapshot version.
  final String termsVersion;

  DeclarationsInput copyWith({
    bool? informationAccurate,
    bool? authorizedToSubmit,
    bool? termsAccepted,
    String? termsVersion,
  }) {
    return DeclarationsInput(
      informationAccurate: informationAccurate ?? this.informationAccurate,
      authorizedToSubmit: authorizedToSubmit ?? this.authorizedToSubmit,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsVersion: termsVersion ?? this.termsVersion,
    );
  }
}
