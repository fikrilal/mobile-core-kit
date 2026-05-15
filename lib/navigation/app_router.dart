import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/foundation/config/build_config.dart';
import 'package:mobile_core_kit/core/platform/media/image_picker_service.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_route_observer.dart';
import 'package:mobile_core_kit/core/runtime/analytics/analytics_tracker.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/runtime/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/runtime/navigation/deep_link_parser.dart';
import 'package:mobile_core_kit/core/runtime/navigation/navigation_service.dart';
import 'package:mobile_core_kit/core/runtime/navigation/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/runtime/user_context/user_context_service.dart';
import 'package:mobile_core_kit/features/account/presentation/pages/account_page.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_effect.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/features/auth/subfeatures/sign_out/presentation/localization/logout_failure_localizer.dart';
import 'package:mobile_core_kit/features/home/presentation/pages/home_page.dart';
import 'package:mobile_core_kit/navigation/account/account_routes_list.dart';
import 'package:mobile_core_kit/navigation/app_redirect.dart';
import 'package:mobile_core_kit/navigation/app_routes.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes_list.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes_list.dart';
import 'package:mobile_core_kit/navigation/onboarding/onboarding_routes_list.dart';
import 'package:mobile_core_kit/navigation/shell/app_shell_page.dart';

/// Builds the global [GoRouter] used by the app.
///
/// The boilerplate starts with a minimal bottom-tab shell so navigation is not
/// empty. Feature modules can extend this by exposing their own `List<GoRoute>`
/// and combining them here.
GoRouter createRouter() {
  final navigation = locator<NavigationService>();
  final analyticsTracker = locator<AnalyticsTracker>();
  final startup = locator<AppStartupController>();
  final deepLinks = locator<PendingDeepLinkController>();
  final deepLinkParser = locator<DeepLinkParser>();
  return GoRouter(
    navigatorKey: navigation.rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    observers: [AnalyticsRouteObserver(analyticsTracker)],
    refreshListenable: Listenable.merge([startup, deepLinks]),
    redirect: (context, state) =>
        appRedirect(state, startup, deepLinks, deepLinkParser),
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: 'root',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider<LogoutCubit>(
                      create: (_) => locator<LogoutCubit>(),
                    ),
                    BlocProvider<ProfileImageCubit>(
                      create: (_) => locator<ProfileImageCubit>()..loadAvatar(),
                    ),
                  ],
                  child: const _AccountRoutePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      if (BuildConfig.env == BuildEnv.dev) ...devToolsRoutes,
      ...authRoutes,
      ...onboardingRoutes,
      ...accountRoutes,
    ],
  );
}

class _AccountRoutePage extends StatefulWidget {
  const _AccountRoutePage();

  @override
  State<_AccountRoutePage> createState() => _AccountRoutePageState();
}

class _AccountRoutePageState extends State<_AccountRoutePage> {
  StreamSubscription<LogoutEffect>? _logoutEffectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logoutEffectSubscription ??= context.read<LogoutCubit>().effects.listen(
      _handleLogoutEffect,
    );
  }

  void _handleLogoutEffect(LogoutEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case LogoutFailureEffect(:final failure):
        AppSnackBar.showError(
          context,
          message: messageForLogoutFailure(failure, context.l10n),
        );
    }
  }

  @override
  void dispose() {
    unawaited(_logoutEffectSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogoutCubit, LogoutState>(
      builder: (context, logoutState) {
        return AccountPage(
          userContext: locator<UserContextService>(),
          themeModeController: locator<ThemeModeController>(),
          localeController: locator<LocaleController>(),
          imagePicker: locator<ImagePickerService>(),
          isLoggingOut: logoutState.isSubmitting,
          onLogout: () => context.read<LogoutCubit>().logout(),
        );
      },
    );
  }
}
