import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';

/// Failure taxonomy for the merchant-onboarding application boundary. Local
/// final-gate failures carry deterministic validation failures; remote
/// failures map the accepted backend error codes into safe domain outcomes.
sealed class MerchantOnboardingFailure {
  const MerchantOnboardingFailure();
}

/// The submit use case rejected the raw input before any repository call.
final class MerchantLocalValidationFailure extends MerchantOnboardingFailure {
  const MerchantLocalValidationFailure(this.failures);

  final List<MerchantValidationFailure> failures;
}

/// Server field validation with recognized stable codes/paths.
final class MerchantServerValidationFailure extends MerchantOnboardingFailure {
  const MerchantServerValidationFailure(this.failures);

  final List<MerchantValidationFailure> failures;
}

/// The application already exists for this user (idempotent replay or a
/// previous accepted submission).
final class MerchantDuplicateApplicationFailure
    extends MerchantOnboardingFailure {
  const MerchantDuplicateApplicationFailure();
}

/// The registration number is already registered to another business.
final class MerchantRegistrationConflictFailure
    extends MerchantOnboardingFailure {
  const MerchantRegistrationConflictFailure();
}

/// Reference ids used by the draft no longer exist in the server snapshot.
final class MerchantStaleReferenceFailure extends MerchantOnboardingFailure {
  const MerchantStaleReferenceFailure();
}

/// The accepted terms version differs from the server's current version.
final class MerchantStaleTermsFailure extends MerchantOnboardingFailure {
  const MerchantStaleTermsFailure();
}

final class MerchantUnauthenticatedFailure extends MerchantOnboardingFailure {
  const MerchantUnauthenticatedFailure();
}

/// An idempotency key is already being processed; the client may retry the
/// same submission later.
final class MerchantIdempotencyInProgressFailure
    extends MerchantOnboardingFailure {
  const MerchantIdempotencyInProgressFailure();
}

/// Retryable transport/server failure (timeout, 5xx, generic conflict).
final class MerchantRetryableFailure extends MerchantOnboardingFailure {
  const MerchantRetryableFailure();
}

final class MerchantUnexpectedFailure extends MerchantOnboardingFailure {
  const MerchantUnexpectedFailure();
}
