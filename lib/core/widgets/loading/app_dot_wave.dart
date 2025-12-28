import 'dart:math' as math;
import 'package:flutter/material.dart';

/// AppDotWave
///
/// Smooth, continuous dot wave loader using a sine-based animation.
/// Designed for inline numeric/value placeholders.
class AppDotWave extends StatefulWidget {
  const AppDotWave({
    super.key,
    required this.color,
    this.count = 3,
    this.dotSize = 8,
    this.spacing = 6,
    this.period = const Duration(milliseconds: 1200),
    this.minScale = 0.6,
    this.maxScale = 1.0,
    this.fade = true,
  }) : assert(count > 0, 'AppDotWave.count must be > 0.'),
       assert(dotSize > 0, 'AppDotWave.dotSize must be > 0.'),
       assert(spacing >= 0, 'AppDotWave.spacing must be >= 0.'),
       assert(minScale > 0, 'AppDotWave.minScale must be > 0.'),
       assert(maxScale >= minScale, 'AppDotWave.maxScale must be >= minScale.');

  final Color color;
  final int count;
  final double dotSize;
  final double spacing;
  final Duration period;
  final double minScale;
  final double maxScale;
  final bool fade;

  @override
  State<AppDotWave> createState() => _AppDotWaveState();
}

class _AppDotWaveState extends State<AppDotWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    assert(widget.period > Duration.zero, 'AppDotWave.period must be > 0.');
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(AppDotWave oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.period != oldWidget.period) {
      assert(widget.period > Duration.zero, 'AppDotWave.period must be > 0.');
      _controller
        ..duration = widget.period
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a single controller and compute per-dot phase offset for seamless loop
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = _controller.value * 2 * math.pi; // 0..2π
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.count, (i) {
            final phase =
                i *
                (2 * math.pi / widget.count) *
                0.8; // adjusted spacing of peaks
            final s = (math.sin(t + phase) + 1) / 2; // 0..1
            final scale =
                widget.minScale + (widget.maxScale - widget.minScale) * s;
            final opacity = widget.fade ? (0.5 + 0.5 * s) : 1.0;
            return Padding(
              padding: EdgeInsets.only(
                right: i == widget.count - 1 ? 0 : widget.spacing,
              ),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
