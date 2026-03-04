import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/pages/change_password_page.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/pages/complete_profile_page.dart';
import 'package:mobile_core_kit/features/user/presentation/pages/request_account_deletion_page.dart';
import 'package:mobile_core_kit/features/user/presentation/pages/security_privacy_page.dart';
import 'package:mobile_core_kit/navigation/user/user_routes.dart';

final List<GoRoute> userRoutes = [
  GoRoute(
    path: UserRoutes.completeProfile,
    name: 'complete-profile',
    builder: (context, state) => BlocProvider<CompleteProfileCubit>(
      create: (_) => locator<CompleteProfileCubit>()..loadDraft(),
      child: const CompleteProfilePage(),
    ),
  ),
  GoRoute(
    path: UserRoutes.changePassword,
    name: 'change-password',
    builder: (context, state) => BlocProvider<ChangePasswordCubit>(
      create: (_) => locator<ChangePasswordCubit>(),
      child: const ChangePasswordPage(),
    ),
  ),
  GoRoute(
    path: UserRoutes.securityPrivacy,
    name: 'security-privacy',
    builder: (context, state) =>
        SecurityPrivacyPage(userContext: locator<UserContextService>()),
  ),
  GoRoute(
    path: UserRoutes.requestAccountDeletion,
    name: 'request-account-deletion',
    builder: (context, state) => BlocProvider<RequestAccountDeletionCubit>(
      create: (_) => locator<RequestAccountDeletionCubit>(),
      child: RequestAccountDeletionPage(
        userContext: locator<UserContextService>(),
      ),
    ),
  ),
];
