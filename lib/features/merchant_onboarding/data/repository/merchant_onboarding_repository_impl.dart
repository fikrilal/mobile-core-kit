import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/mapper/merchant_onboarding_submit_mapper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/mapper/merchant_reference_data_mapper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_validation_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

/// Production repository adapter backed by the authenticated remote
/// datasource. Transport types never cross the domain boundary; success and
/// every documented backend error code map to the feature failure taxonomy.
class MerchantOnboardingRepositoryImpl implements MerchantOnboardingRepository {
  MerchantOnboardingRepositoryImpl(this._remote);

  final MerchantOnboardingRemoteDataSource _remote;

  @override
  Future<Either<MerchantOnboardingFailure, MerchantReferenceData>>
  loadReferenceData() async {
    try {
      final response = await _remote.fetchReferenceData();
      if (response.isError) {
        return left(mapReferenceFailure(response));
      }
      final data = response.data;
      if (data == null) {
        return left(const MerchantUnexpectedFailure());
      }
      final reference = merchantReferenceDataFromDto(data);
      if (reference == null) {
        return left(const MerchantUnexpectedFailure());
      }
      return right(reference);
    } catch (e, st) {
      return left(_mapException(e, st, 'loadReferenceData'));
    }
  }

  @override
  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>>
  submitApplication(MerchantOnboardingApplication application) async {
    try {
      final request = merchantOnboardingSubmitRequestFromApplication(
        application,
      );
      final response = await _remote.submitApplication(request: request);
      if (response.isError) {
        return left(mapSubmitFailure(response));
      }
      final data = response.data;
      if (data == null) {
        return left(const MerchantUnexpectedFailure());
      }
      return right(
        MerchantApplicationReceipt(applicationId: data.applicationId),
      );
    } catch (e, st) {
      return left(_mapException(e, st, 'submitApplication'));
    }
  }

  MerchantOnboardingFailure _mapException(
    Object error,
    StackTrace stack,
    String operation,
  ) {
    if (error is ApiFailure) {
      return mapApiFailure(error);
    }
    // Dio exceptions reach here only when ApiHelper did not normalize them.
    // Never expose raw messages; surface a safe retryable failure.
    return const MerchantRetryableFailure();
  }
}

/// Maps a reference-data `ApiResponse` error into a domain failure.
MerchantOnboardingFailure mapReferenceFailure(ApiResponse<dynamic> response) {
  final failure = response.code;
  return switch (failure) {
    'UNAUTHORIZED' => const MerchantUnauthenticatedFailure(),
    'INTERNAL' => const MerchantRetryableFailure(),
    _ => const MerchantUnexpectedFailure(),
  };
}

/// Maps a submit `ApiResponse` error into the documented domain outcomes.
MerchantOnboardingFailure mapSubmitFailure(ApiResponse<dynamic> response) {
  final code = response.code;
  switch (code) {
    case 'VALIDATION_FAILED':
      final failures = response.errors ?? const [];
      return MerchantServerValidationFailure(
        failures
            .map(
              (error) => MerchantValidationFailure(
                code: error.code ?? 'server.field.invalid',
                path: error.field,
              ),
            )
            .toList(growable: false),
      );
    case 'UNAUTHORIZED':
      return const MerchantUnauthenticatedFailure();
    case 'IDEMPOTENCY_IN_PROGRESS':
      return const MerchantIdempotencyInProgressFailure();
    case 'MERCHANT_ONBOARDING_APPLICATION_ALREADY_EXISTS':
      return const MerchantDuplicateApplicationFailure();
    case 'MERCHANT_ONBOARDING_REGISTRATION_ALREADY_EXISTS':
      return const MerchantRegistrationConflictFailure();
    case 'MERCHANT_ONBOARDING_REFERENCE_DATA_STALE':
      return const MerchantStaleReferenceFailure();
    case 'MERCHANT_ONBOARDING_TERMS_VERSION_STALE':
      return const MerchantStaleTermsFailure();
    case 'CONFLICT':
    case 'INTERNAL':
      return const MerchantRetryableFailure();
    default:
      return const MerchantUnexpectedFailure();
  }
}

/// Maps a normalized [ApiFailure] into the domain failure taxonomy.
MerchantOnboardingFailure mapApiFailure(ApiFailure failure) {
  return switch (failure.code) {
    'UNAUTHORIZED' => const MerchantUnauthenticatedFailure(),
    'IDEMPOTENCY_IN_PROGRESS' => const MerchantIdempotencyInProgressFailure(),
    'MERCHANT_ONBOARDING_APPLICATION_ALREADY_EXISTS' =>
      const MerchantDuplicateApplicationFailure(),
    'MERCHANT_ONBOARDING_REGISTRATION_ALREADY_EXISTS' =>
      const MerchantRegistrationConflictFailure(),
    'MERCHANT_ONBOARDING_REFERENCE_DATA_STALE' =>
      const MerchantStaleReferenceFailure(),
    'MERCHANT_ONBOARDING_TERMS_VERSION_STALE' =>
      const MerchantStaleTermsFailure(),
    _ => const MerchantRetryableFailure(),
  };
}
