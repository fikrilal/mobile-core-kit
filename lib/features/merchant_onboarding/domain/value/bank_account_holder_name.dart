import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/value/trimmed_name_validator.dart';

class BankAccountHolderName {
  const BankAccountHolderName._(this.value);

  final String value;

  static Either<MerchantValidationFailure, BankAccountHolderName> create(
    String raw,
  ) {
    final failure = validateTrimmedName(
      raw: raw,
      requiredCode: MerchantValidationCodes.settlementHolderNameRequired,
      invalidCode: MerchantValidationCodes.settlementHolderNameInvalid,
      path: 'settlement.accountHolderName',
    );
    if (failure != null) return left(failure);
    return right(BankAccountHolderName._(raw.trim()));
  }
}
