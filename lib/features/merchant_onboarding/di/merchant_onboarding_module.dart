import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/datasource/remote/merchant_onboarding_remote_datasource.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/data/repository/merchant_onboarding_repository_impl.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/repository/merchant_onboarding_repository.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/load_merchant_reference_data_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/domain/usecase/submit_merchant_onboarding_usecase.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';

/// Feature DI module for the merchant-onboarding flow backed by the
/// authenticated remote datasource.
class MerchantOnboardingModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<MerchantOnboardingRemoteDataSource>()) {
      getIt.registerLazySingleton<MerchantOnboardingRemoteDataSource>(
        () => MerchantOnboardingRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<MerchantOnboardingRepository>()) {
      getIt.registerLazySingleton<MerchantOnboardingRepository>(
        () => MerchantOnboardingRepositoryImpl(
          getIt<MerchantOnboardingRemoteDataSource>(),
        ),
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
