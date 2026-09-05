import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/input/merchant_onboarding_input.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

class SubmitMerchantOnboardingUseCase {
  SubmitMerchantOnboardingUseCase(this._repository);

  final MerchantOnboardingRepository _repository;

  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>> call({
    required MerchantOnboardingInput input,
    required MerchantReferenceDataEntity reference,
  }) {
    return MerchantOnboardingApplication.create(
      input: input,
      reference: reference,
    ).match(
      (failures) async => left(MerchantLocalValidationFailure(failures)),
      _repository.submitApplication,
    );
  }
}
