import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:mobile_core_kit_lints/src/architecture_imports.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_font_sizes.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_ui_colors.dart';
import 'package:mobile_core_kit_lints/src/manual_text_scaling.dart';
import 'package:mobile_core_kit_lints/src/modal_entrypoints.dart';
import 'package:mobile_core_kit_lints/src/motion_durations.dart';
import 'package:mobile_core_kit_lints/src/spacing_tokens.dart';
import 'package:mobile_core_kit_lints/src/state_opacity_tokens.dart';

PluginBase createPlugin() => _MobileCoreKitLintsPlugin();

class _MobileCoreKitLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    ArchitectureImportsLint(configs.rules['architecture_imports']),
    HardcodedFontSizesLint(configs.rules['hardcoded_font_sizes']),
    HardcodedUiColorsLint(configs.rules['hardcoded_ui_colors']),
    ManualTextScalingLint(configs.rules['manual_text_scaling']),
    ModalEntrypointsLint(configs.rules['modal_entrypoints']),
    SpacingTokensLint(configs.rules['spacing_tokens']),
    StateOpacityTokensLint(configs.rules['state_opacity_tokens']),
    MotionDurationsLint(configs.rules['motion_durations']),
  ];
}
