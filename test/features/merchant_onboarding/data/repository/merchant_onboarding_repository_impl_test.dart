import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/foundation/validation/validation_error.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_response.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/model/remote/merchant_onboarding_submit_models.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/repository/merchant_onboarding_repository_impl.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mocktail/mocktail.dart';

import '../../domain/merchant_test_fixtures.dart';
import '../../support/fake_merchant_onboarding_repository.dart';

class _MockRemoteDataSource extends Mock
    implements MerchantOnboardingRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const MerchantOnboardingSubmitRequestModel(
        business: MerchantBusinessInputModel(
          legalName: 'x',
          businessTypeId: 'sole_proprietorship',
          industryId: 'retail',
          monthlySalesRangeId: '10m_to_50m_idr',
          contactEmail: 'a@b.co',
          contactPhone: '+6281234567890',
        ),
        owners: [],
        settlement: MerchantSettlementInputModel(
          bankId: 'demo_bank_alpha',
          accountHolderName: 'A',
          accountNumber: '123456',
          holderTypeId: 'business',
          payoutScheduleId: 'daily',
        ),
        declarations: MerchantDeclarationsInputModel(
          informationAccurate: true,
          authorizedToSubmit: true,
          termsAccepted: true,
          termsVersion: '2026-08-30',
        ),
      ),
    );
  });

  late _MockRemoteDataSource remote;
  late MerchantOnboardingRepositoryImpl repository;

  setUp(() {
    remote = _MockRemoteDataSource();
    repository = MerchantOnboardingRepositoryImpl(remote);
  });

  test(
    'loadReferenceData maps a success envelope into the domain snapshot',
    () async {
      when(() => remote.fetchReferenceData()).thenAnswer(
        (_) async => ApiResponse.success(
          data: FakeMerchantOnboardingRepository.demoReferenceDataModel(),
        ),
      );

      final result = await repository.loadReferenceData();

      final reference = result.getRight().toNullable()!;
      expect(reference.businessTypes, isNotEmpty);
      expect(reference.termsVersion, '2026-08-30');
    },
  );

  test('loadReferenceData maps UNAUTHORIZED to unauthenticated', () async {
    when(() => remote.fetchReferenceData()).thenAnswer(
      (_) async => ApiResponse.error(code: 'UNAUTHORIZED', statusCode: 401),
    );

    final result = await repository.loadReferenceData();

    expect(
      result.getLeft().toNullable(),
      isA<MerchantUnauthenticatedFailure>(),
    );
  });

  test('submitApplication maps every documented backend error code', () async {
    final application = MerchantOnboardingApplication.create(
      input: validInput(),
      reference: buildReferenceData(),
    ).getRight().toNullable()!;

    final cases = <String, MerchantOnboardingFailure>{
      'UNAUTHORIZED': const MerchantUnauthenticatedFailure(),
      'IDEMPOTENCY_IN_PROGRESS': const MerchantIdempotencyInProgressFailure(),
      'MERCHANT_ONBOARDING_APPLICATION_ALREADY_EXISTS':
          const MerchantDuplicateApplicationFailure(),
      'MERCHANT_ONBOARDING_REGISTRATION_ALREADY_EXISTS':
          const MerchantRegistrationConflictFailure(),
      'MERCHANT_ONBOARDING_REFERENCE_DATA_STALE':
          const MerchantStaleReferenceFailure(),
      'MERCHANT_ONBOARDING_TERMS_VERSION_STALE':
          const MerchantStaleTermsFailure(),
      'CONFLICT': const MerchantRetryableFailure(),
      'INTERNAL': const MerchantRetryableFailure(),
    };

    for (final entry in cases.entries) {
      when(
        () => remote.submitApplication(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => ApiResponse.error(code: entry.key, statusCode: 409),
      );

      final result = await repository.submitApplication(application);

      expect(
        result.getLeft().toNullable(),
        isA<MerchantOnboardingFailure>().having(
          (f) => f.runtimeType,
          'type',
          entry.value.runtimeType,
        ),
        reason: 'code ${entry.key}',
      );
    }
  });

  test(
    'submitApplication maps VALIDATION_FAILED errors with stable paths',
    () async {
      final application = MerchantOnboardingApplication.create(
        input: validInput(),
        reference: buildReferenceData(),
      ).getRight().toNullable()!;

      when(
        () => remote.submitApplication(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => ApiResponse.error(
          code: 'VALIDATION_FAILED',
          statusCode: 422,
          errors: [
            const ValidationError(
              field: 'business.legalName',
              message: 'too short',
              code: 'minLength',
            ),
          ],
        ),
      );

      final result = await repository.submitApplication(application);

      final failure = result.getLeft().toNullable()!;
      expect(failure, isA<MerchantServerValidationFailure>());
      final serverFailure = failure as MerchantServerValidationFailure;
      expect(serverFailure.failures.single.path, 'business.legalName');
      expect(serverFailure.failures.single.code, 'minLength');
    },
  );

  test(
    'submitApplication maps success to a receipt with only the app id',
    () async {
      final application = MerchantOnboardingApplication.create(
        input: validInput(),
        reference: buildReferenceData(),
      ).getRight().toNullable()!;

      when(
        () => remote.submitApplication(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => ApiResponse.success(
          data: const MerchantSubmitResultModel(
            applicationId: 'app-123',
            submittedAt: '2026-08-31T00:00:00.000Z',
          ),
        ),
      );

      final result = await repository.submitApplication(application);

      final receipt = result.getRight().toNullable()!;
      expect(receipt.applicationId, 'app-123');
    },
  );

  test('unknown failure codes fall back to unexpected', () async {
    final application = MerchantOnboardingApplication.create(
      input: validInput(),
      reference: buildReferenceData(),
    ).getRight().toNullable()!;

    when(
      () => remote.submitApplication(request: any(named: 'request')),
    ).thenAnswer(
      (_) async => ApiResponse.error(code: 'SOME_NEW_CODE', statusCode: 500),
    );

    final result = await repository.submitApplication(application);

    expect(result.getLeft().toNullable(), isA<MerchantUnexpectedFailure>());
  });
}
