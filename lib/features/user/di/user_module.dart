import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/core/infra/database/app_database.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/profile_draft_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/local/user_local_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/me_push_token_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_avatar_download_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:mobile_core_kit/features/user/data/repository/profile_avatar_repository_impl.dart';
import 'package:mobile_core_kit/features/user/data/repository/profile_draft_repository_impl.dart';
import 'package:mobile_core_kit/features/user/data/repository/profile_image_repository_impl.dart';
import 'package:mobile_core_kit/features/user/data/repository/user_repository_impl.dart';
import 'package:mobile_core_kit/features/user/data/services/user_avatar_cache_session_listener.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_avatar_repository.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_draft_repository.dart';
import 'package:mobile_core_kit/features/user/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/user/domain/repository/user_repository.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_all_profile_avatar_caches_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_cached_profile_avatar_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_me_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/get_profile_image_url_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/refresh_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/user/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/profile_image/profile_image_cubit.dart';

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

    if (!getIt.isRegistered<ProfileAvatarCacheLocalDataSource>()) {
      getIt.registerLazySingleton<ProfileAvatarCacheLocalDataSource>(
        () => ProfileAvatarCacheLocalDataSource(),
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

    if (!getIt.isRegistered<ProfileImageRemoteDataSource>()) {
      getIt.registerLazySingleton<ProfileImageRemoteDataSource>(
        () => ProfileImageRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<ProfileAvatarDownloadDataSource>()) {
      getIt.registerLazySingleton<ProfileAvatarDownloadDataSource>(
        () => ProfileAvatarDownloadDataSource(getIt<PresignedDownloadClient>()),
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

    if (!getIt.isRegistered<ProfileImageRepository>()) {
      getIt.registerLazySingleton<ProfileImageRepository>(
        () => ProfileImageRepositoryImpl(
          getIt<ProfileImageRemoteDataSource>(),
          getIt<PresignedUploadClient>(),
        ),
      );
    }

    if (!getIt.isRegistered<ProfileAvatarRepository>()) {
      getIt.registerLazySingleton<ProfileAvatarRepository>(
        () => ProfileAvatarRepositoryImpl(
          getIt<ProfileImageRemoteDataSource>(),
          getIt<ProfileAvatarDownloadDataSource>(),
          getIt<ProfileAvatarCacheLocalDataSource>(),
        ),
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

    if (!getIt.isRegistered<UploadProfileImageUseCase>()) {
      getIt.registerFactory<UploadProfileImageUseCase>(
        () => UploadProfileImageUseCase(
          getIt<ProfileImageRepository>(),
          getIt<GetMeUseCase>(),
        ),
      );
    }

    if (!getIt.isRegistered<ClearProfileImageUseCase>()) {
      getIt.registerFactory<ClearProfileImageUseCase>(
        () => ClearProfileImageUseCase(
          getIt<ProfileImageRepository>(),
          getIt<GetMeUseCase>(),
        ),
      );
    }

    if (!getIt.isRegistered<GetProfileImageUrlUseCase>()) {
      getIt.registerFactory<GetProfileImageUrlUseCase>(
        () => GetProfileImageUrlUseCase(getIt<ProfileImageRepository>()),
      );
    }

    if (!getIt.isRegistered<GetCachedProfileAvatarUseCase>()) {
      getIt.registerFactory<GetCachedProfileAvatarUseCase>(
        () => GetCachedProfileAvatarUseCase(getIt<ProfileAvatarRepository>()),
      );
    }

    if (!getIt.isRegistered<RefreshProfileAvatarCacheUseCase>()) {
      getIt.registerFactory<RefreshProfileAvatarCacheUseCase>(
        () =>
            RefreshProfileAvatarCacheUseCase(getIt<ProfileAvatarRepository>()),
      );
    }

    if (!getIt.isRegistered<SaveProfileAvatarCacheUseCase>()) {
      getIt.registerFactory<SaveProfileAvatarCacheUseCase>(
        () => SaveProfileAvatarCacheUseCase(getIt<ProfileAvatarRepository>()),
      );
    }

    if (!getIt.isRegistered<ClearProfileAvatarCacheUseCase>()) {
      getIt.registerFactory<ClearProfileAvatarCacheUseCase>(
        () => ClearProfileAvatarCacheUseCase(getIt<ProfileAvatarRepository>()),
      );
    }

    if (!getIt.isRegistered<ClearAllProfileAvatarCachesUseCase>()) {
      getIt.registerFactory<ClearAllProfileAvatarCachesUseCase>(
        () => ClearAllProfileAvatarCachesUseCase(
          getIt<ProfileAvatarRepository>(),
        ),
      );
    }

    // Feature-level session cleanup. Safe to initialize only when AppEventBus
    // exists (e.g. production DI); unit tests may register this module without
    // the full core stack.
    if (!getIt.isRegistered<UserAvatarCacheSessionListener>()) {
      getIt.registerLazySingleton<UserAvatarCacheSessionListener>(
        () => UserAvatarCacheSessionListener(
          events: getIt<AppEventBus>(),
          cache: getIt<ProfileAvatarCacheLocalDataSource>(),
        ),
        dispose: (listener) => listener.dispose(),
      );
    }

    if (getIt.isRegistered<AppEventBus>()) {
      getIt<UserAvatarCacheSessionListener>();
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

    if (!getIt.isRegistered<ProfileImageCubit>()) {
      getIt.registerFactory<ProfileImageCubit>(
        () => ProfileImageCubit(
          getIt<UserContextService>(),
          getIt<UploadProfileImageUseCase>(),
          getIt<ClearProfileImageUseCase>(),
          getIt<GetCachedProfileAvatarUseCase>(),
          getIt<RefreshProfileAvatarCacheUseCase>(),
          getIt<SaveProfileAvatarCacheUseCase>(),
          getIt<ClearProfileAvatarCacheUseCase>(),
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
