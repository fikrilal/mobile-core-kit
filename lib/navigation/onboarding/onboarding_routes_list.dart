import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import 'onboarding_routes.dart';

final List<GoRoute> onboardingRoutes = [
  GoRoute(
    path: OnboardingRoutes.onboarding,
    builder: (context, state) => const OnboardingPage(),
  ),
];

