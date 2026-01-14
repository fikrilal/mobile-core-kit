import 'package:flutter/painting.dart';

/// Policy for applying text scaling at the app root.
///
/// Flutter's modern text scaling uses [TextScaler] (which may be nonlinear on
/// newer OS versions). This policy must preserve that behavior. Do **not**
/// convert scalers into a single linear factor.
sealed class TextScalePolicy {
  const TextScalePolicy();

  /// Preserves the platform's [TextScaler] without modification.
  const factory TextScalePolicy.unclamped() = _UnclampedPolicy;

  /// Clamps the platform's [TextScaler] to a min/max range via
  /// [TextScaler.clamp].
  const factory TextScalePolicy.clamp({
    double minScaleFactor,
    double maxScaleFactor,
  }) = _ClampedPolicy;

  /// Applies this policy to the incoming scaler and returns the effective scaler.
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
