import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';
import 'package:mobile_core_kit/core/infra/network/upload/presigned_upload_client.dart';
import 'package:mobile_core_kit/core/runtime/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/local/profile_avatar_cache_local_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/local/profile_draft_local_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/remote/profile_avatar_download_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/remote/profile_image_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/repository/profile_avatar_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/repository/profile_draft_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/repository/profile_image_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/repository/profile_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/data/services/profile_avatar_cache_session_listener.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_avatar_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_draft_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_all_profile_avatar_caches_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/get_cached_profile_avatar_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/get_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/get_profile_image_url_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/refresh_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/save_profile_avatar_cache_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/save_profile_draft_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit.dart';

class AccountProfileModule {
  static void register(GetIt getIt) {
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

    if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
      getIt.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(getIt<ApiHelper>()),
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

    if (!getIt.isRegistered<ProfileRepository>()) {
      getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
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
        () => PatchMeProfileUseCase(getIt<ProfileRepository>()),
      );
    }

    if (!getIt.isRegistered<UploadProfileImageUseCase>()) {
      getIt.registerFactory<UploadProfileImageUseCase>(
        () => UploadProfileImageUseCase(
          getIt<ProfileImageRepository>(),
          getIt<CurrentUserFetcher>(),
        ),
      );
    }

    if (!getIt.isRegistered<ClearProfileImageUseCase>()) {
      getIt.registerFactory<ClearProfileImageUseCase>(
        () => ClearProfileImageUseCase(
          getIt<ProfileImageRepository>(),
          getIt<CurrentUserFetcher>(),
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
        () => RefreshProfileAvatarCacheUseCase(getIt<ProfileAvatarRepository>()),
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
        () => ClearAllProfileAvatarCachesUseCase(getIt<ProfileAvatarRepository>()),
      );
    }

    if (!getIt.isRegistered<ProfileAvatarCacheSessionListener>()) {
      getIt.registerLazySingleton<ProfileAvatarCacheSessionListener>(
        () => ProfileAvatarCacheSessionListener(
          events: getIt<AppEventBus>(),
          cache: getIt<ProfileAvatarCacheLocalDataSource>(),
        ),
        dispose: (listener) => listener.dispose(),
      );
    }

    if (getIt.isRegistered<AppEventBus>()) {
      getIt<ProfileAvatarCacheSessionListener>();
    }

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
  }
}
