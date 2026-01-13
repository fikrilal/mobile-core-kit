import 'package:flutter/painting.dart';

sealed class TextScalePolicy {
  const TextScalePolicy();

  const factory TextScalePolicy.unclamped() = _UnclampedPolicy;

  const factory TextScalePolicy.clamp({
    double minScaleFactor,
    double maxScaleFactor,
  }) = _ClampedPolicy;

  TextScaler apply(TextScaler incoming);
}

class _UnclampedPolicy extends TextScalePolicy {
  const _UnclampedPolicy();

  @override
  TextScaler apply(TextScaler incoming) => incoming;
}

class _ClampedPolicy extends TextScalePolicy {
  const _ClampedPolicy({
    this.minScaleFactor = 0.0,
    this.maxScaleFactor = double.infinity,
  }) : assert(maxScaleFactor >= minScaleFactor);

  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  TextScaler apply(TextScaler incoming) => incoming.clamp(
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
      );
}

