import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/adaptive_spec.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/policies/modal_policy.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';

void main() {
  group('ModalPolicy.standard', () {
    const policy = ModalPolicy.standard();

    test('uses bottom sheet for compact modal presentation', () {
      final layout = _layout(WindowWidthClass.compact);

      expect(
        policy.modalPresentation(layout: layout),
        AdaptiveModalPresentation.bottomSheet,
      );
    });

    test('uses dialog for medium+ modal presentation', () {
      for (final widthClass in WindowWidthClass.values) {
        if (widthClass == WindowWidthClass.compact) continue;
        final layout = _layout(widthClass);

        expect(
          policy.modalPresentation(layout: layout),
          AdaptiveModalPresentation.dialog,
        );
      }
    });

    test('falls back to modal for compact side sheet presentation', () {
      final layout = _layout(WindowWidthClass.compact);

      expect(
        policy.sideSheetPresentation(layout: layout),
        AdaptiveSideSheetPresentation.modalFallback,
      );
    });

    test('uses side sheet for medium+ side sheet presentation', () {
      for (final widthClass in WindowWidthClass.values) {
        if (widthClass == WindowWidthClass.compact) continue;
        final layout = _layout(widthClass);

        expect(
          policy.sideSheetPresentation(layout: layout),
          AdaptiveSideSheetPresentation.sideSheet,
        );
      }
    });
  });
}

LayoutSpec _layout(WindowWidthClass widthClass) {
  return LayoutSpec(
    size: const Size(800, 600),
    widthClass: widthClass,
    heightClass: WindowHeightClass.medium,
    orientation: Orientation.landscape,
    density: LayoutDensity.comfortable,
    pagePadding: EdgeInsets.zero,
    gutter: 0,
    minTapTarget: 48,
    surfaceTokens: const <SurfaceKind, SurfaceTokens>{},
    grid: const GridSpec(columns: 2, minTileWidth: 160, maxColumns: 4),
    navigation: const NavigationSpec(kind: NavigationKind.none),
  );
}
