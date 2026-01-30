import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/events/app_event_bus.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/services/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/services/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/services/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/session/cached_user_store.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/entity/refresh_request_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/session/session_manager.dart';
import 'package:mobile_core_kit/core/session/session_push_token_revoker.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/session/session_repository_impl.dart';
import 'package:mobile_core_kit/core/session/token_refresher.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_remote_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/refresh_token_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/resend_email_verification_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/sign_in_with_google_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/verify_email_usecase.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_cubit.dart';

class AuthModule {
  static void register(GetIt getIt) {
    // Data sources
    if (!getIt.isRegistered<AuthRemoteDataSource>()) {
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(getIt<ApiHelper>()),
      );
    }

    // Repositories
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          getIt<AuthRemoteDataSource>(),
          getIt<GoogleFederatedAuthService>(),
          getIt<DeviceIdentityService>(),
        ),
      );
    }

    if (!getIt.isRegistered<SessionRepository>()) {
      getIt.registerLazySingleton<SessionRepository>(
        () => SessionRepositoryImpl(cachedUserStore: getIt<CachedUserStore>()),
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

    if (!getIt.isRegistered<TokenRefresher>()) {
      getIt.registerFactory<TokenRefresher>(
        () => _AuthRepositoryTokenRefresher(getIt<AuthRepository>()),
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

    if (!getIt.isRegistered<SignInWithGoogleUseCase>()) {
      getIt.registerFactory<SignInWithGoogleUseCase>(
        () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<VerifyEmailUseCase>()) {
      getIt.registerFactory<VerifyEmailUseCase>(
        () => VerifyEmailUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<ResendEmailVerificationUseCase>()) {
      getIt.registerFactory<ResendEmailVerificationUseCase>(
        () => ResendEmailVerificationUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<ChangePasswordUseCase>()) {
      getIt.registerFactory<ChangePasswordUseCase>(
        () => ChangePasswordUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<RequestPasswordResetUseCase>()) {
      getIt.registerFactory<RequestPasswordResetUseCase>(
        () => RequestPasswordResetUseCase(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<ConfirmPasswordResetUseCase>()) {
      getIt.registerFactory<ConfirmPasswordResetUseCase>(
        () => ConfirmPasswordResetUseCase(getIt<AuthRepository>()),
      );
    }

    // Session manager
    if (!getIt.isRegistered<SessionManager>()) {
      getIt.registerLazySingleton<SessionManager>(
        () => SessionManager(
          getIt<SessionRepository>(),
          tokenRefresher: getIt<TokenRefresher>(),
          events: getIt<AppEventBus>(),
        ),
        dispose: (manager) => manager.dispose(),
      );
    }

    if (!getIt.isRegistered<LogoutFlowUseCase>()) {
      getIt.registerFactory<LogoutFlowUseCase>(
        () => LogoutFlowUseCase(
          logoutRemote: getIt<LogoutRemoteUseCase>(),
          pushTokenRevoker: getIt<SessionPushTokenRevoker>(),
          sessionManager: getIt<SessionManager>(),
        ),
      );
    }

    // Presentation
    if (!getIt.isRegistered<LoginCubit>()) {
      getIt.registerFactory<LoginCubit>(
        () => LoginCubit(
          getIt<LoginUserUseCase>(),
          getIt<SignInWithGoogleUseCase>(),
          getIt<SessionManager>(),
          getIt<AnalyticsTracker>(),
        ),
      );
    }

    if (!getIt.isRegistered<EmailVerificationCubit>()) {
      getIt.registerFactory<EmailVerificationCubit>(
        () => EmailVerificationCubit(
          getIt<VerifyEmailUseCase>(),
          getIt<ResendEmailVerificationUseCase>(),
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

    if (!getIt.isRegistered<ChangePasswordCubit>()) {
      getIt.registerFactory<ChangePasswordCubit>(
        () => ChangePasswordCubit(getIt<ChangePasswordUseCase>()),
      );
    }

    if (!getIt.isRegistered<PasswordResetRequestCubit>()) {
      getIt.registerFactory<PasswordResetRequestCubit>(
        () => PasswordResetRequestCubit(getIt<RequestPasswordResetUseCase>()),
      );
    }

    if (!getIt.isRegistered<PasswordResetConfirmCubit>()) {
      getIt.registerFactory<PasswordResetConfirmCubit>(
        () => PasswordResetConfirmCubit(
          getIt<ConfirmPasswordResetUseCase>(),
          getIt<SessionManager>(),
        ),
      );
    }
  }
}

class _AuthRepositoryTokenRefresher implements TokenRefresher {
  _AuthRepositoryTokenRefresher(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<SessionFailure, AuthTokensEntity>> refresh(
    String refreshToken,
  ) async {
    final result = await _repository.refreshToken(
      RefreshRequestEntity(refreshToken: refreshToken),
    );
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
