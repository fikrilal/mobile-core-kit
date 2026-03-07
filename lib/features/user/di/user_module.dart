import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/me_push_token_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/repository/user_repository_impl.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/cancel_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/request_account_deletion_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';

class UserModule {
  static bool _dbRegistered = false;

  static void register(GetIt getIt) {
    // Database table registration (owned by the user feature).
    if (!_dbRegistered) {
      AppDatabase.registerOnCreate((db) async => UserDao(db).createTable());
      _dbRegistered = true;
    }

    if (!getIt.isRegistered<UserLocalDataSource>()) {
      getIt.registerLazySingleton<UserLocalDataSource>(
        () => const UserLocalDataSource(),
      );
    }

    if (!getIt.isRegistered<UserRemoteDataSource>()) {
      getIt.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<PushTokenRegistrar>()) {
      getIt.registerLazySingleton<PushTokenRegistrar>(
        () => MePushTokenRemoteDataSource(getIt<ApiHelper>()),
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

    if (!getIt.isRegistered<RequestAccountDeletionUseCase>()) {
      getIt.registerFactory<RequestAccountDeletionUseCase>(
        () => RequestAccountDeletionUseCase(getIt<UserRepository>()),
      );
    }

    if (!getIt.isRegistered<CancelAccountDeletionUseCase>()) {
      getIt.registerFactory<CancelAccountDeletionUseCase>(
        () => CancelAccountDeletionUseCase(getIt<UserRepository>()),
      );
    }

    if (!getIt.isRegistered<RequestAccountDeletionCubit>()) {
      getIt.registerFactory<RequestAccountDeletionCubit>(
        () => RequestAccountDeletionCubit(
          getIt<RequestAccountDeletionUseCase>(),
          getIt<CancelAccountDeletionUseCase>(),
          getIt<UserContextService>(),
        ),
      );
    }
  }
}
