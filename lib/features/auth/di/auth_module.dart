import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/database/app_database.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/local/dao/user_dao.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/google_sign_in_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_remote_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/refresh_token_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_cubit.dart';

class AuthModule {
  static void register(GetIt getIt) {
    // Database table registration
    AppDatabase.registerOnCreate((db) async => UserDao(db).createTable());

    // Data sources
    if (!getIt.isRegistered<AuthRemoteDataSource>()) {
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    if (!getIt.isRegistered<AuthLocalDataSource>()) {
      getIt.registerLazySingleton<AuthLocalDataSource>(
        () => const AuthLocalDataSource(),
      );
    }

    // Repositories
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          getIt<AuthRemoteDataSource>(),
          getIt<GoogleFederatedAuthService>(),
        ),
      );
    }

    if (!getIt.isRegistered<SessionRepository>()) {
      getIt.registerLazySingleton<SessionRepository>(
        () => SessionRepositoryImpl(local: getIt<AuthLocalDataSource>()),
      );
    }

    // Use cases
    if (!getIt.isRegistered<LoginUserUseCase>()) {
      getIt.registerFactory<LoginUserUseCase>(
        () => LoginUserUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<RefreshTokenUsecase>()) {
      getIt.registerFactory<RefreshTokenUsecase>(
        () => RefreshTokenUsecase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<LogoutRemoteUseCase>()) {
      getIt.registerFactory<LogoutRemoteUseCase>(
        () => LogoutRemoteUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<RegisterUserUseCase>()) {
      getIt.registerFactory<RegisterUserUseCase>(
        () => RegisterUserUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<GoogleSignInUseCase>()) {
      getIt.registerFactory<GoogleSignInUseCase>(
        () => GoogleSignInUseCase(getIt<AuthRepository>()),
      );
    }

    // Session manager
    if (!getIt.isRegistered<SessionManager>()) {
      getIt.registerLazySingleton<SessionManager>(
        () => SessionManager(
          getIt<SessionRepository>(),
          refreshUsecase: getIt<RefreshTokenUsecase>(),
          events: getIt<AppEventBus>(),
        ),
        dispose: (manager) => manager.dispose(),
      );
    }

    if (!getIt.isRegistered<LogoutFlowUseCase>()) {
      getIt.registerFactory<LogoutFlowUseCase>(
        () => LogoutFlowUseCase(
          logoutRemote: getIt<LogoutRemoteUseCase>(),
          sessionManager: getIt<SessionManager>(),
        ),
      );
    }

    // Presentation
    if (!getIt.isRegistered<LoginCubit>()) {
      getIt.registerFactory<LoginCubit>(
        () => LoginCubit(
          getIt<LoginUserUseCase>(),
          getIt<GoogleSignInUseCase>(),
          getIt<SessionManager>(),
          getIt<AnalyticsTracker>(),
        ),
      );
    }

    if (!getIt.isRegistered<RegisterCubit>()) {
      getIt.registerFactory<RegisterCubit>(
        () => RegisterCubit(
          getIt<RegisterUserUseCase>(),
          getIt<SessionManager>(),
          getIt<AnalyticsTracker>(),
        ),
      );
    }

    if (!getIt.isRegistered<LogoutCubit>()) {
      getIt.registerFactory<LogoutCubit>(
        () => LogoutCubit(getIt<LogoutFlowUseCase>()),
      );
    }
  }
}
