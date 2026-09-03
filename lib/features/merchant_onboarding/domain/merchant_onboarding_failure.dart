import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

sealed class MerchantOnboardingFailure {
  const MerchantOnboardingFailure();
}

final class MerchantLocalValidationFailure extends MerchantOnboardingFailure {
  const MerchantLocalValidationFailure(this.failures);

  final List<MerchantValidationFailure> failures;
}

final class MerchantServerValidationFailure extends MerchantOnboardingFailure {
  const MerchantServerValidationFailure(this.failures);

  final List<MerchantValidationFailure> failures;
}

final class MerchantDuplicateApplicationFailure
    extends MerchantOnboardingFailure {
  const MerchantDuplicateApplicationFailure();
}

final class MerchantRegistrationConflictFailure
    extends MerchantOnboardingFailure {
  const MerchantRegistrationConflictFailure();
}

final class MerchantStaleReferenceFailure extends MerchantOnboardingFailure {
  const MerchantStaleReferenceFailure();
}

final class MerchantStaleTermsFailure extends MerchantOnboardingFailure {
  const MerchantStaleTermsFailure();
}

final class MerchantUnauthenticatedFailure extends MerchantOnboardingFailure {
  const MerchantUnauthenticatedFailure();
}

final class MerchantIdempotencyInProgressFailure
    extends MerchantOnboardingFailure {
  const MerchantIdempotencyInProgressFailure();
}

final class MerchantRetryableFailure extends MerchantOnboardingFailure {
  const MerchantRetryableFailure();
}

final class MerchantUnexpectedFailure extends MerchantOnboardingFailure {
  const MerchantUnexpectedFailure();
}
