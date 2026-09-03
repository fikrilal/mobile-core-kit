import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_error_codes.dart';
import 'package:mobile_core_kit/core/infra/network/exceptions/api_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/error/merchant_onboarding_error_codes.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/error/merchant_onboarding_failure_mapper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';

void main() {
  group('mapMerchantReferenceFailure', () {
    test(
      'maps UNAUTHORIZED code and 401 status to unauthenticated failure',
      () {
        final byCode = ApiFailure(
          message: 'Unauthorized',
          code: ApiErrorCodes.unauthorized,
        );
        final byStatus = ApiFailure(message: 'Unauthorized', statusCode: 401);

        expect(
          mapMerchantReferenceFailure(byCode),
          isA<MerchantUnauthenticatedFailure>(),
        );
        expect(
          mapMerchantReferenceFailure(byStatus),
          isA<MerchantUnauthenticatedFailure>(),
        );
      },
    );

    test('maps INTERNAL and 5xx status to retryable failure', () {
      final byCode = ApiFailure(
        message: 'Internal',
        code: ApiErrorCodes.internal,
      );
      final byStatus = ApiFailure(message: 'Server error', statusCode: 500);

      expect(
        mapMerchantReferenceFailure(byCode),
        isA<MerchantRetryableFailure>(),
      );
      expect(
        mapMerchantReferenceFailure(byStatus),
        isA<MerchantRetryableFailure>(),
      );
    });

    test('maps unknown codes to unexpected failure', () {
      final unknown = ApiFailure(message: 'Unknown', code: 'SOMETHING_ELSE');

      expect(
        mapMerchantReferenceFailure(unknown),
        isA<MerchantUnexpectedFailure>(),
      );
    });
  });

  group('mapMerchantSubmitFailure', () {
    test(
      'maps VALIDATION_FAILED with field errors to MerchantServerValidationFailure',
      () {
        final failure = ApiFailure(
          message: 'Validation failed',
          code: ApiErrorCodes.validationFailed,
          validationErrors: const [
            ValidationError(
              field: 'business.legalName',
              message: 'Invalid name',
              code: 'business.legal_name.invalid',
            ),
          ],
        );

        final result = mapMerchantSubmitFailure(failure);
        expect(result, isA<MerchantServerValidationFailure>());
        final validation = result as MerchantServerValidationFailure;
        expect(validation.failures.single.path, 'business.legalName');
        expect(validation.failures.single.code, 'business.legal_name.invalid');
      },
    );

    test('maps documented domain error codes correctly', () {
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(
            message: '',
            code: MerchantOnboardingErrorCodes.applicationAlreadyExists,
          ),
        ),
        isA<MerchantDuplicateApplicationFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(
            message: '',
            code: MerchantOnboardingErrorCodes.registrationAlreadyExists,
          ),
        ),
        isA<MerchantRegistrationConflictFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(
            message: '',
            code: MerchantOnboardingErrorCodes.referenceDataStale,
          ),
        ),
        isA<MerchantStaleReferenceFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(
            message: '',
            code: MerchantOnboardingErrorCodes.termsVersionStale,
          ),
        ),
        isA<MerchantStaleTermsFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(message: '', code: ApiErrorCodes.idempotencyInProgress),
        ),
        isA<MerchantIdempotencyInProgressFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(message: '', code: ApiErrorCodes.unauthorized),
        ),
        isA<MerchantUnauthenticatedFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(message: '', code: ApiErrorCodes.conflict),
        ),
        isA<MerchantRetryableFailure>(),
      );
      expect(
        mapMerchantSubmitFailure(
          ApiFailure(message: '', code: ApiErrorCodes.internal),
        ),
        isA<MerchantRetryableFailure>(),
      );
    });

    test('maps unknown codes to unexpected failure', () {
      final unknown = ApiFailure(message: 'Unknown', code: 'UNEXPECTED_CODE');
      expect(
        mapMerchantSubmitFailure(unknown),
        isA<MerchantUnexpectedFailure>(),
      );
    });
  });
}
