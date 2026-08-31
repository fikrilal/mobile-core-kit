import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../merchant_test_fixtures.dart';

class _MockMerchantOnboardingRepository extends Mock
    implements MerchantOnboardingRepository {}

void main() {
  late _MockMerchantOnboardingRepository repo;

  setUpAll(() {
    registerFallbackValue(
      MerchantOnboardingApplication.create(
        input: validInput(),
        reference: buildReferenceData(),
      ).getRight().toNullable()!,
    );
  });

  setUp(() {
    repo = _MockMerchantOnboardingRepository();
    when(() => repo.submitApplication(any())).thenAnswer(
      (_) async => right(
        const MerchantApplicationReceipt(
          applicationId: 'demo-merchant-application-0001',
        ),
      ),
    );
  });

  group('SubmitMerchantOnboardingUseCase', () {
    test('never calls the repository for invalid raw input', () async {
      final usecase = SubmitMerchantOnboardingUseCase(repo);

      final result = await usecase(
        input: validInput(business: validBusinessInput(legalName: '')),
        reference: buildReferenceData(),
      );

      final failure = result.getLeft().toNullable();
      expect(failure, isA<MerchantLocalValidationFailure>());
      expect(
        (failure as MerchantLocalValidationFailure).failures.first.code,
        'business.legal_name.required',
      );
      verifyNever(() => repo.submitApplication(any()));
    });

    test('rejects an unknown dropdown id at the final gate', () async {
      final usecase = SubmitMerchantOnboardingUseCase(repo);

      final result = await usecase(
        input: validInput(business: validBusinessInput(industryId: 'mining')),
        reference: buildReferenceData(),
      );

      expect(result.isLeft(), true);
      verifyNever(() => repo.submitApplication(any()));
    });

    test('submits a validated application exactly once when valid', () async {
      final usecase = SubmitMerchantOnboardingUseCase(repo);
      final input = validInput();

      final result = await usecase(
        input: input,
        reference: buildReferenceData(),
      );

      expect(result.isRight(), true);
      final captured = verify(
        () => repo.submitApplication(captureAny()),
      ).captured;
      expect(captured, hasLength(1));
      final application = captured.single as MerchantOnboardingApplication;
      expect(
        application.business.contactEmail.value,
        'contact@kopinusantara.id',
      );
      expect(application.settlement.accountNumber.value, '0123456789');
    });
  });
}
