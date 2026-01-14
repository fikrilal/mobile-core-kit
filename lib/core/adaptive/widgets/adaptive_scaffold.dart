import 'package:flutter/material.dart';

import '../adaptive_context.dart';
import '../adaptive_spec.dart';
import '../tokens/navigation_tokens.dart';

@immutable
class AdaptiveScaffoldDestination {
  const AdaptiveScaffoldDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? tooltip;
}

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawerHeader,
    this.backgroundColor,
  });

  final List<AdaptiveScaffoldDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawerHeader;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final layout = context.adaptiveLayout;

    return switch (layout.navigation.kind) {
      NavigationKind.bar => _buildNavigationBarScaffold(context, layout),
      NavigationKind.rail => _buildRailScaffold(
        context,
        layout,
        extended: false,
      ),
      NavigationKind.extendedRail => _buildRailScaffold(
        context,
        layout,
        extended: true,
      ),
      NavigationKind.modalDrawer => _buildModalDrawerScaffold(context, layout),
      NavigationKind.standardDrawer => _buildStandardDrawerScaffold(
        context,
        layout,
      ),
      NavigationKind.none => _buildPlainScaffold(),
    };
  }

  Widget _buildPlainScaffold() {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildNavigationBarScaffold(BuildContext context, LayoutSpec layout) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: d.icon,
              selectedIcon: d.selectedIcon ?? d.icon,
              label: d.label,
              tooltip: d.tooltip,
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildRailScaffold(
    BuildContext context,
    LayoutSpec layout, {
    required bool extended,
  }) {
    final spec = layout.navigation;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              extended: extended,
              minWidth: spec.railWidth ?? NavigationTokens.railWidth,
              minExtendedWidth:
                  spec.extendedRailWidth ?? NavigationTokens.extendedRailWidth,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon ?? d.icon,
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildStandardDrawerScaffold(BuildContext context, LayoutSpec layout) {
    final spec = layout.navigation;
    final width = spec.drawerWidth ?? NavigationTokens.drawerWidth;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: width),
              child: _buildNavigationDrawer(context, persistent: true),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildModalDrawerScaffold(BuildContext context, LayoutSpec layout) {
    final spec = layout.navigation;
    final width = spec.drawerWidth ?? NavigationTokens.drawerWidth;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      drawer: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: width),
        child: _buildNavigationDrawer(context, persistent: false),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  Widget _buildNavigationDrawer(
    BuildContext context, {
    required bool persistent,
  }) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        if (!persistent) {
          Navigator.of(context).maybePop();
        }
      },
      children: [
        if (drawerHeader != null) drawerHeader!,
        for (final d in destinations)
          NavigationDrawerDestination(
            icon: d.icon,
            selectedIcon: d.selectedIcon ?? d.icon,
            label: Text(d.label),
          ),
      ],
    );
  }
}
