import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/navigation/merchant_onboarding/merchant_onboarding_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageContainer(
      surface: SurfaceKind.dashboard,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.titleLarge(
            context.l10n.commonHome,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton.primary(
            text: context.l10n.merchantOnboardingHomeEntry,
            isExpanded: true,
            onPressed: () => context.push(MerchantOnboardingRoutes.root),
          ),
        ],
      ),
    );
  }
}
