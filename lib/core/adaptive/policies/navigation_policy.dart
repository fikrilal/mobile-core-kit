import 'package:flutter/foundation.dart';

import '../adaptive_spec.dart';
import '../size_classes.dart';
import '../tokens/navigation_tokens.dart';

sealed class NavigationPolicy {
  const NavigationPolicy();

  const factory NavigationPolicy.standard() = _StandardNavigationPolicy;

  const factory NavigationPolicy.none() = _NoneNavigationPolicy;

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
