import 'package:flutter/material.dart';
import 'breakpoints.dart';

class AppSizing {
  AppSizing._();

  // Fixed component sizes (non-responsive)
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double avatarSizeExtraSmall = 24.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  static const double avatarSizeExtraLarge = 80.0;

  // Component-specific responsive utilities
  static double heroHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Responsive hero height based on device type
    if (width < Breakpoints.sm) {
      return (height * 0.25).clamp(120.0, 200.0); // Smaller on mobile
    } else if (width < Breakpoints.lg) {
      return (height * 0.3).clamp(180.0, 300.0); // Medium on tablets
    } else {
      return (height * 0.35).clamp(250.0, 400.0); // Larger on desktop
    }
  }

  static double modalWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return width * 0.9; // 90% of screen width on mobile
    } else if (width < Breakpoints.md) {
      return 450.0; // Fixed width on small tablets
    } else {
      return 550.0; // Fixed width on desktop
    }
  }
}
