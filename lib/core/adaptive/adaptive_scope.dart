import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'adaptive_aspect.dart';
import 'adaptive_spec.dart';
import 'adaptive_spec_builder.dart';
import 'policies/input_policy.dart';
import 'policies/motion_policy.dart';
import 'policies/navigation_policy.dart';
import 'policies/text_scale_policy.dart';

class AdaptiveScope extends StatelessWidget {
  const AdaptiveScope({
    super.key,
    required this.child,
    required this.navigationPolicy,
    this.textScalePolicy = const TextScalePolicy.clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 2.0,
    ),
    this.motionPolicy = const MotionPolicy.standard(),
    this.inputPolicy = const InputPolicy.standard(),
  });

  final Widget child;
  final TextScalePolicy textScalePolicy;
  final NavigationPolicy navigationPolicy;
  final MotionPolicy motionPolicy;
  final InputPolicy inputPolicy;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final appliedTextScaler = textScalePolicy.apply(media.textScaler);

    return MediaQuery(
      data: media.copyWith(textScaler: appliedTextScaler),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spec = AdaptiveSpecBuilder.build(
            constraints: constraints,
            media: MediaQuery.of(context),
            platform: defaultTargetPlatform,
            textScalePolicy: const TextScalePolicy.unclamped(),
            navigationPolicy: navigationPolicy,
            motionPolicy: motionPolicy,
            inputPolicy: inputPolicy,
          );
          return AdaptiveModel(spec: spec, child: child);
        },
      ),
    );
  }
}

class AdaptiveModel extends InheritedModel<AdaptiveAspect> {
  const AdaptiveModel({super.key, required this.spec, required super.child});

  final AdaptiveSpec spec;

  static AdaptiveSpec of(BuildContext context, {AdaptiveAspect? aspect}) {
    final model = InheritedModel.inheritFrom<AdaptiveModel>(
      context,
      aspect: aspect,
    );
    assert(model != null, 'No AdaptiveScope found in context');
    return model!.spec;
  }

  static AdaptiveSpec read(BuildContext context) {
    final widget =
        context.getElementForInheritedWidgetOfExactType<AdaptiveModel>()?.widget
            as AdaptiveModel?;
    assert(widget != null, 'No AdaptiveScope found in context');
    return widget!.spec;
  }

  @override
  bool updateShouldNotify(AdaptiveModel oldWidget) => spec != oldWidget.spec;

  @override
  bool updateShouldNotifyDependent(
    AdaptiveModel oldWidget,
    Set<AdaptiveAspect> dependencies,
  ) {
    if (dependencies.contains(AdaptiveAspect.layout) &&
        spec.layout != oldWidget.spec.layout) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.insets) &&
        spec.insets != oldWidget.spec.insets) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.text) &&
        spec.text != oldWidget.spec.text) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.motion) &&
        spec.motion != oldWidget.spec.motion) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.input) &&
        spec.input != oldWidget.spec.input) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.platform) &&
        spec.platform != oldWidget.spec.platform) {
      return true;
    }
    if (dependencies.contains(AdaptiveAspect.foldable) &&
        spec.foldable != oldWidget.spec.foldable) {
      return true;
    }
    return false;
  }
}
