import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/architecture_imports.dart';

PluginBase createPlugin() => _MobileCoreKitLintsPlugin();

class _MobileCoreKitLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    ArchitectureImportsLint(configs.rules['architecture_imports']),
  ];
}
