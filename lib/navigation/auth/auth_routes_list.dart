import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/deep_link/pending_deep_link_controller.dart';
import '../../core/widgets/navigation/pending_deep_link_cancel_on_pop.dart';
import '../../features/auth/presentation/cubit/login/login_cubit.dart';
import '../../features/auth/presentation/cubit/register/register_cubit.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import 'auth_routes.dart';

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
];
