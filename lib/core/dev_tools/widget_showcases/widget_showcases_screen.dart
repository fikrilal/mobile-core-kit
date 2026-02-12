import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/tokens/surface_tokens.dart';
import 'package:mobile_core_kit/core/design_system/adaptive/widgets/app_page_container.dart';
import 'package:mobile_core_kit/core/design_system/widgets/badge/app_icon_badge.dart';
import 'package:mobile_core_kit/core/design_system/widgets/collection/collection.dart';
import 'package:mobile_core_kit/core/design_system/widgets/list/app_list_tile.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Screen listing all available widget showcases for developers.
class WidgetShowcasesScreen extends StatelessWidget {
  const WidgetShowcasesScreen({super.key});

  static const _showcaseItems = <_WidgetShowcaseItem>[
    _WidgetShowcaseItem(
      icon: PhosphorIconsRegular.cursorClick,
      title: 'Buttons',
      subtitle: 'AppButton variants, sizes & states',
      route: DevToolsRoutes.buttonShowcase,
    ),
    _WidgetShowcaseItem(
      icon: PhosphorIconsRegular.textbox,
      title: 'Text Fields',
      subtitle: 'AppTextField & form inputs',
      route: DevToolsRoutes.fieldShowcase,
    ),
    _WidgetShowcaseItem(
      icon: PhosphorIconsRegular.calendarDots,
      title: 'Date Picker',
      subtitle: 'Single and range date pickers',
      route: DevToolsRoutes.datePickerShowcase,
    ),
    _WidgetShowcaseItem(
      icon: PhosphorIconsRegular.textT,
      title: 'Typography',
      subtitle: 'AppText, Headings & Paragraphs',
      route: DevToolsRoutes.typographyShowcase,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Showcases')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: AppPaginatedCollectionView<_WidgetShowcaseItem>(
          status: _showcaseItems.isEmpty
              ? AppCollectionStatus.empty
              : AppCollectionStatus.success,
          items: _showcaseItems,
          onRefresh: () async {},
          hasMore: false,
          itemBuilder: (context, item, index) {
            return AppListTile(
              leading: AppIconBadge(icon: PhosphorIcon(item.icon, size: 24)),
              title: item.title,
              subtitle: item.subtitle,
              onTap: () => context.push(item.route),
            );
          },
        ),
      ),
    );
  }
}

class _WidgetShowcaseItem {
  const _WidgetShowcaseItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
