import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/api_helper_datasource_policy.dart';
import 'package:mobile_core_kit_lints/src/architecture_imports.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_font_sizes.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_ui_colors.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_ui_strings.dart';
import 'package:mobile_core_kit_lints/src/icon_size_tokens.dart';
import 'package:mobile_core_kit_lints/src/manual_text_scaling.dart';
import 'package:mobile_core_kit_lints/src/modal_entrypoints.dart';
import 'package:mobile_core_kit_lints/src/motion_durations.dart';
import 'package:mobile_core_kit_lints/src/radius_tokens.dart';
import 'package:mobile_core_kit_lints/src/restricted_imports.dart';
import 'package:mobile_core_kit_lints/src/route_string_literals.dart';
import 'package:mobile_core_kit_lints/src/spacing_tokens.dart';
import 'package:mobile_core_kit_lints/src/state_opacity_tokens.dart';

PluginBase createPlugin() => _MobileCoreKitLintsPlugin();

class _MobileCoreKitLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    ApiHelperDatasourcePolicyLint(
      configs.rules['api_helper_datasource_policy'],
    ),
    ArchitectureImportsLint(configs.rules['architecture_imports']),
    HardcodedUiStringsLint(configs.rules['hardcoded_ui_strings']),
    HardcodedFontSizesLint(configs.rules['hardcoded_font_sizes']),
    HardcodedUiColorsLint(configs.rules['hardcoded_ui_colors']),
    ManualTextScalingLint(configs.rules['manual_text_scaling']),
    ModalEntrypointsLint(configs.rules['modal_entrypoints']),
    IconSizeTokensLint(configs.rules['icon_size_tokens']),
    SpacingTokensLint(configs.rules['spacing_tokens']),
    StateOpacityTokensLint(configs.rules['state_opacity_tokens']),
    RadiusTokensLint(configs.rules['radius_tokens']),
    MotionDurationsLint(configs.rules['motion_durations']),
    RestrictedImportsLint(configs.rules['restricted_imports']),
    RouteStringLiteralsLint(configs.rules['route_string_literals']),
  ];
}
