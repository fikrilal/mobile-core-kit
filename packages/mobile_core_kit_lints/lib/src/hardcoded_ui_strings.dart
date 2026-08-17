// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class HardcodedUiStringsLint extends DartLintRule {
  const HardcodedUiStringsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'hardcoded_ui_strings',
    problemMessage:
        'Hardcoded UI string is not allowed. Use localization instead: {0}',
    correctionMessage:
        'Use `context.l10n.*` (or pass localized strings into widgets). Suppress with `// ignore: hardcoded_ui_strings` for rare cases.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _fallbackInclude = [
    'lib/core/widgets/**',
    'lib/features/**',
    'lib/navigation/**',
    'lib/presentation/**',
  ];

  static const _fallbackExclude = ['lib/core/dev_tools/**', '**/*showcase*'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final projectRoot = ProjectRootFinder.findForFile(resolver.path);
    if (projectRoot == null) return;

    final sourceRelativePath = normalizePath(
      p.relative(resolver.path, from: projectRoot),
    );
    if (isGeneratedDart(sourceRelativePath)) return;

    final config = PathConfig.fromOptions(
      _options,
      fallbackInclude: _fallbackInclude,
      fallbackExclude: _fallbackExclude,
    );
    if (!config.isIncluded(sourceRelativePath)) return;

    void report(AstNode node, String preview) {
      reporter.atNode(node, _code, arguments: [preview]);
    }

    context.registry.addInstanceCreationExpression((node) {
      final rawType = node.constructorName.type.toSource();
      final typeName = rawType.split('.').last;
      if (typeName != 'Text') return;

      if (node.argumentList.arguments.isEmpty) return;
      final first = node.argumentList.arguments.first;
      if (first is! StringLiteral) return;

      report(first, shorten(first.toSource()));
    });

    context.registry.addMethodInvocation((node) {
      final target = node.target;
      final isAppText = target is SimpleIdentifier && target.name == 'AppText';
      final isAppButton =
          target is SimpleIdentifier && target.name == 'AppButton';

      if (!isAppText && !isAppButton) return;

      if (isAppText) {
        if (node.argumentList.arguments.isEmpty) return;
        final first = node.argumentList.arguments.first;
        if (first is! StringLiteral) return;
        report(first, shorten(first.toSource()));
        return;
      }

      // AppButton.*(text: '...')
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        if (name != 'text') continue;
        final value = arg.expression;
        if (value is! StringLiteral) continue;
        report(value, shorten(value.toSource()));
      }
    });
  }
}
