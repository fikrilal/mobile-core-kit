import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'adaptive_aspect.dart';
import 'adaptive_policies.dart';
import 'adaptive_spec.dart';
import 'adaptive_spec_builder.dart';
import 'policies/input_policy.dart';
import 'policies/modal_policy.dart';
import 'policies/motion_policy.dart';
import 'policies/navigation_policy.dart';
import 'policies/platform_policy.dart';
import 'policies/text_scale_policy.dart';

/// Root provider for the adaptive contract.
///
/// Place exactly once at the app root (typically `MaterialApp.builder`):
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return AdaptiveScope(
///       navigationPolicy: const NavigationPolicy.standard(),
///       textScalePolicy: const TextScalePolicy.clamp(maxScaleFactor: 2.0),
///       child: child ?? const SizedBox.shrink(),
///     );
///   },
/// );
/// ```
///
/// This widget:
/// - applies the configured [TextScalePolicy] via `MediaQuery.copyWith(...)`
/// - derives [AdaptiveSpec] from constraints + capabilities
/// - publishes it via [AdaptiveModel] (`InheritedModel`) with aspect scoping
class AdaptiveScope extends StatelessWidget {
  const AdaptiveScope({
    super.key,
    required this.child,
    required this.navigationPolicy,
    this.textScalePolicy = const TextScalePolicy.clamp(
      minScaleFactor: 1.0,
      maxScaleFactor: 2.0,
    ),
    this.modalPolicy = const ModalPolicy.standard(),
    this.motionPolicy = const MotionPolicy.standard(),
    this.inputPolicy = const InputPolicy.standard(),
    this.platformPolicy = const PlatformPolicy.standard(),
  });

  final Widget child;
  final TextScalePolicy textScalePolicy;
  final NavigationPolicy navigationPolicy;
  final ModalPolicy modalPolicy;
  final MotionPolicy motionPolicy;
  final InputPolicy inputPolicy;
  final PlatformPolicy platformPolicy;

  @override
  Widget build(BuildContext context) {
    // Ensure we rebuild when input capabilities change (e.g., mouse/trackpad
    // connect/disconnect), since Flutter does not expose this via MediaQueryData.
    return AdaptivePolicies(
      modalPolicy: modalPolicy,
      child: _MouseConnectionListener(
        child: _AdaptiveScopeBody(
          textScalePolicy: textScalePolicy,
          navigationPolicy: navigationPolicy,
          motionPolicy: motionPolicy,
          inputPolicy: inputPolicy,
          platformPolicy: platformPolicy,
          child: child,
        ),
      ),
    );
  }
}

class _AdaptiveScopeBody extends StatelessWidget {
  const _AdaptiveScopeBody({
    required this.child,
    required this.textScalePolicy,
    required this.navigationPolicy,
    required this.motionPolicy,
    required this.inputPolicy,
    required this.platformPolicy,
  });

  final Widget child;
  final TextScalePolicy textScalePolicy;
  final NavigationPolicy navigationPolicy;
  final MotionPolicy motionPolicy;
  final InputPolicy inputPolicy;
  final PlatformPolicy platformPolicy;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final appliedTextScaler = textScalePolicy.apply(media.textScaler);

    // Clamp text scaling once at the root via MediaQuery.
    // The builder receives an unclamped policy because `media.textScaler` is
    // already the effective scaler for the subtree.
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
            platformPolicy: platformPolicy,
          );
          return AdaptiveModel(spec: spec, child: child);
        },
      ),
    );
  }
}

class _MouseConnectionListener extends StatefulWidget {
  const _MouseConnectionListener({required this.child});

  final Widget child;

  @override
  State<_MouseConnectionListener> createState() =>
      _MouseConnectionListenerState();
}

class _MouseConnectionListenerState extends State<_MouseConnectionListener> {
  @override
  void initState() {
    super.initState();
    RendererBinding.instance.mouseTracker.addListener(_handleMouseConnection);
  }

  @override
  void dispose() {
    RendererBinding.instance.mouseTracker.removeListener(
      _handleMouseConnection,
    );
    super.dispose();
  }

  void _handleMouseConnection() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// InheritedModel wrapper that publishes the current [AdaptiveSpec].
///
/// Widgets should not depend on this directly; prefer
/// `BuildContext` extension getters in `adaptive_context.dart`.
class AdaptiveModel extends InheritedModel<AdaptiveAspect> {
  const AdaptiveModel({super.key, required this.spec, required super.child});

  final AdaptiveSpec spec;

  /// Returns the current [AdaptiveSpec] and registers an aspect dependency.
  ///
  /// If [aspect] is omitted, the dependency is on the whole spec (rebuilds on
  /// any change).
  static AdaptiveSpec of(BuildContext context, {AdaptiveAspect? aspect}) {
    final model = InheritedModel.inheritFrom<AdaptiveModel>(
      context,
      aspect: aspect,
    );
    assert(model != null, 'No AdaptiveScope found in context');
    return model!.spec;
  }

  /// Returns the current [AdaptiveSpec] without registering a dependency.
  ///
  /// Use sparingly; most widgets should listen to updates.
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
