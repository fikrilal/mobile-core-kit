import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/runtime/localization/locale_controller.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/locale_setting_tile.dart';
import 'package:mobile_core_kit/features/account/presentation/widgets/theme_mode_setting_tile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({
    super.key,
    required this.showDevTools,
    required this.themeModeController,
    required this.localeController,
    required this.onSecurityPrivacyTap,
    required this.onNotificationsTap,
    required this.onChangeProfilePhotoTap,
    required this.onPaymentMethodsTap,
  });

  final bool showDevTools;
  final ThemeModeController themeModeController;
  final LocaleController localeController;
  final VoidCallback onSecurityPrivacyTap;
  final VoidCallback onNotificationsTap;
  final Future<void> Function() onChangeProfilePhotoTap;
  final VoidCallback onPaymentMethodsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleLarge(context.l10n.commonSettings),
        const SizedBox(height: AppSpacing.space8),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.shieldCheck,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileSecurityAndPrivacy,
          subtitle: context.l10n.profileSecurityAndPrivacySubtitle,
          onTap: onSecurityPrivacyTap,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.bellRinging,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profileNotifications,
          subtitle: context.l10n.profileNotificationsSubtitle,
          onTap: onNotificationsTap,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.userCircle,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.commonChangeProfilePhoto,
          onTap: onChangeProfilePhotoTap,
        ),
        ThemeModeSettingTile(controller: themeModeController),
        LocaleSettingTile(
          includePseudoLocales: showDevTools,
          controller: localeController,
        ),
        AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.bank,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.profilePaymentMethods,
          subtitle: context.l10n.profilePaymentMethodsSubtitle,
          onTap: onPaymentMethodsTap,
        ),
      ],
    );
  }
}
