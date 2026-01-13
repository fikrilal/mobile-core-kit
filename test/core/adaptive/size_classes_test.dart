import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/adaptive/size_classes.dart';

void main() {
  group('widthClassFor', () {
    test('maps boundary conditions correctly', () {
      expect(widthClassFor(0), WindowWidthClass.compact);
      expect(widthClassFor(599.999), WindowWidthClass.compact);

      expect(widthClassFor(600), WindowWidthClass.medium);
      expect(widthClassFor(839.999), WindowWidthClass.medium);

      expect(widthClassFor(840), WindowWidthClass.expanded);
      expect(widthClassFor(1199.999), WindowWidthClass.expanded);

      expect(widthClassFor(1200), WindowWidthClass.large);
      expect(widthClassFor(1599.999), WindowWidthClass.large);

      expect(widthClassFor(1600), WindowWidthClass.extraLarge);
      expect(widthClassFor(10_000), WindowWidthClass.extraLarge);
    });
  });

  group('heightClassFor', () {
    test('maps boundary conditions correctly', () {
      expect(heightClassFor(0), WindowHeightClass.compact);
      expect(heightClassFor(479.999), WindowHeightClass.compact);

      expect(heightClassFor(480), WindowHeightClass.medium);
      expect(heightClassFor(899.999), WindowHeightClass.medium);

      expect(heightClassFor(900), WindowHeightClass.expanded);
      expect(heightClassFor(10_000), WindowHeightClass.expanded);
    });
  });
}
