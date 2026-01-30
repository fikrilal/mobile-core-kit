import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/adaptive_scaffold.dart';
import 'package:mobile_core_kit/core/design_system/localization/l10n.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        AdaptiveScaffoldDestination(
          label: context.l10n.commonHome,
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
        ),
        AdaptiveScaffoldDestination(
          label: context.l10n.commonProfile,
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
        ),
      ],
      body: navigationShell,
    );
  }
}
