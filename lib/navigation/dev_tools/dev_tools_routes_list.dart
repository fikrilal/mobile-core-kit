import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/dev_tools/theme/theme_roles_showcase_screen.dart';
import 'package:mobile_core_kit/core/dev_tools/widget_showcases/widget_showcases_screen.dart';
import 'package:mobile_core_kit/core/theme/typography/showcase/typography_showcase_screen.dart';
import 'package:mobile_core_kit/core/widgets/button/button_showcase_screen.dart';
import 'package:mobile_core_kit/core/widgets/field/field_showcase_screen.dart';
import 'package:mobile_core_kit/navigation/dev_tools/dev_tools_routes.dart';

final List<GoRoute> devToolsRoutes = [
  GoRoute(
    path: DevToolsRoutes.themeRoles,
    builder: (context, state) => const ThemeRolesShowcaseScreen(),
  ),
  GoRoute(
    path: DevToolsRoutes.widgetShowcases,
    builder: (context, state) => const WidgetShowcasesScreen(),
  ),
  GoRoute(
    path: DevToolsRoutes.buttonShowcase,
    builder: (context, state) => const ButtonShowcaseScreen(),
  ),
  GoRoute(
    path: DevToolsRoutes.fieldShowcase,
    builder: (context, state) => const FieldShowcaseScreen(),
  ),
  GoRoute(
    path: DevToolsRoutes.typographyShowcase,
    builder: (context, state) => const TypographyShowcaseScreen(),
  ),
];
