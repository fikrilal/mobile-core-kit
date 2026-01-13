import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'foldables/foldable_spec.dart';
import 'size_classes.dart';
import 'tokens/surface_tokens.dart';

enum InputMode { touch, pointer, mixed }

enum LayoutDensity { comfortable, compact }

enum NavigationKind {
  bar,
  rail,
  extendedRail,
  modalDrawer,
  standardDrawer,
  none,
}

@immutable
class AdaptiveSpec {
  const AdaptiveSpec({
    required this.layout,
    required this.insets,
    required this.text,
    required this.motion,
    required this.input,
    required this.platform,
    required this.foldable,
  });

  final LayoutSpec layout;
  final InsetsSpec insets;
  final TextSpec text;
  final MotionSpec motion;
  final InputSpec input;
  final PlatformSpec platform;
  final FoldableSpec foldable;

  AdaptiveSpec copyWith({
    LayoutSpec? layout,
    InsetsSpec? insets,
    TextSpec? text,
    MotionSpec? motion,
    InputSpec? input,
    PlatformSpec? platform,
    FoldableSpec? foldable,
  }) {
    return AdaptiveSpec(
      layout: layout ?? this.layout,
      insets: insets ?? this.insets,
      text: text ?? this.text,
      motion: motion ?? this.motion,
      input: input ?? this.input,
      platform: platform ?? this.platform,
      foldable: foldable ?? this.foldable,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdaptiveSpec &&
      layout == other.layout &&
      insets == other.insets &&
      text == other.text &&
      motion == other.motion &&
      input == other.input &&
      platform == other.platform &&
      foldable == other.foldable;

  @override
  int get hashCode => Object.hash(
        layout,
        insets,
        text,
        motion,
        input,
        platform,
        foldable,
      );
}

@immutable
class LayoutSpec {
  const LayoutSpec({
    required this.size,
    required this.widthClass,
    required this.heightClass,
    required this.orientation,
    required this.density,
    required this.pagePadding,
    required this.gutter,
    required this.minTapTarget,
    required this.surfaceTokens,
    required this.grid,
    required this.navigation,
  });

  final Size size;
  final WindowWidthClass widthClass;
  final WindowHeightClass heightClass;
  final Orientation orientation;

  final LayoutDensity density;
  final EdgeInsets pagePadding;
  final double gutter;
  final double minTapTarget;

  final Map<SurfaceKind, SurfaceTokens> surfaceTokens;
  final GridSpec grid;
  final NavigationSpec navigation;

  SurfaceTokens surface(SurfaceKind kind) =>
      surfaceTokens[kind] ?? const SurfaceTokens(contentMaxWidth: null);

  @override
  bool operator ==(Object other) =>
      other is LayoutSpec &&
      size == other.size &&
      widthClass == other.widthClass &&
      heightClass == other.heightClass &&
      orientation == other.orientation &&
      density == other.density &&
      pagePadding == other.pagePadding &&
      gutter == other.gutter &&
      minTapTarget == other.minTapTarget &&
      mapEquals(surfaceTokens, other.surfaceTokens) &&
      grid == other.grid &&
      navigation == other.navigation;

  @override
  int get hashCode => Object.hash(
        size,
        widthClass,
        heightClass,
        orientation,
        density,
        pagePadding,
        gutter,
        minTapTarget,
        _surfaceTokensHash(surfaceTokens),
        grid,
        navigation,
      );

  static int _surfaceTokensHash(Map<SurfaceKind, SurfaceTokens> tokens) {
    // `MapEntry` does not implement value equality/hashCode in Dart, so hashing
    // `map.entries` would violate `==`/`hashCode` when maps are recreated.
    return Object.hashAll(
      SurfaceKind.values.map((kind) => Object.hash(kind, tokens[kind])),
    );
  }
}

@immutable
class GridSpec {
  const GridSpec({
    required this.columns,
    required this.minTileWidth,
    required this.maxColumns,
  });

  final int columns;
  final double minTileWidth;
  final int maxColumns;

  @override
  bool operator ==(Object other) =>
      other is GridSpec &&
      columns == other.columns &&
      minTileWidth == other.minTileWidth &&
      maxColumns == other.maxColumns;

  @override
  int get hashCode => Object.hash(columns, minTileWidth, maxColumns);
}

@immutable
class NavigationSpec {
  const NavigationSpec({
    required this.kind,
    this.railWidth,
    this.extendedRailWidth,
    this.drawerWidth,
  });

  final NavigationKind kind;
  final double? railWidth;
  final double? extendedRailWidth;
  final double? drawerWidth;

  @override
  bool operator ==(Object other) =>
      other is NavigationSpec &&
      kind == other.kind &&
      railWidth == other.railWidth &&
      extendedRailWidth == other.extendedRailWidth &&
      drawerWidth == other.drawerWidth;

  @override
  int get hashCode => Object.hash(kind, railWidth, extendedRailWidth, drawerWidth);
}

@immutable
class InsetsSpec {
  const InsetsSpec({
    required this.safePadding,
    required this.viewInsets,
  });

  final EdgeInsets safePadding;
  final EdgeInsets viewInsets;

  @override
  bool operator ==(Object other) =>
      other is InsetsSpec &&
      safePadding == other.safePadding &&
      viewInsets == other.viewInsets;

  @override
  int get hashCode => Object.hash(safePadding, viewInsets);
}

@immutable
class TextSpec {
  const TextSpec({
    required this.textScaler,
    required this.boldText,
  });

  final TextScaler textScaler;
  final bool boldText;

  @override
  bool operator ==(Object other) =>
      other is TextSpec &&
      textScaler == other.textScaler &&
      boldText == other.boldText;

  @override
  int get hashCode => Object.hash(textScaler, boldText);
}

@immutable
class MotionSpec {
  const MotionSpec({required this.reduceMotion});

  final bool reduceMotion;

  @override
  bool operator ==(Object other) =>
      other is MotionSpec && reduceMotion == other.reduceMotion;

  @override
  int get hashCode => reduceMotion.hashCode;
}

@immutable
class InputSpec {
  const InputSpec({
    required this.mode,
    required this.pointerHoverEnabled,
  });

  final InputMode mode;
  final bool pointerHoverEnabled;

  @override
  bool operator ==(Object other) =>
      other is InputSpec &&
      mode == other.mode &&
      pointerHoverEnabled == other.pointerHoverEnabled;

  @override
  int get hashCode => Object.hash(mode, pointerHoverEnabled);
}

@immutable
class PlatformSpec {
  const PlatformSpec({required this.platform});

  final TargetPlatform platform;

  bool get isIOS => platform == TargetPlatform.iOS;
  bool get isAndroid => platform == TargetPlatform.android;

  @override
  bool operator ==(Object other) =>
      other is PlatformSpec && platform == other.platform;

  @override
  int get hashCode => platform.hashCode;
}
