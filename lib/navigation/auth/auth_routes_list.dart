import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/widgets/button/button_showcase_screen.dart';
import '../../core/widgets/field/field_showcase_screen.dart';
import '../../features/auth/presentation/cubit/login/login_cubit.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import 'auth_routes.dart';

/// Auth feature routes (minimal: sign-in only for the boilerplate).
final List<GoRoute> authRoutes = [
  GoRoute(
    path: AuthRoutes.signIn,
    builder: (_, __) => BlocProvider<LoginCubit>(
      create: (_) => locator<LoginCubit>(),
      child: const ButtonShowcaseScreen(),
    ),
  ),
];
