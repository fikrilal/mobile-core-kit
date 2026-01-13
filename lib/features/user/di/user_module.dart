import 'package:get_it/get_it.dart';

import '../../../core/network/api/api_helper.dart';
import '../data/datasource/remote/user_remote_datasource.dart';
import '../data/repository/user_repository_impl.dart';
import '../domain/repository/user_repository.dart';
import '../domain/usecase/get_me_usecase.dart';

class UserModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<UserRemoteDataSource>()) {
      getIt.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
      );
    }

    if (!getIt.isRegistered<GetMeUseCase>()) {
      getIt.registerFactory<GetMeUseCase>(
        () => GetMeUseCase(getIt<UserRepository>()),
      );
    }
  }
}
