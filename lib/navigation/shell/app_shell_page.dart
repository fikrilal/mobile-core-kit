import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/widgets/adaptive_scaffold.dart';

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
      destinations: const [
        AdaptiveScaffoldDestination(
          label: 'Home',
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
        ),
        AdaptiveScaffoldDestination(
          label: 'Profile',
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
        ),
      ],
      body: navigationShell,
    );
  }
}
