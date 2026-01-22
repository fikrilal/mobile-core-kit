import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/services/user_context/current_user_state.dart';
import 'package:mobile_core_kit/core/services/user_context/user_context_service.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/avatar/app_avatar.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/features/profile/presentation/widgets/locale_setting_tile.dart';
import 'package:mobile_core_kit/features/profile/presentation/widgets/theme_mode_setting_tile.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = context.select(
      (LogoutCubit c) => c.state.isSubmitting,
    );
    return BlocListener<LogoutCubit, LogoutState>(
      listenWhen: (prev, curr) =>
          prev.failure != curr.failure && curr.failure != null,
      listener: (context, state) {
        AppSnackBar.showError(
          context,
          message: messageForLogoutFailure(state.failure!, context.l10n),
        );
      },
      child: AppLoadingOverlay(
        isLoading: isLoggingOut,
        message: context.l10n.profileLoggingOut,
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
    final userContext = locator<UserContextService>();

    return AppPageContainer(
      surface: SurfaceKind.settings,
      safeArea: true,
      child: Padding(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ValueListenableBuilder<CurrentUserState>(
                  valueListenable: userContext.stateListenable,
                  builder: (context, state, _) {
                    final displayName = userContext.displayName;
                    final email = userContext.email;
                    final hasDisplayName =
                        displayName != null && displayName.trim().isNotEmpty;
                    final showEmail =
                        hasDisplayName &&
                        email != null &&
                        email.trim().isNotEmpty &&
                        email.trim() != displayName.trim();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [AppAvatar(onChangePhoto: () {})],
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        if (hasDisplayName) AppText.headlineMedium(displayName),
                        if (showEmail) ...[
                          const SizedBox(height: AppSpacing.space4),
                          AppText.bodyMedium(email),
                        ] else if (displayName == null &&
                            email != null &&
                            email.trim().isNotEmpty)
                          AppText.headlineMedium(email),
                        if (state.isAuthPending) ...[
                          const SizedBox(height: AppSpacing.space4),
                          AppText.bodySmall(context.l10n.commonLoading),
                        ],
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: sectionSpacing),
              AppText.titleLarge(context.l10n.profileYourAccountHeading),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.bell, size: 24),
                  showDot: true,
                ),
                title: context.l10n.profileInbox,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.question, size: 24),
                ),
                title: context.l10n.profileHelp,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.fileText, size: 24),
                ),
                title: context.l10n.profileStatementsAndReports,
                onTap: () {},
              ),
              SizedBox(height: sectionSpacing),

              // Settings Section
              AppText.titleLarge(context.l10n.commonSettings),
              const SizedBox(height: AppSpacing.space8),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.shieldCheck,
                    size: 24,
                  ),
                ),
                title: context.l10n.profileSecurityAndPrivacy,
                subtitle: context.l10n.profileSecurityAndPrivacySubtitle,
                onTap: () {},
              ),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.bellRinging,
                    size: 24,
                  ),
                ),
                title: context.l10n.profileNotifications,
                subtitle: context.l10n.profileNotificationsSubtitle,
                onTap: () {},
              ),
              const ThemeModeSettingTile(),
              LocaleSettingTile(includePseudoLocales: showDevTools),
              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.bank, size: 24),
                ),
                title: context.l10n.profilePaymentMethods,
                subtitle: context.l10n.profilePaymentMethodsSubtitle,
                onTap: () {},
              ),
              if (showDevTools) ...[
                SizedBox(height: sectionSpacing),
                AppText.titleLarge(context.l10n.commonDeveloper),
                const SizedBox(height: AppSpacing.space8),
                AppListTile(
                  leading: AppIconBadge(
                    icon: PhosphorIcon(PhosphorIconsRegular.palette, size: 24),
                  ),
                  title: context.l10n.profileThemeRoles,
                  subtitle: context.l10n.profileThemeRolesSubtitle,
                  onTap: () => context.push(DevToolsRoutes.themeRoles),
                ),
                AppListTile(
                  leading: AppIconBadge(
                    icon: PhosphorIcon(PhosphorIconsRegular.cube, size: 24),
                  ),
                  title: context.l10n.profileWidgetShowcases,
                  subtitle: context.l10n.profileWidgetShowcasesSubtitle,
                  onTap: () => context.push(DevToolsRoutes.widgetShowcases),
                ),
              ],
              SizedBox(height: sectionSpacing),

              AppListTile(
                leading: AppIconBadge(
                  icon: PhosphorIcon(PhosphorIconsRegular.signOut, size: 24),
                  iconColor: Theme.of(context).colorScheme.error,
                ),
                title: context.l10n.commonLogout,
                showChevron: false,
                enabled: !isLoggingOut,
                onTap: () async {
                  final confirmed = await showAppConfirmationDialog(
                    context: context,
                    title: context.l10n.profileLogoutDialogTitle,
                    message: context.l10n.profileLogoutDialogMessage,
                    confirmLabel: context.l10n.commonLogout,
                    cancelLabel: context.l10n.commonCancel,
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
