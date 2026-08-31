import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';

/// Shared shell for the four merchant-onboarding steps: progress header,
/// scrollable step content, and Back/Next/Submit actions.
class MerchantOnboardingStepShell extends StatelessWidget {
  const MerchantOnboardingStepShell({
    super.key,
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.canGoBack,
    required this.canSubmit,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
    required this.child,
  });

  final MerchantOnboardingStep step;
  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final bool canGoBack;
  final bool canSubmit;
  final bool isLastStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stepTitle = switch (step) {
      MerchantOnboardingStep.business => l10n.merchantOnboardingStepBusiness,
      MerchantOnboardingStep.owners => l10n.merchantOnboardingStepOwners,
      MerchantOnboardingStep.settlement =>
        l10n.merchantOnboardingStepSettlement,
      MerchantOnboardingStep.review => l10n.merchantOnboardingStepReview,
    };

    return AppPageContainer(
      surface: SurfaceKind.dashboard,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space16,
              AppSpacing.space12,
              AppSpacing.space16,
              AppSpacing.space4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleMedium(stepTitle),
                const SizedBox(height: AppSpacing.space4),
                AppText.bodySmall(
                  l10n.merchantOnboardingStepOf(
                    current: currentStep,
                    total: totalSteps,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: child,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space16,
                AppSpacing.space8,
                AppSpacing.space16,
                AppSpacing.space16,
              ),
              child: Row(
                children: [
                  if (canGoBack)
                    AppButton.secondary(
                      text: l10n.merchantOnboardingActionBack,
                      onPressed: isSubmitting ? null : onBack,
                    ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: isLastStep
                        ? AppButton.primary(
                            text: l10n.merchantOnboardingActionSubmit,
                            isExpanded: true,
                            isLoading: isSubmitting,
                            isDisabled: !canSubmit,
                            onPressed: isSubmitting ? null : onNext,
                          )
                        : AppButton.primary(
                            text: l10n.merchantOnboardingActionNext,
                            isExpanded: true,
                            onPressed: isSubmitting ? null : onNext,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
