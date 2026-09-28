import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/aggregate/merchant_onboarding_application.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/entity/merchant_reference_data_entity.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/failure/merchant_onboarding_failure.dart';

abstract class MerchantOnboardingRepository {
  Future<Either<MerchantOnboardingFailure, MerchantReferenceDataEntity>>
  loadReferenceData();

  Future<Either<MerchantOnboardingFailure, MerchantApplicationReceipt>>
  submitApplication(MerchantOnboardingApplication application);
}
