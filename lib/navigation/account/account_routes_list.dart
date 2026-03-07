import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/cubit/request_account_deletion/request_account_deletion_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/account_deletion/presentation/pages/request_account_deletion_page.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/pages/complete_profile_page.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/cubit/me_sessions/me_sessions_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/pages/me_sessions_page.dart';
import 'package:mobile_core_kit/features/account/subfeatures/security/presentation/pages/security_privacy_page.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/cubit/change_password/change_password_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/credential_management/presentation/pages/change_password_page.dart';
import 'package:mobile_core_kit/navigation/account/account_routes.dart';

final List<GoRoute> accountRoutes = [
  GoRoute(
    path: AccountRoutes.completeProfile,
    name: 'complete-profile',
    builder: (context, state) => BlocProvider<CompleteProfileCubit>(
      create: (_) => locator<CompleteProfileCubit>()..loadDraft(),
      child: const CompleteProfilePage(),
    ),
  ),
  GoRoute(
    path: AccountRoutes.changePassword,
    name: 'change-password',
    builder: (context, state) => BlocProvider<ChangePasswordCubit>(
      create: (_) => locator<ChangePasswordCubit>(),
      child: const ChangePasswordPage(),
    ),
  ),
  GoRoute(
    path: AccountRoutes.securityPrivacy,
    name: 'security-privacy',
    builder: (context, state) =>
        SecurityPrivacyPage(userContext: locator<UserContextService>()),
  ),
  GoRoute(
    path: AccountRoutes.meSessions,
    name: 'me-sessions',
    builder: (context, state) => BlocProvider<MeSessionsCubit>(
      create: (_) => locator<MeSessionsCubit>()..load(),
      child: const MeSessionsPage(),
    ),
  ),
  GoRoute(
    path: AccountRoutes.requestAccountDeletion,
    name: 'request-account-deletion',
    builder: (context, state) => BlocProvider<RequestAccountDeletionCubit>(
      create: (_) => locator<RequestAccountDeletionCubit>(),
      child: RequestAccountDeletionPage(
        userContext: locator<UserContextService>(),
      ),
    ),
  ),
];
