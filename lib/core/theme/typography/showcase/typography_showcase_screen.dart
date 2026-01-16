import 'package:flutter/material.dart';
import '../../../adaptive/adaptive_context.dart';
import '../../extensions/theme_extensions_utils.dart';
import '../components/text.dart';
import '../tokens/type_weights.dart';
import '../tokens/typefaces.dart';

/// A comprehensive showcase screen for testing all typography styles and font weights.
///
/// This screen displays all available text styles, font weights, and responsive
/// behavior to help developers and designers verify the typography system.
class TypographyShowcaseScreen extends StatelessWidget {
  const TypographyShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typography Showcase'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Font Weights'),
            _buildFontWeightsSection(context),
            const SizedBox(height: 32),

            _buildSectionHeader(context, 'Text Styles'),
            _buildTextStylesSection(context),
            const SizedBox(height: 32),

            _buildSectionHeader(context, 'Responsive Behavior'),
            _buildResponsiveSection(context),
            const SizedBox(height: 32),

            _buildSectionHeader(context, 'Accessibility Features'),
            _buildAccessibilitySection(context),
            const SizedBox(height: 32),

            _buildSectionHeader(context, 'Color Variations'),
            _buildColorVariationsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppText.headlineMedium(title, color: scheme.primary),
    );
  }

  Widget _buildFontWeightsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weights = [
      ('Regular (400)', TypeWeights.regular),
      ('Medium (500)', TypeWeights.medium),
      ('Semi Bold (600)', TypeWeights.semiBold),
      ('Bold (700)', TypeWeights.bold),
    ];

    return Column(
      children: weights.map((weight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: AppText.labelMedium(
                  weight.$1,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  'The quick brown fox jumps over the lazy dog',
                  style: TextStyle(
                    fontFamily: Typefaces.primary,
                    fontSize: 16,
                    fontWeight: weight.$2,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextStylesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyleExample(
          context,
          'Display Large',
          () => AppText.displayLarge('Display Large Text'),
        ),
        _buildStyleExample(
          context,
          'Display Medium',
          () => AppText.displayMedium('Display Medium Text'),
        ),
        _buildStyleExample(
          context,
          'Display Small',
          () => AppText.displaySmall('Display Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          context,
          'Headline Large',
          () => AppText.headlineLarge('Headline Large Text'),
        ),
        _buildStyleExample(
          context,
          'Headline Medium',
          () => AppText.headlineMedium('Headline Medium Text'),
        ),
        _buildStyleExample(
          context,
          'Headline Small',
          () => AppText.headlineSmall('Headline Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          context,
          'Title Large',
          () => AppText.titleLarge('Title Large Text'),
        ),
        _buildStyleExample(
          context,
          'Title Medium',
          () => AppText.titleMedium('Title Medium Text'),
        ),
        _buildStyleExample(
          context,
          'Title Small',
          () => AppText.titleSmall('Title Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          context,
          'Body Large',
          () => AppText.bodyLarge(
            'Body Large Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),
        _buildStyleExample(
          context,
          'Body Medium',
          () => AppText.bodyMedium(
            'Body Medium Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),
        _buildStyleExample(
          context,
          'Body Small',
          () => AppText.bodySmall(
            'Body Small Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          context,
          'Label Large',
          () => AppText.labelLarge('Label Large'),
        ),
        _buildStyleExample(
          context,
          'Label Medium',
          () => AppText.labelMedium('Label Medium'),
        ),
        _buildStyleExample(
          context,
          'Label Small',
          () => AppText.labelSmall('Label Small'),
        ),
      ],
    );
  }

  Widget _buildStyleExample(
    BuildContext context,
    String label,
    Widget Function() builder,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.labelSmall(label, color: scheme.onSurfaceVariant),
          const SizedBox(height: 4),
          builder(),
        ],
      ),
    );
  }

  Widget _buildResponsiveSection(BuildContext context) {
    final layout = context.adaptiveLayout;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          'Width class: ${layout.widthClass}  •  Height class: ${layout.heightClass}',
          color: scheme.primary,
        ),
        const SizedBox(height: 16),

        AppText.bodyMedium(
          'Screen width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px',
        ),
        const SizedBox(height: 8),

        AppText.bodyMedium(
          'Layout adapts using the adaptive size classes; text scaling follows system settings (clamped at the app root).',
        ),
        const SizedBox(height: 16),

        // Example header + body text under the current layout constraints
        AppText.headlineLarge(
          'This headline follows the type ramp',
          color: scheme.primary,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          'Accessibility features built into the typography system:',
        ),
        const SizedBox(height: 12),

        _buildAccessibilityFeature('✓ Respects system text scaling'),
        _buildAccessibilityFeature('✓ Proper contrast ratios'),
        _buildAccessibilityFeature('✓ Semantic text roles'),
        _buildAccessibilityFeature('✓ Screen reader compatibility'),

        const SizedBox(height: 16),

        AppText.bodyMedium(
          'Try changing your device\'s text size in system settings to see the responsive behavior.',
          color: scheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildAccessibilityFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppText.bodyMedium(feature),
    );
  }

  Widget _buildColorVariationsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          'Current theme: ${isDark ? "Dark" : "Light"}',
          color: scheme.tertiary,
        ),
        const SizedBox(height: 16),

        _buildColorExample(
          'Primary Color',
          Theme.of(context).colorScheme.primary,
        ),
        _buildColorExample(
          'Secondary Color',
          Theme.of(context).colorScheme.secondary,
        ),
        _buildColorExample('Error Color', Theme.of(context).colorScheme.error),
        _buildColorExample('Success Color', semantic.success),
        _buildColorExample('Warning Color', semantic.warning),

        const SizedBox(height: 16),

        AppText.bodySmall(
          'Toggle between light and dark themes to see how typography adapts.',
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildColorExample(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          AppText.bodyMedium(
            '$label - Sample text in this color',
            color: color,
          ),
        ],
      ),
    );
  }
}
