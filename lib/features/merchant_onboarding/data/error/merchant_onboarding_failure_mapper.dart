import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/error/merchant_onboarding_error_codes.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_validation_failure.dart';

MerchantOnboardingFailure mapMerchantReferenceFailure(ApiFailure failure) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.unauthorized:
        return const MerchantUnauthenticatedFailure();
      case ApiErrorCodes.internal:
        return const MerchantRetryableFailure();
      default:
        return const MerchantUnexpectedFailure();
    }
  }

  return switch (failure.statusCode) {
    401 => const MerchantUnauthenticatedFailure(),
    500 || 502 || 503 || 504 || -1 || -2 => const MerchantRetryableFailure(),
    _ => const MerchantUnexpectedFailure(),
  };
}

MerchantOnboardingFailure mapMerchantSubmitFailure(ApiFailure failure) {
  final code = failure.code;
  if (code != null) {
    switch (code) {
      case ApiErrorCodes.validationFailed:
        final errors = failure.validationErrors ?? const [];
        return MerchantServerValidationFailure(
          errors
              .map(
                (error) => MerchantValidationFailure(
                  code: error.code ?? 'server.field.invalid',
                  path: error.field,
                ),
              )
              .toList(growable: false),
        );
      case ApiErrorCodes.unauthorized:
        return const MerchantUnauthenticatedFailure();
      case ApiErrorCodes.idempotencyInProgress:
        return const MerchantIdempotencyInProgressFailure();
      case MerchantOnboardingErrorCodes.applicationAlreadyExists:
        return const MerchantDuplicateApplicationFailure();
      case MerchantOnboardingErrorCodes.registrationAlreadyExists:
        return const MerchantRegistrationConflictFailure();
      case MerchantOnboardingErrorCodes.referenceDataStale:
        return const MerchantStaleReferenceFailure();
      case MerchantOnboardingErrorCodes.termsVersionStale:
        return const MerchantStaleTermsFailure();
      case ApiErrorCodes.conflict:
      case ApiErrorCodes.internal:
        return const MerchantRetryableFailure();
      default:
        return const MerchantUnexpectedFailure();
    }
  }

  return switch (failure.statusCode) {
    401 => const MerchantUnauthenticatedFailure(),
    409 => const MerchantRetryableFailure(),
    _ when (failure.statusCode ?? 0) >= 500 => const MerchantRetryableFailure(),
    -1 || -2 => const MerchantRetryableFailure(),
    _ => const MerchantUnexpectedFailure(),
  };
}
