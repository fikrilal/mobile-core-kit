import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/services/deep_link/pending_deep_link_controller.dart';
import 'package:mobile_core_kit/core/widgets/navigation/pending_deep_link_cancel_on_pop.dart';
import 'package:mobile_core_kit/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_core_kit/navigation/onboarding/onboarding_routes.dart';

final List<GoRoute> onboardingRoutes = [
  GoRoute(
    path: OnboardingRoutes.onboarding,
    builder: (context, state) => PendingDeepLinkCancelOnPop(
      deepLinks: locator<PendingDeepLinkController>(),
      child: OnboardingPage(startup: locator<AppStartupController>()),
    ),
  ),
];
