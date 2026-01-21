import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

import 'package:mobile_core_kit/core/database/app_database.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/repository/user_repository_impl.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';

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

    if (!getIt.isRegistered<CachedUserStore>()) {
      getIt.registerLazySingleton<CachedUserStore>(
        () => getIt<UserLocalDataSource>(),
      );
    }

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

    if (!getIt.isRegistered<PatchMeProfileUseCase>()) {
      getIt.registerFactory<PatchMeProfileUseCase>(
        () => PatchMeProfileUseCase(getIt<UserRepository>()),
      );
    }

    if (!getIt.isRegistered<CurrentUserFetcher>()) {
      getIt.registerFactory<CurrentUserFetcher>(
        () => _GetMeCurrentUserFetcher(getIt<GetMeUseCase>()),
      );
    }
  }
}

class _GetMeCurrentUserFetcher implements CurrentUserFetcher {
  _GetMeCurrentUserFetcher(this._getMe);

  final GetMeUseCase _getMe;

  @override
  Future<Either<SessionFailure, UserEntity>> fetch() async {
    final result = await _getMe();
    return result.mapLeft(_toSessionFailure);
  }

  SessionFailure _toSessionFailure(AuthFailure failure) {
    return failure.when(
      network: () => const SessionFailure.network(),
      cancelled: () => const SessionFailure.unexpected(),
      unauthenticated: () => const SessionFailure.unauthenticated(),
      emailTaken: () => const SessionFailure.unexpected(),
      emailNotVerified: () => const SessionFailure.unexpected(),
      validation: (_) => const SessionFailure.unexpected(),
      invalidCredentials: () => const SessionFailure.unexpected(),
      tooManyRequests: () => const SessionFailure.tooManyRequests(),
      userSuspended: () => const SessionFailure.unexpected(),
      serverError: (message) => SessionFailure.serverError(message),
      unexpected: (message) => SessionFailure.unexpected(message),
    );
  }
}
