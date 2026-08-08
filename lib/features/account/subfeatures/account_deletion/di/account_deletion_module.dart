import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/datasource/remote/account_deletion_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/data/repository/account_deletion_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/repository/account_deletion_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/domain/usecase/account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';

class AccountDeletionModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<AccountDeletionRemoteDataSource>()) {
      getIt.registerLazySingleton<AccountDeletionRemoteDataSource>(
        () => AccountDeletionRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<AccountDeletionRepository>()) {
      getIt.registerLazySingleton<AccountDeletionRepository>(
        () => AccountDeletionRepositoryImpl(
          getIt<AccountDeletionRemoteDataSource>(),
        ),
      );
    }

    if (!getIt.isRegistered<AccountDeletionUseCase>()) {
      getIt.registerFactory<AccountDeletionUseCase>(
        () => AccountDeletionUseCase(getIt<AccountDeletionRepository>()),
      );
    }

    if (!getIt.isRegistered<RequestAccountDeletionCubit>()) {
      getIt.registerFactory<RequestAccountDeletionCubit>(
        () => RequestAccountDeletionCubit(
          getIt<AccountDeletionUseCase>(),
          getIt<UserContextService>(),
        ),
      );
    }
  }
}
