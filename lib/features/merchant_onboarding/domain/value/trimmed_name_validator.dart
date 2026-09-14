import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

MerchantValidationFailure? validateTrimmedName({
  required String raw,
  required String requiredCode,
  required String invalidCode,
  required String? path,
}) {
  final value = raw.trim();
  if (value.isEmpty) {
    return MerchantValidationFailure(code: requiredCode, path: path);
  }
  if (value.length < 2 || value.length > 100) {
    return MerchantValidationFailure(code: invalidCode, path: path);
  }
  return null;
}
