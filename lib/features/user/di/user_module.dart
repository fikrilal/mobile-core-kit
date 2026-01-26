import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/database/app_database.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/services/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_draft_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/me_push_token_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/repository/profile_draft_repository_impl.dart';
import 'package:mobile_core_kit/features/user/data/repository/user_repository_impl.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_draft_repository.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';

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

    if (!getIt.isRegistered<ProfileDraftLocalDataSource>()) {
      getIt.registerLazySingleton<ProfileDraftLocalDataSource>(
        () => ProfileDraftLocalDataSource(),
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

    if (!getIt.isRegistered<ProfileDraftRepository>()) {
      getIt.registerLazySingleton<ProfileDraftRepository>(
        () => ProfileDraftRepositoryImpl(getIt<ProfileDraftLocalDataSource>()),
      );
    }

    if (!getIt.isRegistered<GetMeUseCase>()) {
      getIt.registerFactory<GetMeUseCase>(
        () => GetMeUseCase(getIt<UserRepository>()),
      );
    }

    if (!getIt.isRegistered<GetProfileDraftUseCase>()) {
      getIt.registerFactory<GetProfileDraftUseCase>(
        () => GetProfileDraftUseCase(getIt<ProfileDraftRepository>()),
      );
    }

    if (!getIt.isRegistered<SaveProfileDraftUseCase>()) {
      getIt.registerFactory<SaveProfileDraftUseCase>(
        () => SaveProfileDraftUseCase(getIt<ProfileDraftRepository>()),
      );
    }

    if (!getIt.isRegistered<ClearProfileDraftUseCase>()) {
      getIt.registerFactory<ClearProfileDraftUseCase>(
        () => ClearProfileDraftUseCase(getIt<ProfileDraftRepository>()),
      );
    }

    if (!getIt.isRegistered<PatchMeProfileUseCase>()) {
      getIt.registerFactory<PatchMeProfileUseCase>(
        () => PatchMeProfileUseCase(getIt<UserRepository>()),
      );
    }

    // Presentation
    if (!getIt.isRegistered<CompleteProfileCubit>()) {
      getIt.registerFactory<CompleteProfileCubit>(
        () => CompleteProfileCubit(
          getIt<GetProfileDraftUseCase>(),
          getIt<SaveProfileDraftUseCase>(),
          getIt<ClearProfileDraftUseCase>(),
          getIt<PatchMeProfileUseCase>(),
          getIt<SessionManager>(),
        ),
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
      passwordNotSet: () => const SessionFailure.unexpected(),
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
