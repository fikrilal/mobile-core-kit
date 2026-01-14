part of 'shimmer_component.dart';

// Pre-built shimmer shapes for common use cases.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerComponent.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: direction,
      period: period,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double diameter;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerCircle({
    super.key,
    required this.diameter,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerComponent.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: direction,
      period: period,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final ShimmerDirection direction;
  final Duration period;

  const ShimmerText({
    super.key,
    required this.width,
    this.height = 16.0,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.direction = ShimmerDirection.ltr,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerComponent.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: direction,
      period: period,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}
