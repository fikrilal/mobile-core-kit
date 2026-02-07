import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/startup/app_startup_controller.dart';
import 'package:mobile_core_kit/navigation/auth/auth_routes.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.startup});

  final AppStartupController startup;

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
              AppText.headlineSmall(context.l10n.onboardingWelcomeTitle),
              const SizedBox(height: AppSpacing.space8),
              AppText.bodyMedium(context.l10n.onboardingPlaceholderBody),
              const Spacer(),
              AppButton.primary(
                text: context.l10n.commonContinue,
                isExpanded: true,
                semanticLabel: context.l10n.onboardingSemanticContinue,
                onPressed: () async {
                  await startup.completeOnboarding();
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
