import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/adaptive/adaptive_spec_builder.dart';
import 'package:mobile_core_kit/core/adaptive/policies/input_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/motion_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/navigation_policy.dart';
import 'package:mobile_core_kit/core/adaptive/policies/text_scale_policy.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';

void main() {
  group('AdaptiveSpecBuilder.build', () {
    test('computes a compact spec from constraints + media', () {
      final media = MediaQueryData(
        size: const Size(500, 800),
        textScaler: TextScaler.linear(1.0),
      );

      final spec = AdaptiveSpecBuilder.build(
        constraints: const BoxConstraints.tightFor(width: 500, height: 800),
        media: media,
        platform: TargetPlatform.android,
        textScalePolicy: const TextScalePolicy.unclamped(),
        navigationPolicy: const NavigationPolicy.standard(),
        motionPolicy: const MotionPolicy.standard(),
        inputPolicy: const InputPolicy.standard(),
      );

      expect(spec.layout.widthClass, WindowWidthClass.compact);
      expect(spec.layout.heightClass, WindowHeightClass.medium);
      expect(
        spec.layout.pagePadding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(spec.layout.gutter, 12);
      expect(spec.layout.minTapTarget, 48);
      expect(spec.layout.navigation.kind, NavigationKind.bar);
      expect(spec.input.mode, InputMode.touch);
      expect(spec.text.boldText, isFalse);
    });

    test('computes an expanded spec and rail navigation defaults', () {
      final media = MediaQueryData(
        size: const Size(900, 700),
        textScaler: TextScaler.linear(1.0),
      );

      final spec = AdaptiveSpecBuilder.build(
        constraints: const BoxConstraints.tightFor(width: 900, height: 700),
        media: media,
        platform: TargetPlatform.android,
        textScalePolicy: const TextScalePolicy.unclamped(),
        navigationPolicy: const NavigationPolicy.standard(),
        motionPolicy: const MotionPolicy.standard(),
        inputPolicy: const InputPolicy.standard(),
      );

      expect(spec.layout.widthClass, WindowWidthClass.expanded);
      expect(
        spec.layout.pagePadding,
        const EdgeInsets.symmetric(horizontal: 32),
      );
      expect(spec.layout.navigation.kind, NavigationKind.rail);
    });
  });

  group('LayoutSpec equality/hashCode', () {
    test('surfaceTokens hashing is stable across map instances', () {
      const grid = GridSpec(columns: 2, minTileWidth: 160, maxColumns: 2);
      const navigation = NavigationSpec(
        kind: NavigationKind.bar,
        railWidth: 72,
        extendedRailWidth: 256,
        drawerWidth: 304,
      );

      final tokensA = Map<SurfaceKind, SurfaceTokens>.unmodifiable({
        SurfaceKind.reading: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.form: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.settings: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.dashboard: const SurfaceTokens(contentMaxWidth: 1200),
        SurfaceKind.media: const SurfaceTokens(contentMaxWidth: 1200),
        SurfaceKind.fullBleed: const SurfaceTokens(contentMaxWidth: null),
      });

      final tokensB = Map<SurfaceKind, SurfaceTokens>.unmodifiable({
        SurfaceKind.reading: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.form: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.settings: const SurfaceTokens(contentMaxWidth: 720),
        SurfaceKind.dashboard: const SurfaceTokens(contentMaxWidth: 1200),
        SurfaceKind.media: const SurfaceTokens(contentMaxWidth: 1200),
        SurfaceKind.fullBleed: const SurfaceTokens(contentMaxWidth: null),
      });

      final a = LayoutSpec(
        size: const Size(800, 600),
        widthClass: WindowWidthClass.medium,
        heightClass: WindowHeightClass.medium,
        orientation: Orientation.landscape,
        density: LayoutDensity.comfortable,
        pagePadding: const EdgeInsets.symmetric(horizontal: 24),
        gutter: 16,
        minTapTarget: 48,
        surfaceTokens: tokensA,
        grid: grid,
        navigation: navigation,
      );

      final b = LayoutSpec(
        size: const Size(800, 600),
        widthClass: WindowWidthClass.medium,
        heightClass: WindowHeightClass.medium,
        orientation: Orientation.landscape,
        density: LayoutDensity.comfortable,
        pagePadding: const EdgeInsets.symmetric(horizontal: 24),
        gutter: 16,
        minTapTarget: 48,
        surfaceTokens: tokensB,
        grid: grid,
        navigation: navigation,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
