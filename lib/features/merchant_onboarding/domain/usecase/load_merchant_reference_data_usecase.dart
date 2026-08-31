import 'package:fpdart/fpdart.dart';

import 'package:mobile_core_kit/features/merchant_onboarding/domain/merchant_onboarding_failure.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/reference/merchant_reference_data.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';

/// Loads the immutable reference-data snapshot required before editing.
class LoadMerchantReferenceDataUseCase {
  LoadMerchantReferenceDataUseCase(this._repository);

  final MerchantOnboardingRepository _repository;

  Future<Either<MerchantOnboardingFailure, MerchantReferenceData>> call() {
    return _repository.loadReferenceData();
  }
}
