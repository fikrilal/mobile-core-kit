import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/features/account/data/datasource/local/account_cached_user_local_datasource.dart';
import 'package:mobile_core_kit/features/account/data/datasource/remote/me_push_token_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/data/datasource/remote/me_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/data/repository/current_user_repository_impl.dart';
import 'package:mobile_core_kit/features/account/domain/repository/current_user_repository.dart';
import 'package:mobile_core_kit/features/account/domain/usecase/get_current_user_usecase.dart';

class AccountCurrentUserModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<AccountCachedUserLocalDataSource>()) {
      getIt.registerLazySingleton<AccountCachedUserLocalDataSource>(
        () => const AccountCachedUserLocalDataSource(),
      );
    }

    if (!getIt.isRegistered<MeRemoteDataSource>()) {
      getIt.registerLazySingleton<MeRemoteDataSource>(
        () => MeRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<PushTokenRegistrar>()) {
      getIt.registerLazySingleton<PushTokenRegistrar>(
        () => MePushTokenRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<CurrentUserRepository>()) {
      getIt.registerLazySingleton<CurrentUserRepository>(
        () => CurrentUserRepositoryImpl(getIt<MeRemoteDataSource>()),
      );
    }

    if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
      getIt.registerFactory<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(getIt<CurrentUserRepository>()),
      );
    }
  }
}
