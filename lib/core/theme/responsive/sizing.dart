import 'package:flutter/material.dart';

import 'breakpoints.dart';

export '../tokens/sizing.dart';

@Deprecated(
  'Legacy responsive helpers. Prefer adaptive layout tokens/widgets instead.',
)
class LegacyResponsiveSizing {
  LegacyResponsiveSizing._();

  static double heroHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Responsive hero height based on legacy breakpoints.
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
