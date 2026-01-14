import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';
import 'package:mobile_core_kit/core/adaptive/tokens/surface_tokens.dart';

void main() {
  group('SurfaceTokenTable.resolve', () {
    test('fullBleed is always unconstrained', () {
      for (final widthClass in WindowWidthClass.values) {
        expect(
          SurfaceTokenTable.resolve(
            kind: SurfaceKind.fullBleed,
            widthClass: widthClass,
          ).contentMaxWidth,
          isNull,
        );
      }
    });

    test('reading uses 720 max width outside compact', () {
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.reading,
          widthClass: WindowWidthClass.compact,
        ).contentMaxWidth,
        isNull,
      );

      for (final widthClass in [
        WindowWidthClass.medium,
        WindowWidthClass.expanded,
        WindowWidthClass.large,
        WindowWidthClass.extraLarge,
      ]) {
        expect(
          SurfaceTokenTable.resolve(
            kind: SurfaceKind.reading,
            widthClass: widthClass,
          ).contentMaxWidth,
          720,
        );
      }
    });

    test('form/settings use 720 max width outside compact', () {
      for (final kind in [SurfaceKind.form, SurfaceKind.settings]) {
        expect(
          SurfaceTokenTable.resolve(
            kind: kind,
            widthClass: WindowWidthClass.compact,
          ).contentMaxWidth,
          isNull,
        );

        for (final widthClass in [
          WindowWidthClass.medium,
          WindowWidthClass.expanded,
          WindowWidthClass.large,
          WindowWidthClass.extraLarge,
        ]) {
          expect(
            SurfaceTokenTable.resolve(
              kind: kind,
              widthClass: widthClass,
            ).contentMaxWidth,
            720,
          );
        }
      }
    });

    test('dashboard ramps up max width by width class', () {
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.dashboard,
          widthClass: WindowWidthClass.compact,
        ).contentMaxWidth,
        isNull,
      );
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.dashboard,
          widthClass: WindowWidthClass.medium,
        ).contentMaxWidth,
        900,
      );
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.dashboard,
          widthClass: WindowWidthClass.expanded,
        ).contentMaxWidth,
        1100,
      );
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.dashboard,
          widthClass: WindowWidthClass.large,
        ).contentMaxWidth,
        1200,
      );
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.dashboard,
          widthClass: WindowWidthClass.extraLarge,
        ).contentMaxWidth,
        1200,
      );
    });

    test('media ramps to 960 on medium and 1200 on expanded+', () {
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.media,
          widthClass: WindowWidthClass.compact,
        ).contentMaxWidth,
        isNull,
      );
      expect(
        SurfaceTokenTable.resolve(
          kind: SurfaceKind.media,
          widthClass: WindowWidthClass.medium,
        ).contentMaxWidth,
        960,
      );

      for (final widthClass in [
        WindowWidthClass.expanded,
        WindowWidthClass.large,
        WindowWidthClass.extraLarge,
      ]) {
        expect(
          SurfaceTokenTable.resolve(
            kind: SurfaceKind.media,
            widthClass: widthClass,
          ).contentMaxWidth,
          1200,
        );
      }
    });
  });
}
