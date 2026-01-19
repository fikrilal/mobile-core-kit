import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_context.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/configs/build_config.dart';
import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/services/appearance/theme_mode_controller.dart';
import 'package:mobile_core_kit/core/services/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/avatar/app_avatar.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/widgets/button/button_variants.dart';
import 'package:mobile_core_kit/core/widgets/dialog/app_confirmation_dialog.dart';
import 'package:mobile_core_kit/core/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/core/widgets/loading/loading.dart';
import 'package:mobile_core_kit/core/widgets/snackbar/app_snackbar.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_cubit.dart';
import 'package:mobile_core_kit/features/auth/presentation/cubit/logout/logout_state.dart';
import 'package:mobile_core_kit/features/auth/presentation/localization/auth_failure_localizer.dart';
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
    final themeModeController = locator<ThemeModeController>();
    final localeController = locator<LocaleController>();

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [AppAvatar(onChangePhoto: () {})],
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppText.headlineMedium('Ahmad Fikril Al Muzakki'),
                  ],
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
                    title: context.l10n.commonAppearance,
                    subtitle: _themeModeLabel(context, themeMode),
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
              ValueListenableBuilder<Locale?>(
                valueListenable: localeController,
                builder: (context, localeOverride, _) {
                  return AppListTile(
                    leading: AppIconBadge(
                      icon: PhosphorIcon(
                        PhosphorIconsRegular.translate,
                        size: 24,
                      ),
                    ),
                    title: context.l10n.commonLanguage,
                    subtitle: _localeLabel(context, localeOverride),
                    onTap: () async {
                      final selected = await showAdaptiveModal<_LocaleOption>(
                        context: context,
                        builder: (_) => _LocalePicker(
                          initialOption: _localeToOption(
                            localeOverride,
                            includePseudo: showDevTools,
                          ),
                          includePseudo: showDevTools,
                        ),
                      );
                      if (selected == null) return;
                      await localeController.setLocale(
                        _localeFromOption(selected),
                      );
                    },
                  );
                },
              ),
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

              // Logout Button
              AppButton(
                text: context.l10n.commonLogout,
                variant: ButtonVariant.danger,
                isLoading: isLoggingOut,
                isDisabled: isLoggingOut,
                onPressed: isLoggingOut
                    ? null
                    : () async {
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

String _themeModeLabel(BuildContext context, ThemeMode mode) => switch (mode) {
  ThemeMode.system => context.l10n.commonSystem,
  ThemeMode.light => context.l10n.commonLight,
  ThemeMode.dark => context.l10n.commonDark,
};

String _localeLabel(BuildContext context, Locale? locale) {
  if (locale == null) return context.l10n.commonSystem;

  final language = locale.languageCode.toLowerCase();
  final country = locale.countryCode?.toUpperCase();

  return switch ((language, country)) {
    ('en', null) => context.l10n.languageEnglish,
    ('id', null) => context.l10n.languageIndonesian,
    ('en', 'XA') => context.l10n.devPseudoLocaleEnXa,
    ('ar', 'XB') => context.l10n.devPseudoLocaleArXb,
    _ => context.l10n.commonSystem,
  };
}

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

enum _LocaleOption { system, en, id, enXa, arXb }

Locale? _localeFromOption(_LocaleOption option) => switch (option) {
  _LocaleOption.system => null,
  _LocaleOption.en => const Locale('en'),
  _LocaleOption.id => const Locale('id'),
  _LocaleOption.enXa => const Locale('en', 'XA'),
  _LocaleOption.arXb => const Locale('ar', 'XB'),
};

_LocaleOption _localeToOption(Locale? locale, {required bool includePseudo}) {
  if (locale == null) return _LocaleOption.system;

  final language = locale.languageCode.toLowerCase();
  final country = locale.countryCode?.toUpperCase();

  if (language == 'en' && (country == null || country.isEmpty)) {
    return _LocaleOption.en;
  }
  if (language == 'id' && (country == null || country.isEmpty)) {
    return _LocaleOption.id;
  }

  if (!includePseudo) return _LocaleOption.system;

  if (language == 'en' && country == 'XA') return _LocaleOption.enXa;
  if (language == 'ar' && country == 'XB') return _LocaleOption.arXb;

  return _LocaleOption.system;
}

class _LocalePicker extends StatelessWidget {
  const _LocalePicker({
    required this.initialOption,
    required this.includePseudo,
  });

  final _LocaleOption initialOption;
  final bool includePseudo;

  @override
  Widget build(BuildContext context) {
    void select(_LocaleOption option) => Navigator.of(context).pop(option);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: RadioGroup<_LocaleOption>(
        groupValue: initialOption,
        onChanged: (value) {
          if (value == null) return;
          select(value);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.titleLarge(context.l10n.commonLanguage),
            const SizedBox(height: AppSpacing.space8),
            _LocaleOptionTile(
              title: context.l10n.commonSystem,
              subtitle: context.l10n.settingsFollowDeviceLanguage,
              value: _LocaleOption.system,
              groupValue: initialOption,
              onSelected: select,
            ),
            _LocaleOptionTile(
              title: context.l10n.languageEnglish,
              value: _LocaleOption.en,
              groupValue: initialOption,
              onSelected: select,
            ),
            _LocaleOptionTile(
              title: context.l10n.languageIndonesian,
              value: _LocaleOption.id,
              groupValue: initialOption,
              onSelected: select,
            ),
            if (includePseudo) ...[
              const SizedBox(height: AppSpacing.space8),
              AppText.labelLarge(context.l10n.devDeveloperQa),
              const SizedBox(height: AppSpacing.space8),
              _LocaleOptionTile(
                title: context.l10n.devPseudoLocaleEnXa,
                subtitle: context.l10n.devPseudoLocaleEnXaSubtitle,
                value: _LocaleOption.enXa,
                groupValue: initialOption,
                onSelected: select,
              ),
              _LocaleOptionTile(
                title: context.l10n.devPseudoLocaleArXb,
                subtitle: context.l10n.devPseudoLocaleArXbSubtitle,
                value: _LocaleOption.arXb,
                groupValue: initialOption,
                onSelected: select,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocaleOptionTile extends StatelessWidget {
  const _LocaleOptionTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onSelected,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final _LocaleOption value;
  final _LocaleOption groupValue;
  final ValueChanged<_LocaleOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: title,
      subtitle: subtitle,
      showChevron: false,
      onTap: () => onSelected(value),
      trailing: Radio<_LocaleOption>(value: value),
    );
  }
}
