import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/core/theme/theme.dart';

void main() {
  group('Typography theme bindings (contract)', () {
    test('applyTypography wires component themes to TextTheme roles', () {
      final theme = AppTheme.light();
      final textTheme = theme.textTheme;

      expect(theme.appBarTheme.titleTextStyle, textTheme.titleLarge);
      expect(
        theme.bottomNavigationBarTheme.selectedLabelStyle,
        textTheme.labelSmall,
      );
      expect(
        theme.bottomNavigationBarTheme.unselectedLabelStyle,
        textTheme.labelSmall,
      );
      expect(theme.tabBarTheme.labelStyle, textTheme.labelMedium);
      expect(theme.tabBarTheme.unselectedLabelStyle, textTheme.labelMedium);
    });
  });
}

