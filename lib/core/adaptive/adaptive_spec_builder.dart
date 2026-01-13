import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'adaptive_spec.dart';
import 'foldables/foldable_spec.dart';
import 'policies/input_policy.dart';
import 'policies/motion_policy.dart';
import 'policies/navigation_policy.dart';
import 'policies/text_scale_policy.dart';
import 'size_classes.dart';
import 'tokens/grid_tokens.dart';
import 'tokens/layout_tokens.dart';
import 'tokens/surface_tokens.dart';

class AdaptiveSpecBuilder {
  AdaptiveSpecBuilder._();

  static AdaptiveSpec build({
    required BoxConstraints constraints,
    required MediaQueryData media,
    required TargetPlatform platform,
    required TextScalePolicy textScalePolicy,
    required NavigationPolicy navigationPolicy,
    required MotionPolicy motionPolicy,
    required InputPolicy inputPolicy,
  }) {
    final size = _sizeFor(constraints, media);

    final widthClass = widthClassFor(size.width);
    final heightClass = heightClassFor(size.height);
    final orientation =
        size.width >= size.height ? Orientation.landscape : Orientation.portrait;

    final input = inputPolicy.derive(media: media, platform: platform);
    final motion = motionPolicy.derive(media: media);
    final textScaler = textScalePolicy.apply(media.textScaler);
    final text = TextSpec(textScaler: textScaler, boldText: media.boldText);

    final insets = InsetsSpec(
      safePadding: media.padding,
      viewInsets: media.viewInsets,
    );

    final foldable = FoldableSpec.fromDisplayFeatures(media.displayFeatures);

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
      platform: PlatformSpec(platform: platform),
      foldable: foldable,
    );
  }

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
    final width =
        constraints.hasBoundedWidth ? constraints.maxWidth : media.size.width;
    final height =
        constraints.hasBoundedHeight ? constraints.maxHeight : media.size.height;
    return Size(width.isFinite ? width : 0, height.isFinite ? height : 0);
  }

  static LayoutDensity _densityFor(InputSpec input, WindowWidthClass widthClass) {
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
    return Map<SurfaceKind, SurfaceTokens>.unmodifiable(<SurfaceKind, SurfaceTokens>{
      for (final kind in SurfaceKind.values)
        kind: SurfaceTokenTable.resolve(kind: kind, widthClass: widthClass),
    });
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
