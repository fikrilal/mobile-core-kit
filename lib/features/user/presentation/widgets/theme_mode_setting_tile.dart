import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/design_system/localization/l10n.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/sizing.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/runtime/appearance/theme_mode_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ThemeModeSettingTile extends StatelessWidget {
  const ThemeModeSettingTile({super.key, required this.controller});

  final ThemeModeController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, themeMode, _) {
        return AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(
              PhosphorIconsRegular.moonStars,
              size: AppSizing.iconSizeMedium,
            ),
          ),
          title: context.l10n.commonAppearance,
          subtitle: _themeModeLabel(context, themeMode),
          onTap: () async {
            final selected = await showAdaptiveModal<ThemeMode>(
              context: context,
              builder: (_) => _ThemeModePicker(initialThemeMode: themeMode),
            );
            if (selected == null) return;
            await controller.setThemeMode(selected);
          },
        );
      },
    );
  }
}

String _themeModeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.system => context.l10n.commonSystem,
  ThemeMode.light => context.l10n.commonLight,
  ThemeMode.dark => context.l10n.commonDark,
};

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    void selectThemeMode(ThemeMode mode) => Navigator.of(context).pop(mode);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: RadioGroup<ThemeMode>(
        groupValue: initialThemeMode,
        onChanged: (value) {
          if (value == null) return;
          selectThemeMode(value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.titleLarge(context.l10n.commonTheme),
            const SizedBox(height: AppSpacing.space8),
            _ThemeModeOptionTile(
              title: context.l10n.commonSystem,
              subtitle: context.l10n.settingsFollowDeviceAppearance,
              value: ThemeMode.system,
              groupValue: initialThemeMode,
              onSelected: selectThemeMode,
            ),
            _ThemeModeOptionTile(
              title: context.l10n.commonLight,
              value: ThemeMode.light,
              groupValue: initialThemeMode,
              onSelected: selectThemeMode,
            ),
            _ThemeModeOptionTile(
              title: context.l10n.commonDark,
              value: ThemeMode.dark,
              groupValue: initialThemeMode,
              onSelected: selectThemeMode,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeOptionTile extends StatelessWidget {
  const _ThemeModeOptionTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onSelected,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      showChevron: false,
      onTap: () => onSelected(value),
      trailing: Radio<ThemeMode>(value: value),
    );
  }
}
