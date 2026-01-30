import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/widgets/navigation/pending_deep_link_cancel_on_pop.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/email_verification/email_verification_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_confirm/password_reset_confirm_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/password_reset_request/password_reset_request_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/password_reset_confirm_page.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/password_reset_request_page.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/register_page.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/verify_email_page.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

/// Auth feature routes (minimal: sign-in only for the boilerplate).
final List<GoRoute> authRoutes = [
  GoRoute(
    path: AuthRoutes.signIn,
    builder: (context, state) => PendingDeepLinkCancelOnPop(
      deepLinks: locator<PendingDeepLinkController>(),
      child: BlocProvider<LoginCubit>(
        create: (_) => locator<LoginCubit>(),
        child: const SignInPage(),
      ),
    ),
  ),
  GoRoute(
    path: AuthRoutes.register,
    builder: (context, state) => PendingDeepLinkCancelOnPop(
      deepLinks: locator<PendingDeepLinkController>(),
      clearWhenCanPop: false,
      child: BlocProvider<RegisterCubit>(
        create: (_) => locator<RegisterCubit>(),
        child: const RegisterPage(),
      ),
    ),
  ),
  GoRoute(
    path: AuthRoutes.passwordResetRequest,
    builder: (context, state) => PendingDeepLinkCancelOnPop(
      deepLinks: locator<PendingDeepLinkController>(),
      clearWhenCanPop: false,
      child: BlocProvider<PasswordResetRequestCubit>(
        create: (_) => locator<PasswordResetRequestCubit>(),
        child: const PasswordResetRequestPage(),
      ),
    ),
  ),
  GoRoute(
    path: AuthRoutes.passwordResetConfirm,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];

      return BlocProvider<PasswordResetConfirmCubit>(
        create: (_) {
          final cubit = locator<PasswordResetConfirmCubit>();
          cubit.tokenChanged(token ?? '');
          return cubit;
        },
        child: const PasswordResetConfirmPage(),
      );
    },
  ),
  GoRoute(
    path: AuthRoutes.verifyEmail,
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      final startup = locator<AppStartupController>();

      return BlocProvider<EmailVerificationCubit>(
        create: (_) {
          final cubit = locator<EmailVerificationCubit>();
          cubit.tokenChanged(token ?? '');
          unawaited(cubit.verify());
          return cubit;
        },
        child: VerifyEmailPage(
          canResendVerificationEmail: startup.isAuthenticated,
        ),
      );
    },
  ),
];
