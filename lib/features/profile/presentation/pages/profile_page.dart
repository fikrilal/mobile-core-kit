import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/adaptive/adaptive_context.dart';
import '../../../../core/adaptive/tokens/surface_tokens.dart';
import '../../../../core/adaptive/widgets/app_page_container.dart';
import '../../../../core/adaptive/widgets/adaptive_modal.dart';
import '../../../../core/theme/typography/components/text.dart';
import '../../../../core/widgets/button/app_button.dart';
import '../../../../core/widgets/button/button_variants.dart';
import '../../../../core/widgets/dialog/app_confirmation_dialog.dart';
import '../../../../core/widgets/loading/loading.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../auth/presentation/cubit/logout/logout_cubit.dart';
import '../../../auth/presentation/cubit/logout/logout_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = context.select(
      (LogoutCubit c) => c.state.isSubmitting,
    );
    return BlocListener<LogoutCubit, LogoutState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        AppSnackBar.showError(context, message: state.errorMessage!);
      },
      child: AppLoadingOverlay(
        isLoading: isLoggingOut,
        message: 'Logging out...',
        child: _ProfileContent(isLoggingOut: isLoggingOut),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.isLoggingOut});

  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;
    final sectionSpacing = layout.gutter * 3;
    final showDevTools = BuildConfig.env == BuildEnv.dev;
    final themeModeController = locator<ThemeModeController>();

    return AppPageContainer(
      surface: SurfaceKind.settings,
      safeArea: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.headlineMedium('Your account'),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.bell, size: 24),
                  showDot: true,
                ),
                title: 'Inbox',
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.question, size: 24),
                ),
                title: 'Help',
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.fileText, size: 24),
                ),
                title: 'Statements and reports',
                onTap: () {},
              ),
              SizedBox(height: sectionSpacing),
          
              // Settings Section
              const AppText.headlineMedium('Settings'),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.shieldCheck, size: 24),
                ),
                title: 'Security and privacy',
                subtitle: 'Change your security and privacy settings',
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.bellRinging, size: 24),
                ),
                title: 'Notifications',
                subtitle: 'Customise how you get updates',
                onTap: () {},
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeController,
                builder: (context, themeMode, _) {
                  return AppListTile(
                    leading: AppIconBadge(
                      icon: PhosphorIcon(
                        PhosphorIconsRegular.moonStars,
                        size: 24,
                      ),
                    ),
                    title: 'Appearance',
                    subtitle: _themeModeLabel(themeMode),
                    onTap: () async {
                      final selected = await showAdaptiveModal<ThemeMode>(
                        context: context,
                        builder: (_) =>
                            _ThemeModePicker(initialThemeMode: themeMode),
                      );
                      if (selected == null) return;
                      await themeModeController.setThemeMode(selected);
                    },
                  );
                },
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.bank, size: 24),
                ),
                title: 'Payment methods',
                subtitle: 'Manage saved cards and bank accounts',
                onTap: () {},
              ),
              if (showDevTools) ...[
                SizedBox(height: sectionSpacing),
                const AppText.headlineMedium('Developer'),
                const SizedBox(height: AppSpacing.space8),
                AppListTile(
                  leading: AppIconBadge(
                    icon: PhosphorIcon(PhosphorIconsRegular.palette, size: 24),
                  ),
                  title: 'Theme roles',
                  subtitle: 'View ColorScheme + SemanticColors roles',
                  onTap: () => context.push(DevToolsRoutes.themeRoles),
                ),
              ],
              SizedBox(height: sectionSpacing),
          
              // Logout Button
              AppButton(
                text: 'Log out',
                variant: ButtonVariant.danger,
                isLoading: isLoggingOut,
                isDisabled: isLoggingOut,
                onPressed: isLoggingOut
                    ? null
                    : () async {
                        final confirmed = await showAppConfirmationDialog(
                          context: context,
                          title: 'Log out?',
                          message:
                              'You will need to sign in again to continue. This will also revoke your sessions on other devices.',
                          confirmLabel: 'Log out',
                          cancelLabel: 'Cancel',
                          variant: AppConfirmationDialogVariant.standard,
                        );
          
                        if (confirmed != true) return;
                        if (!context.mounted) return;
                        await context.read<LogoutCubit>().logout();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: RadioGroup<ThemeMode>(
        groupValue: initialThemeMode,
        onChanged: (value) => Navigator.of(context).pop(value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: AppText.titleLarge('Theme')),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            const RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              title: Text('System'),
              subtitle: Text('Follow device appearance'),
            ),
            const RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              title: Text('Light'),
            ),
            const RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              title: Text('Dark'),
            ),
          ],
        ),
      ),
    );
  }
}
