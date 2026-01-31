import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/app_button.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button_variants.dart';
import 'package:mobile_core_kit/core/design_system/widgets/common/app_haptic_feedback.dart';

/// A lightweight playground to verify AppButton variants, sizes, and states.
///
/// This is not exported by the public button barrel. It's meant for
/// design‑system owners to iterate quickly while keeping feature code clean.
class ButtonShowcaseScreen extends StatefulWidget {
  const ButtonShowcaseScreen({super.key});

  @override
  State<ButtonShowcaseScreen> createState() => _ButtonShowcaseScreenState();
}

class _ButtonShowcaseScreenState extends State<ButtonShowcaseScreen> {
  bool _loading = false;
  bool _disabled = false;
  bool _expanded = false;

  void _toggleLoading() => setState(() => _loading = !_loading);
  void _toggleDisabled() => setState(() => _disabled = !_disabled);
  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Showcase'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControls(),
            const SizedBox(height: AppSpacing.space24),
            _sectionHeader('Variants'),
            _buildVariantsSection(),
            const SizedBox(height: AppSpacing.space24),
            _sectionHeader('Sizes'),
            _buildSizesSection(),
            const SizedBox(height: AppSpacing.space24),
            _sectionHeader('Icons'),
            _buildIconsSection(),
            const SizedBox(height: AppSpacing.space24),
            _sectionHeader('Layout'),
            _buildLayoutSection(),
            const SizedBox(height: AppSpacing.space24),
            _sectionHeader('Customization'),
            _buildCustomizationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Controls', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Loading'),
                  selected: _loading,
                  onSelected: (_) => _toggleLoading(),
                ),
                FilterChip(
                  label: const Text('Disabled'),
                  selected: _disabled,
                  onSelected: (_) => _toggleDisabled(),
                ),
                FilterChip(
                  label: const Text('Expanded'),
                  selected: _expanded,
                  onSelected: (_) => _toggleExpanded(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection() {
    return Column(
      children: [
        AppButton.primary(
          text: 'Primary',
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.secondary(
          text: 'Secondary',
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.outline(
          text: 'Outline',
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.danger(
          text: 'Danger',
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ButtonSize.values.map((size) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  size.name,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: AppButton(
                  text: 'Primary $size',
                  size: size,
                  isLoading: _loading,
                  isDisabled: _disabled,
                  isExpanded: _expanded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconsSection() {
    return Column(
      children: [
        AppButton.primary(
          text: 'Leading icon',
          icon: const Icon(Icons.login),
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.primary(
          text: 'Trailing icon',
          suffixIcon: const Icon(Icons.arrow_forward),
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.primary(
          text: 'Both sides',
          icon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.arrow_forward),
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLayoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inline in a row', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.space8),
        Row(
          children: [
            Expanded(
              child: AppButton.outline(
                text: 'Cancel',
                isLoading: false,
                isDisabled: _disabled,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: AppButton.primary(
                text: 'Confirm',
                isLoading: _loading,
                isDisabled: _disabled,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),
        Text(
          'Expanded vs intrinsic width',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.space8),
        AppButton.primary(
          text: 'Intrinsic',
          isExpanded: false,
          isLoading: _loading,
          isDisabled: _disabled,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space8),
        AppButton.primary(
          text: 'Expanded',
          isExpanded: true,
          isLoading: _loading,
          isDisabled: _disabled,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        AppButton(
          text: 'Custom colors',
          variant: ButtonVariant.primary,
          backgroundColor: scheme.tertiary,
          textColor: scheme.onTertiary,
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton(
          text: 'Outline custom border',
          variant: ButtonVariant.outline,
          borderColor: scheme.secondary,
          textColor: scheme.secondary,
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.space12),
        AppButton.primary(
          text: 'Opt‑in haptics',
          hapticFeedback: AppHapticFeedback.selectionClick,
          isLoading: _loading,
          isDisabled: _disabled,
          isExpanded: _expanded,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
