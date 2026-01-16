import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/theme/extensions/theme_extensions_utils.dart';
import 'package:mobile_core_kit/core/theme/typography/components/text.dart';

/// Developer screen that visualizes the current theme roles.
///
/// Purpose:
/// - Make it easy to QA role colors in light/dark.
/// - Prevent “mystery colors” by showing what `ColorScheme` + `SemanticColors`
///   actually look like on device.
///
/// This is intentionally a role showcase (not a palette ramp showcase).
class ThemeRolesShowcaseScreen extends StatelessWidget {
  const ThemeRolesShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.cs;
    final semantic = context.semanticColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme roles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Surfaces',
            children: [
              _RoleSwatch(
                name: 'surface / onSurface',
                bg: scheme.surface,
                fg: scheme.onSurface,
              ),
              _RoleSwatch(
                name: 'surfaceContainerLow / onSurface',
                bg: scheme.surfaceContainerLow,
                fg: scheme.onSurface,
              ),
              _RoleSwatch(
                name: 'surfaceContainer / onSurface',
                bg: scheme.surfaceContainer,
                fg: scheme.onSurface,
              ),
              _RoleSwatch(
                name: 'surfaceContainerHigh / onSurface',
                bg: scheme.surfaceContainerHigh,
                fg: scheme.onSurface,
              ),
              _RoleSwatch(
                name: 'surfaceContainerHighest / onSurface',
                bg: scheme.surfaceContainerHighest,
                fg: scheme.onSurface,
              ),
              _RoleSwatch(
                name: 'inverseSurface / onInverseSurface',
                bg: scheme.inverseSurface,
                fg: scheme.onInverseSurface,
              ),
              _RoleSwatch(
                name: 'outline (border) on surface',
                bg: scheme.surface,
                fg: scheme.outline,
                sample: _BorderSample(
                  borderColor: scheme.outline,
                  label: 'Control boundary',
                ),
              ),
              _RoleSwatch(
                name: 'outlineVariant (subtle) on surface',
                bg: scheme.surface,
                fg: scheme.outlineVariant,
                sample: _BorderSample(
                  borderColor: scheme.outlineVariant,
                  label: 'Decorative separator',
                ),
              ),
            ],
          ),
          _Section(
            title: 'Brand',
            children: [
              _RoleSwatch(
                name: 'primary / onPrimary',
                bg: scheme.primary,
                fg: scheme.onPrimary,
              ),
              _RoleSwatch(
                name: 'primaryContainer / onPrimaryContainer',
                bg: scheme.primaryContainer,
                fg: scheme.onPrimaryContainer,
              ),
              _RoleSwatch(
                name: 'secondary / onSecondary',
                bg: scheme.secondary,
                fg: scheme.onSecondary,
              ),
              _RoleSwatch(
                name: 'secondaryContainer / onSecondaryContainer',
                bg: scheme.secondaryContainer,
                fg: scheme.onSecondaryContainer,
              ),
              _RoleSwatch(
                name: 'tertiary / onTertiary',
                bg: scheme.tertiary,
                fg: scheme.onTertiary,
              ),
              _RoleSwatch(
                name: 'tertiaryContainer / onTertiaryContainer',
                bg: scheme.tertiaryContainer,
                fg: scheme.onTertiaryContainer,
              ),
            ],
          ),
          _Section(
            title: 'Status (SemanticColors)',
            children: [
              _RoleSwatch(
                name: 'success / onSuccess',
                bg: semantic.success,
                fg: semantic.onSuccess,
              ),
              _RoleSwatch(
                name: 'successContainer / onSuccessContainer',
                bg: semantic.successContainer,
                fg: semantic.onSuccessContainer,
              ),
              _RoleSwatch(
                name: 'info / onInfo',
                bg: semantic.info,
                fg: semantic.onInfo,
              ),
              _RoleSwatch(
                name: 'infoContainer / onInfoContainer',
                bg: semantic.infoContainer,
                fg: semantic.onInfoContainer,
              ),
              _RoleSwatch(
                name: 'warning / onWarning',
                bg: semantic.warning,
                fg: semantic.onWarning,
              ),
              _RoleSwatch(
                name: 'warningContainer / onWarningContainer',
                bg: semantic.warningContainer,
                fg: semantic.onWarningContainer,
              ),
            ],
          ),
          _Section(
            title: 'Error',
            children: [
              _RoleSwatch(
                name: 'error / onError',
                bg: scheme.error,
                fg: scheme.onError,
              ),
              _RoleSwatch(
                name: 'errorContainer / onErrorContainer',
                bg: scheme.errorContainer,
                fg: scheme.onErrorContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleLarge(title),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: children),
        ],
      ),
    );
  }
}

class _RoleSwatch extends StatelessWidget {
  const _RoleSwatch({
    required this.name,
    required this.bg,
    required this.fg,
    this.sample,
  });

  final String name;
  final Color bg;
  final Color fg;
  final Widget? sample;

  @override
  Widget build(BuildContext context) {
    final border = context.borderSubtle;
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DefaultTextStyle(
            style: TextStyle(color: fg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.labelMedium(
                  name,
                  color: fg,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                AppText.bodySmall(
                  '${_hex(bg)}  /  ${_hex(fg)}',
                  color: fg,
                ),
                const SizedBox(height: 10),
                AppText.bodyMedium(
                  'Aa 123 — sample text',
                  color: fg,
                ),
                if (sample != null) ...[
                  const SizedBox(height: 10),
                  sample!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class _BorderSample extends StatelessWidget {
  const _BorderSample({required this.borderColor, required this.label});

  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: AppText.bodySmall(
          label,
          color: context.textPrimary,
        ),
      ),
    );
  }
}
