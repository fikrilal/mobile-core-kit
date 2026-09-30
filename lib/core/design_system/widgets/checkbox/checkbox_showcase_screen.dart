import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/checkbox/checkbox.dart';

/// A lightweight playground to verify AppCheckbox and AppCheckboxTile states,
/// sizes, variants, and customization options.
///
/// This is not exported by the public checkbox barrel. It's meant for
/// design-system owners to iterate quickly while keeping feature code clean.
class CheckboxShowcaseScreen extends StatefulWidget {
  const CheckboxShowcaseScreen({super.key});

  @override
  State<CheckboxShowcaseScreen> createState() => _CheckboxShowcaseScreenState();
}

class _CheckboxShowcaseScreenState extends State<CheckboxShowcaseScreen> {
  bool _checked = true;
  bool? _tristate;
  bool _tileBasic = true;
  bool _tileHelper = false;
  bool _tileTrailing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkbox Showcase')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Interactive'),
              _buildInteractiveSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('States'),
              _buildStatesSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Sizes'),
              _buildSizesSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Variants'),
              _buildVariantsSection(),
              const SizedBox(height: AppSpacing.space24),
              _sectionHeader('Tiles'),
              _buildTilesSection(),
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

  Widget _buildInteractiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppCheckbox(
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false),
            ),
            const SizedBox(width: AppSpacing.space16),
            AppCheckbox(
              value: _tristate,
              tristate: true,
              onChanged: (value) => setState(() => _tristate = value),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        AppText.bodySmall('Checked: $_checked · Tristate: $_tristate'),
      ],
    );
  }

  Widget _buildStatesSection() {
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _checkboxItem(
          label: 'Unchecked',
          checkbox: AppCheckbox(value: false, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'Checked',
          checkbox: AppCheckbox(value: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'Indeterminate',
          checkbox: AppCheckbox(value: null, tristate: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'Disabled',
          checkbox: AppCheckbox(
            value: false,
            enabled: false,
            onChanged: (_) {},
          ),
        ),
        _checkboxItem(
          label: 'Disabled + checked',
          checkbox: AppCheckbox(value: true, enabled: false, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _checkboxItem(
          label: 'small',
          checkbox: AppCheckbox.small(value: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'medium',
          checkbox: AppCheckbox.medium(value: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'large',
          checkbox: AppCheckbox.large(value: true, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildVariantsSection() {
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _checkboxItem(
          label: 'primary',
          checkbox: AppCheckbox.primary(value: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'secondary',
          checkbox: AppCheckbox.secondary(value: true, onChanged: (_) {}),
        ),
      ],
    );
  }

  Widget _buildTilesSection() {
    return Column(
      children: [
        AppCheckboxTile(
          value: _tileBasic,
          label: 'Email notifications',
          onChanged: (value) => setState(() => _tileBasic = value ?? false),
        ),
        AppCheckboxTile(
          value: _tileHelper,
          label: 'Accept terms and conditions',
          helperText: 'Required before continuing.',
          onChanged: (value) => setState(() => _tileHelper = value ?? false),
        ),
        AppCheckboxTile(
          value: _tileTrailing,
          label: 'Checkbox on trailing',
          checkboxOnTrailing: true,
          onChanged: (value) => setState(() => _tileTrailing = value ?? false),
        ),
        AppCheckboxTile(
          value: false,
          label: 'Disabled tile',
          helperText: 'Cannot be changed.',
          enabled: false,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSpacing.space16,
      runSpacing: AppSpacing.space16,
      children: [
        _checkboxItem(
          label: 'Default',
          checkbox: AppCheckbox(value: true, onChanged: (_) {}),
        ),
        _checkboxItem(
          label: 'Custom colors',
          checkbox: AppCheckbox(
            value: true,
            onChanged: (_) {},
            activeColor: scheme.tertiary,
            checkColor: scheme.onTertiary,
          ),
        ),
      ],
    );
  }

  Widget _checkboxItem({required String label, required Widget checkbox}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        checkbox,
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
}
