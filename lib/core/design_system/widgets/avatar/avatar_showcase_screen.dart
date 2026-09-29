import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/avatar/avatar.dart';

/// A lightweight playground to verify AppAvatar sizes, fallbacks, states, and
/// customization options.
///
/// This is not exported by the public avatar barrel. It's meant for
/// design-system owners to iterate quickly while keeping feature code clean.
class AvatarShowcaseScreen extends StatefulWidget {
  const AvatarShowcaseScreen({super.key});

  @override
  State<AvatarShowcaseScreen> createState() => _AvatarShowcaseScreenState();
}

class _AvatarShowcaseScreenState extends State<AvatarShowcaseScreen> {
  int _tapCount = 0;
  int _photoChangeCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Sizes'),
              _buildSizesSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Fallbacks'),
              _buildFallbacksSection(),
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
          SizedBox(
            width: size.diameter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppAvatar(displayName: 'Ada Lovelace', size: size),
                const SizedBox(height: AppSpacing.space8),
                AppText.labelSmall(size.name),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFallbacksSection() {
    return Column(
      children: [
        _fallbackRow(
          label: 'Broken image URL falls back to initials',
          avatar: AppAvatar(
            imageUrl: 'https://example.invalid/avatar.png',
            displayName: 'Ada Lovelace',
          ),
        ),
        _fallbackRow(
          label: 'Initials computed from display name',
          avatar: const AppAvatar(displayName: 'Ada Lovelace'),
        ),
        _fallbackRow(
          label: 'Explicit initials',
          avatar: const AppAvatar(initials: 'JD'),
        ),
        _fallbackRow(
          label: 'No image or name (person icon)',
          avatar: const AppAvatar(),
        ),
      ],
    );
  }

  Widget _fallbackRow({required String label, required Widget avatar}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space16),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: AppSpacing.space16),
          Expanded(child: AppText.bodySmall(label)),
        ],
      ),
    );
  }

  Widget _buildInteractionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppAvatar(displayName: 'Ada Lovelace', onTap: _handleTap),
            const SizedBox(width: AppSpacing.space16),
            AppAvatar(
              displayName: 'Ada Lovelace',
              onChangePhoto: _handlePhotoChange,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodySmall(
          'First avatar taps: $_tapCount · Camera badge taps: '
          '$_photoChangeCount',
        ),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _customizationItem(
          label: 'Colors',
          avatar: AppAvatar(
            displayName: 'Ada Lovelace',
            backgroundColor: scheme.tertiaryContainer,
            foregroundColor: scheme.onTertiaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.space16),
        _customizationItem(
          label: 'Border',
          avatar: AppAvatar(
            displayName: 'Ada Lovelace',
            borderColor: scheme.outline,
            borderWidth: AppSpacing.space2,
          ),
        ),
        const SizedBox(width: AppSpacing.space16),
        _customizationItem(
          label: 'Badge',
          avatar: AppAvatar(
            displayName: 'Ada Lovelace',
            onChangePhoto: _handlePhotoChange,
            badgeBackgroundColor: scheme.tertiary,
            badgeIconColor: scheme.onTertiary,
          ),
        ),
      ],
    );
  }

  Widget _customizationItem({required String label, required Widget avatar}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
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

  void _handlePhotoChange() => setState(() => _photoChangeCount++);
}
