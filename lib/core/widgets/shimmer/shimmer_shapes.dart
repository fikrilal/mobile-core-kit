part of 'shimmer_component.dart';

// Pre-built shimmer shapes for common use cases.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBase = baseColor ?? scheme.surfaceContainerHigh;
    final effectiveHighlight = highlightColor ?? scheme.surfaceContainerHighest;
    return ShimmerComponent.fromColors(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      direction: direction,
      period: period,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: effectiveBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double diameter;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerCircle({
    super.key,
    required this.diameter,
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBase = baseColor ?? scheme.surfaceContainerHigh;
    final effectiveHighlight = highlightColor ?? scheme.surfaceContainerHighest;
    return ShimmerComponent.fromColors(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      direction: direction,
      period: period,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: effectiveBase, shape: BoxShape.circle),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 16.0,
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveBase = baseColor ?? scheme.surfaceContainerHigh;
    final effectiveHighlight = highlightColor ?? scheme.surfaceContainerHighest;
    return ShimmerComponent.fromColors(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      direction: direction,
      period: period,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: effectiveBase,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
