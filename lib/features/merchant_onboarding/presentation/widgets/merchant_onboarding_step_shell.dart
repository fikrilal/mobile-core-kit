import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/merchant_onboarding/presentation/cubit/merchant_onboarding/merchant_onboarding_state.dart';

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
    final theme = Theme.of(context);
    final stepTitle = switch (step) {
      MerchantOnboardingStep.business => l10n.merchantOnboardingStepBusiness,
      MerchantOnboardingStep.owners => l10n.merchantOnboardingStepOwners,
      MerchantOnboardingStep.settlement =>
        l10n.merchantOnboardingStepSettlement,
      MerchantOnboardingStep.review => l10n.merchantOnboardingStepReview,
    };

    return AppPageContainer(
      surface: SurfaceKind.form,
      safeArea: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.space16,
              bottom: AppSpacing.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySmall(
                  l10n.merchantOnboardingStepOf(
                    current: currentStep,
                    total: totalSteps,
                  ),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.space4),
                AppText.headlineSmall(stepTitle),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
              child: child,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
              child: Row(
                children: [
                  if (canGoBack) ...[
                    Expanded(
                      child: AppButton.secondary(
                        text: l10n.merchantOnboardingActionBack,
                        isDisabled: isSubmitting,
                        onPressed: onBack,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                  ],
                  Expanded(
                    flex: canGoBack ? 2 : 1,
                    child: AppButton.primary(
                      text: isLastStep
                          ? l10n.merchantOnboardingActionSubmit
                          : l10n.merchantOnboardingActionNext,
                      isExpanded: true,
                      isLoading: isSubmitting,
                      isDisabled: !canSubmit,
                      onPressed: onNext,
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
