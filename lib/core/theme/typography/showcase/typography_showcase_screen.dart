import 'package:flutter/material.dart';
import '../components/text.dart';
import '../tokens/type_weights.dart';
import '../../responsive/screen_utils.dart';

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
            _buildSectionHeader('Font Weights'),
            _buildFontWeightsSection(),
            const SizedBox(height: 32),

            _buildSectionHeader('Text Styles'),
            _buildTextStylesSection(),
            const SizedBox(height: 32),

            _buildSectionHeader('Responsive Behavior'),
            _buildResponsiveSection(context),
            const SizedBox(height: 32),

            _buildSectionHeader('Accessibility Features'),
            _buildAccessibilitySection(),
            const SizedBox(height: 32),

            _buildSectionHeader('Color Variations'),
            _buildColorVariationsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppText.headlineMedium(title, color: Colors.blue.shade700),
    );
  }

  Widget _buildFontWeightsSection() {
    final weights = [
      ('Extra Light (200)', TypeWeights.extraLight),
      ('Light (300)', TypeWeights.light),
      ('Regular (400)', TypeWeights.regular),
      ('Medium (500)', TypeWeights.medium),
      ('Semi Bold (600)', TypeWeights.semiBold),
      ('Bold (700)', TypeWeights.bold),
      ('Extra Bold (800)', TypeWeights.extraBold),
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
                  color: Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  'The quick brown fox jumps over the lazy dog',
                  style: TextStyle(
                    fontFamily: 'InterTight',
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

  Widget _buildTextStylesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyleExample(
          'Display Large',
          () => AppText.displayLarge('Display Large Text'),
        ),
        _buildStyleExample(
          'Display Medium',
          () => AppText.displayMedium('Display Medium Text'),
        ),
        _buildStyleExample(
          'Display Small',
          () => AppText.displaySmall('Display Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          'Headline Large',
          () => AppText.headlineLarge('Headline Large Text'),
        ),
        _buildStyleExample(
          'Headline Medium',
          () => AppText.headlineMedium('Headline Medium Text'),
        ),
        _buildStyleExample(
          'Headline Small',
          () => AppText.headlineSmall('Headline Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          'Title Large',
          () => AppText.titleLarge('Title Large Text'),
        ),
        _buildStyleExample(
          'Title Medium',
          () => AppText.titleMedium('Title Medium Text'),
        ),
        _buildStyleExample(
          'Title Small',
          () => AppText.titleSmall('Title Small Text'),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          'Body Large',
          () => AppText.bodyLarge(
            'Body Large Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),
        _buildStyleExample(
          'Body Medium',
          () => AppText.bodyMedium(
            'Body Medium Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),
        _buildStyleExample(
          'Body Small',
          () => AppText.bodySmall(
            'Body Small Text - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          ),
        ),

        const SizedBox(height: 16),

        _buildStyleExample(
          'Label Large',
          () => AppText.labelLarge('Label Large'),
        ),
        _buildStyleExample(
          'Label Medium',
          () => AppText.labelMedium('Label Medium'),
        ),
        _buildStyleExample(
          'Label Small',
          () => AppText.labelSmall('Label Small'),
        ),
      ],
    );
  }

  Widget _buildStyleExample(String label, Widget Function() builder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.labelSmall(label, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          builder(),
        ],
      ),
    );
  }

  Widget _buildResponsiveSection(BuildContext context) {
    final breakpoint = context.breakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          'Current breakpoint: $breakpoint',
          color: Colors.blue.shade600,
        ),
        const SizedBox(height: 16),

        AppText.bodyMedium(
          'Screen width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px',
        ),
        const SizedBox(height: 8),

        AppText.bodyMedium(
          'The text sizes automatically adjust based on the current screen breakpoint.',
        ),
        const SizedBox(height: 16),

        // Example of responsive text
        AppText.headlineLarge(
          'This headline scales responsively',
          color: Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildAccessibilitySection() {
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
          color: Colors.orange.shade700,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(
          'Current theme: ${isDark ? "Dark" : "Light"}',
          color: Colors.purple.shade600,
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
        _buildColorExample('Success Color', Colors.green),
        _buildColorExample('Warning Color', Colors.orange),

        const SizedBox(height: 16),

        AppText.bodySmall(
          'Toggle between light and dark themes to see how typography adapts.',
          color: Colors.grey.shade600,
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
