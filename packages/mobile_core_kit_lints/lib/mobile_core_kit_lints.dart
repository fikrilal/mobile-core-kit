import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'package:mobile_core_kit_lints/src/architecture_imports.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_font_sizes.dart';
import 'package:mobile_core_kit_lints/src/hardcoded_ui_colors.dart';
import 'package:mobile_core_kit_lints/src/manual_text_scaling.dart';

PluginBase createPlugin() => _MobileCoreKitLintsPlugin();

class _MobileCoreKitLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    ArchitectureImportsLint(configs.rules['architecture_imports']),
    HardcodedFontSizesLint(configs.rules['hardcoded_font_sizes']),
    HardcodedUiColorsLint(configs.rules['hardcoded_ui_colors']),
    ManualTextScalingLint(configs.rules['manual_text_scaling']),
  ];
}
