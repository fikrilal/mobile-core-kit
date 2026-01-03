import 'package:go_router/go_router.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/deep_link/pending_deep_link_controller.dart';
import '../../core/widgets/navigation/pending_deep_link_cancel_on_pop.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import 'onboarding_routes.dart';

final List<GoRoute> onboardingRoutes = [
  GoRoute(
    path: OnboardingRoutes.onboarding,
    builder: (context, state) => PendingDeepLinkCancelOnPop(
      deepLinks: locator<PendingDeepLinkController>(),
      child: const OnboardingPage(),
    ),
  ),
];
