import 'package:flutter/widgets.dart';

import 'adaptive_aspect.dart';
import 'adaptive_scope.dart';
import 'adaptive_spec.dart';
import 'foldables/foldable_spec.dart';

extension AdaptiveContextX on BuildContext {
  AdaptiveSpec get adaptive => AdaptiveModel.of(this);

  LayoutSpec get adaptiveLayout =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.layout).layout;

  InsetsSpec get adaptiveInsets =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.insets).insets;

  TextSpec get adaptiveText =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.text).text;

  MotionSpec get adaptiveMotion =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.motion).motion;

  InputSpec get adaptiveInput =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.input).input;

  PlatformSpec get adaptivePlatform =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.platform).platform;

  FoldableSpec get adaptiveFoldable =>
      AdaptiveModel.of(this, aspect: AdaptiveAspect.foldable).foldable;
}
