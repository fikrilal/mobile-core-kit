import 'package:flutter/foundation.dart';

import '../adaptive_spec.dart';
import '../size_classes.dart';
import '../tokens/navigation_tokens.dart';

/// Policy for deriving shell navigation behavior from size classes.
///
/// This keeps navigation decisions **governable**:
/// - Feature code does not choose "bar vs rail vs drawer".
/// - The shell (`AdaptiveScaffold`) renders whatever `NavigationSpec.kind` says.
sealed class NavigationPolicy {
  const NavigationPolicy();

  /// Standard mapping from width class → navigation kind.
  const factory NavigationPolicy.standard() = _StandardNavigationPolicy;

  /// Forces `NavigationKind.none` (useful for nested regions or special flows).
  const factory NavigationPolicy.none() = _NoneNavigationPolicy;

  /// Derives a [NavigationSpec] for the current environment.
  NavigationSpec derive({
    required WindowWidthClass widthClass,
    required TargetPlatform platform,
    required InputSpec input,
  });
}

class _NoneNavigationPolicy extends NavigationPolicy {
  const _NoneNavigationPolicy();

  @override
  NavigationSpec derive({
    required WindowWidthClass widthClass,
    required TargetPlatform platform,
    required InputSpec input,
  }) {
    return const NavigationSpec(kind: NavigationKind.none);
  }
}

class _StandardNavigationPolicy extends NavigationPolicy {
  const _StandardNavigationPolicy();

  @override
  NavigationSpec derive({
    required WindowWidthClass widthClass,
    required TargetPlatform platform,
    required InputSpec input,
  }) {
    final kind = switch (widthClass) {
      WindowWidthClass.compact => NavigationKind.bar,
      WindowWidthClass.medium ||
      WindowWidthClass.expanded => NavigationKind.rail,
      WindowWidthClass.large => NavigationKind.extendedRail,
      WindowWidthClass.extraLarge => NavigationKind.standardDrawer,
    };

    return NavigationSpec(
      kind: kind,
      railWidth: NavigationTokens.railWidth,
      extendedRailWidth: NavigationTokens.extendedRailWidth,
      drawerWidth: NavigationTokens.drawerWidth,
    );
  }
}
