import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/services/app_startup/app_startup_controller.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/theme/responsive/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/button/button.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPageContainer(
        surface: SurfaceKind.reading,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space24),
              const AppText.headlineSmall('Welcome'),
              const SizedBox(height: AppSpacing.space8),
              const AppText.bodyMedium(
                'This is the onboarding placeholder. Projects can replace this with a branded onboarding flow.',
              ),
              const Spacer(),
              AppButton.primary(
                text: 'Continue',
                isExpanded: true,
                semanticLabel: 'Continue onboarding',
                onPressed: () async {
                  await locator<AppStartupController>().completeOnboarding();
                  if (!context.mounted) return;
                  context.go(AuthRoutes.signIn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
