import 'package:flutter/widgets.dart';

import 'adaptive_aspect.dart';
import 'adaptive_scope.dart';
import 'adaptive_spec.dart';
import 'foldables/foldable_spec.dart';

/// Context accessors for the adaptive contract.
///
/// Prefer the most specific accessor possible to avoid over-rebuilding:
/// - `context.adaptiveLayout` for layout/token usage
/// - `context.adaptiveInsets` for safe area / keyboard handling
/// - `context.adaptiveText` for text scaling reactions
/// - etc.
extension AdaptiveContextX on BuildContext {
  /// Full adaptive spec (rebuilds when any aspect changes).
  ///
  /// Prefer the aspect-specific getters unless you're debugging.
  AdaptiveSpec get adaptive => AdaptiveModel.of(this);

  /// Layout-only spec (size classes, tokens, nav kind, grid columns).
  LayoutSpec get adaptiveLayout =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.layout).layout;

  /// Insets-only spec (safe padding + keyboard insets).
  InsetsSpec get adaptiveInsets =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.insets).insets;

  /// Text-only spec (TextScaler + boldText).
  TextSpec get adaptiveText =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.text).text;

  /// Motion-only spec (reduce motion preferences).
  MotionSpec get adaptiveMotion =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.motion).motion;

  /// Input-only spec (touch/pointer/mixed).
  InputSpec get adaptiveInput =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.input).input;

  /// Platform-only spec (TargetPlatform and helpers).
  PlatformSpec get adaptivePlatform =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.platform).platform;

  /// Foldable-only spec (display posture / hinge geometry).
  FoldableSpec get adaptiveFoldable =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.foldable).foldable;
}
