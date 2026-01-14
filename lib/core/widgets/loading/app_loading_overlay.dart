import 'package:flutter/material.dart';

import '../../theme/tokens/spacing.dart';
import '../../theme/typography/components/text.dart';

/// A blocking, modal-style loading overlay.
///
/// This is the recommended API for screens that need to temporarily prevent
/// interaction while work is in progress.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.indicator,
    this.barrierColor,
    this.cardColor,
    this.indicatorSize = 28,
    this.cardPadding,
    this.borderRadius,
    this.blockBackButton = true,
    this.disableChildTickers = true,
  });

  final Widget child;
  final bool isLoading;

  /// Optional text shown under the indicator.
  final String? message;

  /// Optional indicator override (defaults to [CircularProgressIndicator]).
  final Widget? indicator;

  /// Barrier color when loading (defaults to `colorScheme.scrim` with opacity).
  final Color? barrierColor;

  /// Card/background color for the loader content.
  final Color? cardColor;

  final double indicatorSize;
  final EdgeInsetsGeometry? cardPadding;
  final BorderRadiusGeometry? borderRadius;

  /// When true, back navigation is blocked while [isLoading] is true.
  final bool blockBackButton;

  /// When true, disables tickers under [child] while [isLoading] is true.
  ///
  /// This reduces wasted work (animations, tickers) while the UI is blocked.
  final bool disableChildTickers;

  @override
  Widget build(BuildContext context) {
    final effectiveChild = disableChildTickers && isLoading
        ? TickerMode(enabled: false, child: child)
        : child;

    if (!isLoading) {
      return effectiveChild;
    }

    final scheme = Theme.of(context).colorScheme;
    final effectiveBarrierColor =
        barrierColor ?? scheme.scrim.withValues(alpha: 0.45);
    final effectiveCardColor =
        cardColor ?? scheme.surfaceContainerHigh.withValues(alpha: 0.92);

    final overlay = Stack(
      fit: StackFit.passthrough,
      children: [
        effectiveChild,
        Positioned.fill(
          child: Semantics(
            label: message ?? 'Loading',
            liveRegion: true,
            child: ModalBarrier(
              dismissible: false,
              color: effectiveBarrierColor,
            ),
          ),
        ),
        Center(
          child: _LoadingCard(
            backgroundColor: effectiveCardColor,
            padding:
                cardPadding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space12,
                ),
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppSpacing.space12),
            indicator: indicator ?? _DefaultIndicator(size: indicatorSize),
            message: message,
          ),
        ),
      ],
    );

    if (!blockBackButton) {
      return overlay;
    }

    return PopScope(canPop: false, child: overlay);
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.backgroundColor,
    required this.padding,
    required this.borderRadius,
    required this.indicator,
    required this.message,
  });

  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Widget indicator;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.space12),
                AppText.bodyMedium(
                  message!,
                  color: scheme.onSurface,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultIndicator extends StatelessWidget {
  const _DefaultIndicator({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 3, color: scheme.primary),
    );
  }
}
