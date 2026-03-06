import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/features/account/adapters/cached_user_store_adapter.dart';
import 'package:mobile_core_kit/features/account/adapters/current_user_fetcher_adapter.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';

class AccountKernelAdapterModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<CachedUserStore>()) {
      getIt.registerLazySingleton<CachedUserStore>(
        () => AccountCachedUserStoreAdapter(getIt<UserLocalDataSource>()),
      );
    }

    if (!getIt.isRegistered<CurrentUserFetcher>()) {
      getIt.registerFactory<CurrentUserFetcher>(
        () => AccountCurrentUserFetcherAdapter(getIt<GetMeUseCase>()),
      );
    }
  }
}
