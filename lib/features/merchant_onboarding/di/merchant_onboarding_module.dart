import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/repository/fake_merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/load_merchant_reference_data_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';

/// Feature DI module for the merchant-onboarding demo. The fake repository
/// stands in until the backend contract is generated.
class MerchantOnboardingModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<MerchantOnboardingRepository>()) {
      getIt.registerLazySingleton<MerchantOnboardingRepository>(
        FakeMerchantOnboardingRepository.new,
      );
    }

    if (!getIt.isRegistered<LoadMerchantReferenceDataUseCase>()) {
      getIt.registerFactory<LoadMerchantReferenceDataUseCase>(
        () => LoadMerchantReferenceDataUseCase(
          getIt<MerchantOnboardingRepository>(),
        ),
      );
    }

    if (!getIt.isRegistered<SubmitMerchantOnboardingUseCase>()) {
      getIt.registerFactory<SubmitMerchantOnboardingUseCase>(
        () => SubmitMerchantOnboardingUseCase(
          getIt<MerchantOnboardingRepository>(),
        ),
      );
    }

    if (!getIt.isRegistered<MerchantOnboardingCubit>()) {
      getIt.registerFactory<MerchantOnboardingCubit>(
        () => MerchantOnboardingCubit(
          getIt<LoadMerchantReferenceDataUseCase>(),
          getIt<SubmitMerchantOnboardingUseCase>(),
        ),
      );
    }
  }
}
