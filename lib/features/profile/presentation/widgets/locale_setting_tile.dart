import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/adaptive/widgets/adaptive_modal.dart';
import 'package:mobile_core_kit/core/localization/l10n.dart';
import 'package:mobile_core_kit/core/services/localization/locale_controller.dart';
import 'package:mobile_core_kit/core/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/widgets/list/app_list_tile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LocaleSettingTile extends StatelessWidget {
  const LocaleSettingTile({
    required this.includePseudoLocales,
    required this.controller,
    super.key,
  });

  final bool includePseudoLocales;
  final LocaleController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: controller,
      builder: (context, localeOverride, _) {
        return AppListTile(
          leading: AppIconBadge(
            icon: PhosphorIcon(PhosphorIconsRegular.translate, size: 24),
          ),
          title: context.l10n.commonLanguage,
          subtitle: _localeLabel(context, localeOverride),
          onTap: () async {
            final selected = await showAdaptiveModal<_LocaleOption>(
              context: context,
              builder: (_) => _LocalePicker(
                initialOption: _localeToOption(
                  localeOverride,
                  includePseudo: includePseudoLocales,
                ),
                includePseudo: includePseudoLocales,
              ),
            );
            if (selected == null) return;
            await controller.setLocale(_localeFromOption(selected));
          },
        );
      },
    );
  }
}

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
