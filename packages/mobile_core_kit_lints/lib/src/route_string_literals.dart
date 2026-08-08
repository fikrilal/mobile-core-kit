// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class RouteStringLiteralsLint extends DartLintRule {
  const RouteStringLiteralsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'route_string_literals',
    problemMessage: 'Route string literal is not allowed: {0}',
    correctionMessage:
        'Use route constants (e.g., `AppRoutes.*`, `<feature>Routes.*`). Suppress with `// ignore: route_string_literals` for rare cases.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _goRouterMethods = {'go', 'push', 'pushReplacement'};

  static const _fallbackInclude = [
    'lib/navigation/**',
    'lib/features/**',
    'lib/presentation/**',
  ];

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
    );
    if (!config.isIncluded(sourceRelativePath)) return;

    void report(AstNode node, String preview) {
      reporter.atNode(node, _code, arguments: [preview]);
    }

    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      if (!_goRouterMethods.contains(name)) return;
      if (node.argumentList.arguments.isEmpty) return;

      final first = node.argumentList.arguments.first;
      if (first is! StringLiteral) return;

      report(first, shorten(first.toSource()));
    });

    context.registry.addInstanceCreationExpression((node) {
      final rawType = node.constructorName.type.toSource();
      final typeName = rawType.split('.').last;
      if (typeName != 'GoRoute') return;

      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        if (name != 'path') continue;
        final value = arg.expression;
        if (value is! StringLiteral) continue;
        report(value, shorten(value.toSource()));
      }
    });
  }
}
