import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/avatar/avatar_size.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/badge.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

/// A lightweight playground to verify AppIconBadge sizes, notification dot,
/// states, and customization options.
///
/// This is not exported by the public badge barrel. It's meant for
/// design-system owners to iterate quickly while keeping feature code clean.
class BadgeShowcaseScreen extends StatefulWidget {
  const BadgeShowcaseScreen({super.key});

  @override
  State<BadgeShowcaseScreen> createState() => _BadgeShowcaseScreenState();
}

class _BadgeShowcaseScreenState extends State<BadgeShowcaseScreen> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Badge Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Sizes'),
              _buildSizesSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Notification dot'),
              _buildDotSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Interaction'),
              _buildInteractionSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Customization'),
              _buildCustomizationSection(),
              const SizedBox(height: AppSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizesSection() {
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        for (final size in AppAvatarSize.values)
          _badgeItem(
            label: size.name,
            badge: AppIconBadge(
              icon: const PhosphorIcon(PhosphorIconsRegular.bell),
              size: size,
            ),
          ),
      ],
    );
  }

  Widget _buildDotSection() {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _badgeItem(
          label: 'Hidden',
          badge: const AppIconBadge(
            icon: PhosphorIcon(PhosphorIconsRegular.bell),
          ),
        ),
        _badgeItem(
          label: 'Visible',
          badge: const AppIconBadge(
            icon: PhosphorIcon(PhosphorIconsRegular.bell),
            showDot: true,
          ),
        ),
        _badgeItem(
          label: 'xl',
          badge: const AppIconBadge(
            icon: PhosphorIcon(PhosphorIconsRegular.gear),
            size: AppAvatarSize.xl,
            showDot: true,
          ),
        ),
        _badgeItem(
          label: 'Custom',
          badge: AppIconBadge(
            icon: const PhosphorIcon(PhosphorIconsRegular.bell),
            showDot: true,
            dotColor: scheme.tertiary,
            dotBorderColor: scheme.tertiaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.space16,
          runSpacing: AppSpacing.space16,
          children: [
            _badgeItem(
              label: 'Static',
              badge: const AppIconBadge(
                icon: PhosphorIcon(PhosphorIconsRegular.user),
              ),
            ),
            _badgeItem(
              label: 'Tappable',
              badge: AppIconBadge(
                icon: const PhosphorIcon(PhosphorIconsRegular.user),
                onTap: _handleTap,
              ),
            ),
            _badgeItem(
              label: 'Tappable + dot',
              badge: AppIconBadge(
                icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                showDot: true,
                onTap: _handleTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodySmall('Taps: $_tapCount'),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _badgeItem(
          label: 'Colors',
          badge: AppIconBadge(
            icon: const PhosphorIcon(PhosphorIconsRegular.bell),
            backgroundColor: scheme.tertiaryContainer,
            iconColor: scheme.onTertiaryContainer,
          ),
        ),
        _badgeItem(
          label: 'Border',
          badge: AppIconBadge(
            icon: const PhosphorIcon(PhosphorIconsRegular.gear),
            borderColor: scheme.outline,
            borderWidth: AppSpacing.space2,
          ),
        ),
        _badgeItem(
          label: 'Dot',
          badge: AppIconBadge(
            icon: const PhosphorIcon(PhosphorIconsRegular.bell),
            showDot: true,
            dotColor: scheme.tertiary,
            dotBorderColor: scheme.tertiaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _badgeItem({required String label, required AppIconBadge badge}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: badge.size.diameter, child: badge),
        const SizedBox(height: AppSpacing.space8),
        AppText.labelSmall(label),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: AppText.titleLarge(title),
    );
  }

  void _handleTap() => setState(() => _tapCount++);
}
