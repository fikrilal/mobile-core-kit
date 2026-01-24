import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:mobile_core_kit/core/theme/system/motion_durations.dart';
import 'package:mobile_core_kit/core/theme/tokens/radii.dart';

part 'shimmer_render.dart';
part 'shimmer_shapes.dart';

LinearGradient _defaultShimmerGradient(ColorScheme scheme) {
  final base = scheme.surfaceContainerHigh;
  final highlight = scheme.surfaceContainerHighest;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: <Color>[base, base, highlight, base, base],
    stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
  );
}

///
/// An enum defines all supported directions of shimmer effect
///
enum ShimmerDirection { ltr, rtl, ttb, btt }

///
/// A widget renders shimmer effect over [child] widget tree.
///
@immutable
class ShimmerComponent extends StatefulWidget {
  final Widget child;
  final Duration period;
  final ShimmerDirection direction;
  final Gradient? gradient; // optional
  final int loop;
  final bool enabled;

  const ShimmerComponent({
    super.key,
    required this.child,
    this.gradient,
    this.direction = ShimmerDirection.ltr,
    this.period = MotionDurations.shimmerPeriod,
    this.loop = 0,
    this.enabled = true,
  });

  ///
  /// A convenient constructor provides an easy and convenient way to create a
  /// [ShimmerComponent] which [gradient] is [LinearGradient] made up of `baseColor` and
  /// `highlightColor`.
  ///
  ShimmerComponent.fromColors({
    super.key,
    required this.child,
    required Color baseColor,
    required Color highlightColor,
    this.period = MotionDurations.shimmerPeriod,
    this.direction = ShimmerDirection.ltr,
    this.loop = 0,
    this.enabled = true,
  }) : gradient = LinearGradient(
         begin: Alignment.topLeft,
         end: Alignment.centerRight,
         colors: <Color>[
           baseColor,
           baseColor,
           highlightColor,
           baseColor,
           baseColor,
         ],
         stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
       );

  @override
  State<ShimmerComponent> createState() => _ShimmerComponentState();
}

class _ShimmerComponentState extends State<ShimmerComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..addStatusListener((AnimationStatus status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        _count++;
        if (widget.loop <= 0) {
          _controller.repeat();
        } else if (_count < widget.loop) {
          _controller.forward(from: 0.0);
        }
      });
    if (widget.enabled) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ShimmerComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.period != oldWidget.period) {
      _controller.duration = widget.period;
    }

    final enabledChanged = widget.enabled != oldWidget.enabled;
    final loopChanged = widget.loop != oldWidget.loop;
    if (enabledChanged || loopChanged) {
      _count = 0;
    }

    if (!widget.enabled) {
      if (oldWidget.enabled) {
        _controller.stop();
      }
      return;
    }

    if (enabledChanged) {
      _controller.forward(from: 0.0);
      return;
    }

    if (loopChanged) {
      _controller.stop();
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final scheme = Theme.of(context).colorScheme;

    return _Shimmer(
      animation: _controller,
      direction: widget.direction,
      gradient: widget.gradient ?? _defaultShimmerGradient(scheme),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
