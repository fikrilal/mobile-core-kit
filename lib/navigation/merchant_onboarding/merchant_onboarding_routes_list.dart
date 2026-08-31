import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_cubit.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart';
import 'package:mobile_core_kit/navigation/merchant_onboarding/merchant_onboarding_routes.dart';

/// Isolated GoRouter route for the merchant-onboarding demo. The route owns
/// the feature Cubit; reference data loads on entry.
final List<GoRoute> merchantOnboardingRoutes = [
  GoRoute(
    path: MerchantOnboardingRoutes.root,
    builder: (context, state) => BlocProvider<MerchantOnboardingCubit>(
      create: (_) => locator<MerchantOnboardingCubit>(),
      child: const MerchantOnboardingPage(),
    ),
  ),
];
