import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

class BankAccountNumber {
  const BankAccountNumber._(this.value);

  final String value;

  String get masked =>
      value.length <= 4 ? value : '****${value.substring(value.length - 4)}';

  static Either<MerchantValidationFailure, BankAccountNumber> create(
    String raw,
  ) {
    final value = raw.replaceAll(' ', '');
    if (value.isEmpty) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementAccountNumberRequired,
          path: 'settlement.accountNumber',
        ),
      );
    }
    if (!RegExp(r'^\d{6,24}$').hasMatch(value)) {
      return left(
        const MerchantValidationFailure(
          code: MerchantValidationCodes.settlementAccountNumberInvalid,
          path: 'settlement.accountNumber',
        ),
      );
    }
    return right(BankAccountNumber._(value));
  }
}
