import 'package:go_router/go_router.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/showcase/typography_showcase_screen.dart';
import 'package:mobile_core_kit/core/design_system/widgets/button/button_showcase_screen.dart';
import 'package:mobile_core_kit/core/design_system/widgets/date_picker/date_picker_showcase_screen.dart';
import 'package:mobile_core_kit/core/design_system/widgets/field/field_showcase_screen.dart';
import 'package:mobile_core_kit/core/dev_tools/theme/theme_roles_showcase_screen.dart';
import 'package:mobile_core_kit/core/dev_tools/widget_showcases/widget_showcases_screen.dart';
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
    path: DevToolsRoutes.datePickerShowcase,
    builder: (context, state) => const DatePickerShowcaseScreen(),
  ),
  GoRoute(
    path: DevToolsRoutes.typographyShowcase,
    builder: (context, state) => const TypographyShowcaseScreen(),
  ),
];
