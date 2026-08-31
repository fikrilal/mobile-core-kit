import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/l10n/gen/app_localizations.dart';

/// Maps deterministic merchant-onboarding failure codes to localized
/// messages. Unknown codes fall back to a generic form-level message.
String messageForMerchantValidationFailure(
  MerchantValidationFailure failure,
  AppLocalizations l10n,
) {
  return switch (failure.code) {
    MerchantValidationCodes.businessLegalNameRequired =>
      l10n.merchantOnboardingErrorBusinessLegalNameRequired,
    MerchantValidationCodes.businessLegalNameInvalid =>
      l10n.merchantOnboardingErrorBusinessLegalNameInvalid,
    MerchantValidationCodes.businessTypeRequired =>
      l10n.merchantOnboardingErrorBusinessTypeRequired,
    MerchantValidationCodes.businessTypeUnsupported =>
      l10n.merchantOnboardingErrorBusinessTypeUnsupported,
    MerchantValidationCodes.businessRegistrationRequired =>
      l10n.merchantOnboardingErrorBusinessRegistrationRequired,
    MerchantValidationCodes.businessRegistrationInvalid =>
      l10n.merchantOnboardingErrorBusinessRegistrationInvalid,
    MerchantValidationCodes.businessIndustryRequired =>
      l10n.merchantOnboardingErrorBusinessIndustryRequired,
    MerchantValidationCodes.businessIndustryUnsupported =>
      l10n.merchantOnboardingErrorBusinessIndustryUnsupported,
    MerchantValidationCodes.businessSalesRangeRequired =>
      l10n.merchantOnboardingErrorBusinessSalesRangeRequired,
    MerchantValidationCodes.businessSalesRangeUnsupported =>
      l10n.merchantOnboardingErrorBusinessSalesRangeUnsupported,
    MerchantValidationCodes.contactEmailRequired =>
      l10n.merchantOnboardingErrorContactEmailRequired,
    MerchantValidationCodes.contactEmailInvalid =>
      l10n.merchantOnboardingErrorContactEmailInvalid,
    MerchantValidationCodes.contactPhoneRequired =>
      l10n.merchantOnboardingErrorContactPhoneRequired,
    MerchantValidationCodes.contactPhoneInvalid =>
      l10n.merchantOnboardingErrorContactPhoneInvalid,
    MerchantValidationCodes.ownersRequired =>
      l10n.merchantOnboardingErrorOwnersRequired,
    MerchantValidationCodes.ownersLimitExceeded =>
      l10n.merchantOnboardingErrorOwnersLimitExceeded,
    MerchantValidationCodes.ownerNameRequired =>
      l10n.merchantOnboardingErrorOwnerNameRequired,
    MerchantValidationCodes.ownerNameInvalid =>
      l10n.merchantOnboardingErrorOwnerNameInvalid,
    MerchantValidationCodes.ownerRoleRequired =>
      l10n.merchantOnboardingErrorOwnerRoleRequired,
    MerchantValidationCodes.ownerRoleUnsupported =>
      l10n.merchantOnboardingErrorOwnerRoleUnsupported,
    MerchantValidationCodes.ownerPercentageRequired =>
      l10n.merchantOnboardingErrorOwnerPercentageRequired,
    MerchantValidationCodes.ownerPercentageNotAllowed =>
      l10n.merchantOnboardingErrorOwnerPercentageNotAllowed,
    MerchantValidationCodes.ownerPercentageInvalid =>
      l10n.merchantOnboardingErrorOwnerPercentageInvalid,
    MerchantValidationCodes.ownerEmailRequired =>
      l10n.merchantOnboardingErrorOwnerEmailRequired,
    MerchantValidationCodes.ownerEmailInvalid =>
      l10n.merchantOnboardingErrorOwnerEmailInvalid,
    MerchantValidationCodes.ownersEmailDuplicate =>
      l10n.merchantOnboardingErrorOwnersEmailDuplicate,
    MerchantValidationCodes.ownersPrimaryInvalid =>
      l10n.merchantOnboardingErrorOwnersPrimaryInvalid,
    MerchantValidationCodes.ownersTotalInvalid =>
      l10n.merchantOnboardingErrorOwnersTotalInvalid,
    MerchantValidationCodes.settlementBankRequired =>
      l10n.merchantOnboardingErrorSettlementBankRequired,
    MerchantValidationCodes.settlementBankUnsupported =>
      l10n.merchantOnboardingErrorSettlementBankUnsupported,
    MerchantValidationCodes.settlementHolderNameRequired =>
      l10n.merchantOnboardingErrorSettlementHolderNameRequired,
    MerchantValidationCodes.settlementHolderNameInvalid =>
      l10n.merchantOnboardingErrorSettlementHolderNameInvalid,
    MerchantValidationCodes.settlementAccountNumberRequired =>
      l10n.merchantOnboardingErrorSettlementAccountNumberRequired,
    MerchantValidationCodes.settlementAccountNumberInvalid =>
      l10n.merchantOnboardingErrorSettlementAccountNumberInvalid,
    MerchantValidationCodes.settlementHolderTypeRequired =>
      l10n.merchantOnboardingErrorSettlementHolderTypeRequired,
    MerchantValidationCodes.settlementHolderTypeUnsupported =>
      l10n.merchantOnboardingErrorSettlementHolderTypeUnsupported,
    MerchantValidationCodes.settlementOwnerRequired =>
      l10n.merchantOnboardingErrorSettlementOwnerRequired,
    MerchantValidationCodes.settlementOwnerUnknown =>
      l10n.merchantOnboardingErrorSettlementOwnerUnknown,
    MerchantValidationCodes.settlementOwnerNotAllowed =>
      l10n.merchantOnboardingErrorSettlementOwnerNotAllowed,
    MerchantValidationCodes.settlementScheduleRequired =>
      l10n.merchantOnboardingErrorSettlementScheduleRequired,
    MerchantValidationCodes.settlementScheduleUnsupported =>
      l10n.merchantOnboardingErrorSettlementScheduleUnsupported,
    MerchantValidationCodes.settlementScheduleUnsupportedByBank =>
      l10n.merchantOnboardingErrorSettlementScheduleUnsupportedByBank,
    MerchantValidationCodes.declarationsInformationAccurateRequired =>
      l10n.merchantOnboardingErrorDeclarationsInformationAccurateRequired,
    MerchantValidationCodes.declarationsAuthorizedToSubmitRequired =>
      l10n.merchantOnboardingErrorDeclarationsAuthorizedToSubmitRequired,
    MerchantValidationCodes.declarationsTermsAcceptedRequired =>
      l10n.merchantOnboardingErrorDeclarationsTermsAcceptedRequired,
    MerchantValidationCodes.declarationsTermsVersionStale =>
      l10n.merchantOnboardingErrorDeclarationsTermsVersionStale,
    _ => l10n.merchantOnboardingSubmitFailure,
  };
}
