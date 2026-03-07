import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountDeveloperSection extends StatelessWidget {
  const AccountDeveloperSection({
    super.key,
    required this.sectionSpacing,
    required this.onThemeRolesTap,
    required this.onWidgetShowcasesTap,
  });

  final double sectionSpacing;
  final VoidCallback onThemeRolesTap;
  final VoidCallback onWidgetShowcasesTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: sectionSpacing),
        AppText.titleLarge(context.l10n.commonDeveloper),
        const SizedBox(height: AppSpacing.space8),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.palette,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileThemeRoles,
          subtitle: context.l10n.profileThemeRolesSubtitle,
          onTap: onThemeRolesTap,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.cube,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileWidgetShowcases,
          subtitle: context.l10n.profileWidgetShowcasesSubtitle,
          onTap: onWidgetShowcasesTap,
        ),
      ],
    );
  }
}
