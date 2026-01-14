import 'package:flutter/material.dart';

import '../tokens/spacing.dart';
import 'breakpoints.dart';

export '../tokens/spacing.dart';

@Deprecated(
  'Legacy responsive helpers. Prefer `context.adaptiveLayout` tokens and '
  '`AppPageContainer` instead.',
)
class LegacyResponsiveSpacing {
  LegacyResponsiveSpacing._();

  /// Layout-specific spacing that changes at legacy breakpoints.
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return const EdgeInsets.all(AppSpacing.space16);
    } else if (width < Breakpoints.md) {
      return const EdgeInsets.all(AppSpacing.space24);
    } else if (width < Breakpoints.lg) {
      return const EdgeInsets.all(AppSpacing.space32);
    } else {
      return const EdgeInsets.all(AppSpacing.space40);
    }
  }

  /// Content padding for cards, dialogs, etc.
  static EdgeInsets contentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return const EdgeInsets.all(AppSpacing.space16);
    } else {
      return const EdgeInsets.all(AppSpacing.space24);
    }
  }

  /// Horizontal spacing between items in a row.
  static double horizontalSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return AppSpacing.space8;
    } else if (width < Breakpoints.md) {
      return AppSpacing.space16;
    } else {
      return AppSpacing.space24;
    }
  }

  /// Vertical spacing between sections.
  static double sectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.sm) {
      return AppSpacing.space32;
    } else if (width < Breakpoints.md) {
      return AppSpacing.space48;
    } else {
      return AppSpacing.space64;
    }
  }
}
