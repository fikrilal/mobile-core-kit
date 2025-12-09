import 'package:flutter/material.dart';

import 'breakpoints.dart';

class AppSpacing {
  AppSpacing._();

  /// Prefer 4 or 8pt grid values where possible.
  /// Non-standard constants are deprecated to encourage consistency.
  static const double space1 = 1.0;
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  @Deprecated('Prefer 4pt/8pt multiples (use space4 or space8)')
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  @Deprecated('Prefer 4pt/8pt multiples (use space12 or space16)')
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  @Deprecated('Prefer 4pt/8pt multiples (use space16 or space20)')
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  @Deprecated('Prefer 4pt/8pt multiples (use space40)')
  static const double space42 = 42.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;
  static const double space128 = 128.0;
  static const double space256 = 256.0;

  // Layout-specific spacing that changes at breakpoints
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return const EdgeInsets.all(space16);
    } else if (width < Breakpoints.md) {
      return const EdgeInsets.all(space24);
    } else if (width < Breakpoints.lg) {
      return const EdgeInsets.all(space32);
    } else {
      return const EdgeInsets.all(space40);
    }
  }

  // Content padding for cards, dialogs, etc.
  static EdgeInsets contentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return const EdgeInsets.all(space16);
    } else {
      return const EdgeInsets.all(space24);
    }
  }

  // Horizontal spacing between items in a row
  static double horizontalSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return space8;
    } else if (width < Breakpoints.md) {
      return space16;
    } else {
      return space24;
    }
  }

  // Vertical spacing between sections
  static double sectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return space32;
    } else if (width < Breakpoints.md) {
      return space48;
    } else {
      return space64;
    }
  }
}
