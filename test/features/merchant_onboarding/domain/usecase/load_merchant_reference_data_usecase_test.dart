import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/load_merchant_reference_data_usecase.dart';

import '../../support/fake_merchant_onboarding_repository.dart';

void main() {
  group('LoadMerchantReferenceDataUseCase', () {
    test(
      'loads the deterministic demo catalogs from the fake adapter',
      () async {
        final usecase = LoadMerchantReferenceDataUseCase(
          FakeMerchantOnboardingRepository(),
        );

        final result = await usecase();

        final reference = result.getRight().toNullable()!;
        expect(
          reference.businessTypes.map((o) => o.id),
          containsAll(['sole_proprietorship', 'private_company']),
        );
        expect(reference.industries, hasLength(4));
        expect(reference.ownerRoles.map((o) => o.id), contains('owner'));
        expect(
          reference.banks
              .firstWhere((b) => b.id == 'demo_bank_beta')
              .supportedScheduleIds,
          {'weekly'},
        );
        expect(reference.termsVersion, '2026-08-30');
      },
    );

    test('surfaces repository failures unchanged', () async {
      final usecase = LoadMerchantReferenceDataUseCase(_FailingRepository());

      final result = await usecase();

      expect(result.getLeft().toNullable(), isA<MerchantUnexpectedFailure>());
    });
  });
}

class _FailingRepository implements MerchantOnboardingRepository {
  @override
  Future<Either<MerchantOnboardingFailure, MerchantReferenceData>>
  loadReferenceData() async => left(const MerchantUnexpectedFailure());

  @override
  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>>
  submitApplication(MerchantOnboardingApplication application) async =>
      left(const MerchantUnexpectedFailure());
}
