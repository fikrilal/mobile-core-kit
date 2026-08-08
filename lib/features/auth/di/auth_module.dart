import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/core/domain/session/session_push_token_revoker.dart';
import 'package:mobile_core_kit/core/domain/session/token_refresher.dart';
import 'package:mobile_core_kit/core/infra/network/api/api_helper.dart';
import 'package:mobile_core_kit/core/platform/device_identity/device_identity_service.dart';
import 'package:mobile_core_kit/core/platform/federated_auth/google_federated_auth_service.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/runtime/session/session_manager.dart';
import 'package:mobile_core_kit/features/auth/adapters/auth_token_refresher_adapter.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:mobile_core_kit/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mobile_core_kit/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/confirm_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/login_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_flow_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/register_user_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/request_password_reset_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/resend_email_verification_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/sign_in_with_google_usecase.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/verify_email_usecase.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/password_recovery/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/registration/presentation/cubit/register/register_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_cubit.dart';

class AuthModule {
  static void register(GetIt getIt) {
    _registerData(getIt);
    _registerUseCases(getIt);
    _registerSessionIntegration(getIt);
    _registerPresentation(getIt);
  }
}

void _registerData(GetIt getIt) {
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<ApiHelper>()),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<GoogleFederatedAuthService>(),
        getIt<DeviceIdentityService>(),
      ),
    );
  }
}

void _registerUseCases(GetIt getIt) {
  if (!getIt.isRegistered<LoginUserUseCase>()) {
    getIt.registerFactory<LoginUserUseCase>(
      () => LoginUserUseCase(getIt<AuthRepository>()),
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
}

void _registerSessionIntegration(GetIt getIt) {
  if (!getIt.isRegistered<TokenRefresher>()) {
    getIt.registerFactory<TokenRefresher>(
      () => AuthTokenRefresherAdapter(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<LogoutFlowUseCase>()) {
    getIt.registerFactory<LogoutFlowUseCase>(
      () => LogoutFlowUseCase(
        authRepository: getIt<AuthRepository>(),
        pushTokenRevoker: getIt<SessionPushTokenRevoker>(),
        session: getIt<SessionManager>(),
      ),
    );
  }
}

void _registerPresentation(GetIt getIt) {
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
