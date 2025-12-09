import 'package:flutter/material.dart';
import '../system/system_primary_colors.dart';

/// Component-level Floating Action Button (FAB) colors that map system semantic colors to specific FAB component roles.
/// This represents the Component layer in our Token → System → Component color architecture.
@Deprecated('Use FloatingActionButtonThemeData with ColorScheme instead of custom component extensions.')
class ComponentFabColors extends ThemeExtension<ComponentFabColors> {
  const ComponentFabColors({
    // Primary FAB Colors
    required this.primaryContainerColor,
    required this.primaryIconColor,
  });

  // Primary FAB Colors
  final Color primaryContainerColor;
  final Color primaryIconColor;

  /// Light theme FAB colors
  static ComponentFabColors light({required SystemPrimaryColors primary}) {
    return ComponentFabColors(
      // Primary FAB - Uses primary colors for container and icon
      primaryContainerColor: primary.onPrimary,
      primaryIconColor: primary.primaryContainer,
    );
  }

  /// Dark theme FAB colors
  static ComponentFabColors dark({required SystemPrimaryColors primary}) {
    return ComponentFabColors(
      // Primary FAB - Uses primary colors for container and icon
      primaryContainerColor: primary.onPrimary,
      primaryIconColor: primary.primaryContainer,
    );
  }

  @override
  ComponentFabColors copyWith({
    Color? primaryContainerColor,
    Color? primaryIconColor,
  }) {
    return ComponentFabColors(
      primaryContainerColor:
          primaryContainerColor ?? this.primaryContainerColor,
      primaryIconColor: primaryIconColor ?? this.primaryIconColor,
    );
  }

  @override
  ComponentFabColors lerp(ThemeExtension<ComponentFabColors>? other, double t) {
    if (other is! ComponentFabColors) {
      return this;
    }
    return ComponentFabColors(
      primaryContainerColor: Color.lerp(
        primaryContainerColor,
        other.primaryContainerColor,
        t,
      )!,
      primaryIconColor: Color.lerp(
        primaryIconColor,
        other.primaryIconColor,
        t,
      )!,
    );
  }
}
