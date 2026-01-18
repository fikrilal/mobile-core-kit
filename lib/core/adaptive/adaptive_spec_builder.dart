import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/foldables/foldable_spec.dart';
import 'package:mobile_core_kit/core/adaptive/policies/input_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/motion_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/platform_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/text_scale_policy.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/grid_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/layout_tokens.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';

/// Derives the [AdaptiveSpec] contract from constraints + runtime capabilities.
///
/// This class is intentionally "pure": it takes `BoxConstraints` and
/// `MediaQueryData` and returns value types. Keep feature logic out of here.
///
/// If you change token/policy behavior, add unit tests and update relevant
/// docs under `docs/explainers/core/adaptive/`.
class AdaptiveSpecBuilder {
  AdaptiveSpecBuilder._();

  /// Builds the full [AdaptiveSpec] for the given constraints and media.
  ///
  /// `AdaptiveScope` typically applies [TextScalePolicy] at the root via
  /// `MediaQuery.copyWith(textScaler: ...)`, then passes an unclamped policy
  /// here so [TextSpec] reflects the effective scaler without double-clamping.
  static AdaptiveSpec build({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required TargetPlatform platform,
    required TextScalePolicy textScalePolicy,
    required NavigationPolicy navigationPolicy,
    required MotionPolicy motionPolicy,
    required InputPolicy inputPolicy,
    PlatformPolicy platformPolicy = const PlatformPolicy.standard(),
  }) {
    final size = _sizeFor(constraints, media);

    final widthClass = widthClassFor(size.width);
    final heightClass = heightClassFor(size.height);
    final orientation = size.width >= size.height
        ? Orientation.landscape
        : Orientation.portrait;

    final input = inputPolicy.derive(media: media, platform: platform);
    final motion = motionPolicy.derive(media: media);
    final textScaler = textScalePolicy.apply(media.textScaler);
    final text = TextSpec(textScaler: textScaler, boldText: media.boldText);

    final insets = InsetsSpec(
      safePadding: media.padding,
      viewInsets: media.viewInsets,
    );

    final foldable = FoldableSpec.fromDisplayFeatures(media.displayFeatures);
    final platformSpec = platformPolicy.derive(platform: platform);

    final navigation = navigationPolicy.derive(
      widthClass: widthClass,
      platform: platform,
      input: input,
    );

    final layout = deriveLayout(
      constraints: constraints,
      media: media,
      widthClass: widthClass,
      heightClass: heightClass,
      orientation: orientation,
      input: input,
      navigation: navigation,
    );

    return AdaptiveSpec(
      layout: layout,
      insets: insets,
      text: text,
      motion: motion,
      input: input,
      platform: platformSpec,
      foldable: foldable,
    );
  }

  /// Derives the layout-only portion of the contract.
  ///
  /// This is used by [AdaptiveRegion] / [AdaptiveOverrides] to recompute layout
  /// decisions while inheriting non-layout specs from the parent.
  static LayoutSpec deriveLayout({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required WindowWidthClass widthClass,
    required WindowHeightClass heightClass,
    required Orientation orientation,
    required InputSpec input,
    required NavigationSpec navigation,
  }) {
    final size = _sizeFor(constraints, media);

    final pagePadding = LayoutTokens.pagePadding(widthClass);
    final gutter = LayoutTokens.gutter(widthClass);
    final minTapTarget = LayoutTokens.minTapTarget(input.mode);

    final density = _densityFor(input, widthClass);
    final surfaceTokens = _resolveSurfaceTokens(widthClass);

    final baseGridWidth = _gridContentWidth(
      windowWidth: size.width,
      horizontalPadding: pagePadding.horizontal,
      maxContentWidth: surfaceTokens[SurfaceKind.dashboard]?.contentMaxWidth,
    );

    final minTileWidth = GridTokens.minTileWidth(widthClass);
    final maxColumns = GridTokens.maxColumns(widthClass);
    final columns = GridTokens.computeColumns(
      contentWidth: baseGridWidth,
      gutter: gutter,
      widthClass: widthClass,
    );

    final grid = GridSpec(
      columns: columns,
      minTileWidth: minTileWidth,
      maxColumns: maxColumns,
    );

    return LayoutSpec(
      size: size,
      widthClass: widthClass,
      heightClass: heightClass,
      orientation: orientation,
      density: density,
      pagePadding: pagePadding,
      gutter: gutter,
      minTapTarget: minTapTarget,
      surfaceTokens: surfaceTokens,
      grid: grid,
      navigation: navigation,
    );
  }

  static Size _sizeFor(BoxConstraints constraints, MediaQueryData media) {
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : media.size.width;
    final height = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : media.size.height;
    return Size(width.isFinite ? width : 0, height.isFinite ? height : 0);
  }

  static LayoutDensity _densityFor(
    InputSpec input,
    WindowWidthClass widthClass,
  ) {
    if (input.mode == InputMode.pointer && _isAtLeastExpanded(widthClass)) {
      return LayoutDensity.compact;
    }
    return LayoutDensity.comfortable;
  }

  static bool _isAtLeastExpanded(WindowWidthClass widthClass) {
    return switch (widthClass) {
      WindowWidthClass.compact || WindowWidthClass.medium => false,
      _ => true,
    };
  }

  static Map<SurfaceKind, SurfaceTokens> _resolveSurfaceTokens(
    WindowWidthClass widthClass,
  ) {
    return Map<SurfaceKind, SurfaceTokens>.unmodifiable(
      <SurfaceKind, SurfaceTokens>{
        for (final kind in SurfaceKind.values)
          kind: SurfaceTokenTable.resolve(kind: kind, widthClass: widthClass),
      },
    );
  }

  static double _gridContentWidth({
    required double windowWidth,
    required double horizontalPadding,
    required double? maxContentWidth,
  }) {
    final available = math.max(0.0, windowWidth - horizontalPadding).toDouble();
    final max = maxContentWidth;
    if (max == null) return available;
    return math.min(available, max).toDouble();
  }
}
