import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../adaptive/tokens/surface_tokens.dart';
import '../../adaptive/widgets/app_page_container.dart';
import '../../widgets/badge/app_icon_badge.dart';
import '../../widgets/list/app_list_tile.dart';
import '../../../navigation/dev_tools/dev_tools_routes.dart';

/// Screen listing all available widget showcases for developers.
class WidgetShowcasesScreen extends StatelessWidget {
  const WidgetShowcasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Showcases')),
      body: AppPageContainer(
        surface: SurfaceKind.settings,
        safeArea: true,
        child: ListView(
          children: [
            AppListTile(
              leading: AppIconBadge(
                icon: PhosphorIcon(PhosphorIconsRegular.cursorClick, size: 24),
              ),
              title: 'Buttons',
              subtitle: 'AppButton variants, sizes & states',
              onTap: () => context.push(DevToolsRoutes.buttonShowcase),
            ),
            AppListTile(
              leading: AppIconBadge(
                icon: PhosphorIcon(PhosphorIconsRegular.textbox, size: 24),
              ),
              title: 'Text Fields',
              subtitle: 'AppTextField & form inputs',
              onTap: () => context.push(DevToolsRoutes.fieldShowcase),
            ),
            AppListTile(
              leading: AppIconBadge(
                icon: PhosphorIcon(PhosphorIconsRegular.textT, size: 24),
              ),
              title: 'Typography',
              subtitle: 'AppText, Headings & Paragraphs',
              onTap: () => context.push(DevToolsRoutes.typographyShowcase),
            ),
          ],
        ),
      ),
    );
  }
}
