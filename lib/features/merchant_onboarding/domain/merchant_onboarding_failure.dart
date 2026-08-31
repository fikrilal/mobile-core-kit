import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

/// Failure taxonomy for the merchant-onboarding application boundary. Local
/// final-gate failures carry deterministic validation failures; remote-style
/// failures exist so the fake adapter and the later real integration share
/// one contract shape.
sealed class MerchantOnboardingFailure {
  const MerchantOnboardingFailure();
}

/// The submit use case rejected the raw input before any repository call.
final class MerchantLocalValidationFailure extends MerchantOnboardingFailure {
  const MerchantLocalValidationFailure(this.failures);

  final List<MerchantValidationFailure> failures;
}

/// The submission was accepted earlier; the idempotency key matched.
final class MerchantDuplicateApplicationFailure
    extends MerchantOnboardingFailure {
  const MerchantDuplicateApplicationFailure();
}

/// Reference ids used by the draft no longer exist in the server snapshot.
final class MerchantStaleReferenceFailure extends MerchantOnboardingFailure {
  const MerchantStaleReferenceFailure();
}

final class MerchantUnauthenticatedFailure extends MerchantOnboardingFailure {
  const MerchantUnauthenticatedFailure();
}

final class MerchantRetryableFailure extends MerchantOnboardingFailure {
  const MerchantRetryableFailure();
}

final class MerchantUnexpectedFailure extends MerchantOnboardingFailure {
  const MerchantUnexpectedFailure();
}
