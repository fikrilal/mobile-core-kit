import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountMainSection extends StatelessWidget {
  const AccountMainSection({
    super.key,
    required this.sectionSpacing,
    required this.onInboxTap,
    required this.onHelpTap,
    required this.onStatementsTap,
  });

  final double sectionSpacing;
  final VoidCallback onInboxTap;
  final VoidCallback onHelpTap;
  final VoidCallback onStatementsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: sectionSpacing),
        AppText.titleLarge(context.l10n.profileYourAccountHeading),
        const SizedBox(height: AppSpacing.space8),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.bell,
              size: AppSizing.iconSizeMedium,
            ),
            showDot: true,
          ),
          title: context.l10n.profileInbox,
          onTap: onInboxTap,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.question,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileHelp,
          onTap: onHelpTap,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.fileText,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileStatementsAndReports,
          onTap: onStatementsTap,
        ),
      ],
    );
  }
}
