import 'package:go_router/go_router.dart';

import '../../core/dev_tools/theme/theme_roles_showcase_screen.dart';
import 'dev_tools_routes.dart';

final List<GoRoute> devToolsRoutes = [
  GoRoute(
    path: DevToolsRoutes.themeRoles,
    builder: (context, state) => const ThemeRolesShowcaseScreen(),
  ),
];

