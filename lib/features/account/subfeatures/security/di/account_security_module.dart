import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/data/datasource/remote/me_session_remote_datasource.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/data/repository/me_session_repository_impl.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/repository/me_session_repository.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/list_me_sessions_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/domain/usecase/revoke_me_session_usecase.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_cubit.dart';

class AccountSecurityModule {
  static void register(GetIt getIt) {
    if (!getIt.isRegistered<MeSessionRemoteDataSource>()) {
      getIt.registerLazySingleton<MeSessionRemoteDataSource>(
        () => MeSessionRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<MeSessionRepository>()) {
      getIt.registerLazySingleton<MeSessionRepository>(
        () => MeSessionRepositoryImpl(getIt<MeSessionRemoteDataSource>()),
      );
    }

    if (!getIt.isRegistered<ListMeSessionsUseCase>()) {
      getIt.registerFactory<ListMeSessionsUseCase>(
        () => ListMeSessionsUseCase(getIt<MeSessionRepository>()),
      );
    }

    if (!getIt.isRegistered<RevokeMeSessionUseCase>()) {
      getIt.registerFactory<RevokeMeSessionUseCase>(
        () => RevokeMeSessionUseCase(getIt<MeSessionRepository>()),
      );
    }

    if (!getIt.isRegistered<MeSessionsCubit>()) {
      getIt.registerFactory<MeSessionsCubit>(
        () => MeSessionsCubit(
          getIt<ListMeSessionsUseCase>(),
          getIt<RevokeMeSessionUseCase>(),
        ),
      );
    }
  }
}
