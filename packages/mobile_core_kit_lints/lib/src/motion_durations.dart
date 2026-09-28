// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class MotionDurationsLint extends DartLintRule {
  const MotionDurationsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'motion_durations',
    problemMessage:
        'Hardcoded motion duration "{0}" is not allowed. Use `MotionDurations.*` tokens instead.',
    correctionMessage:
        'Prefer `MotionDurations.*` constants for UI animation durations (keep timeouts/network durations separate).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _fallbackInclude = [
    'lib/core/adaptive/widgets/**',
    'lib/core/widgets/**',
    'lib/features/**',
    'lib/navigation/**',
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

    context.registry.addCompilationUnit((unit) {
      unit.accept(_MotionDurationsVisitor(reporter));
    });
  }
}

class _MotionDurationsVisitor extends RecursiveAstVisitor<void> {
  _MotionDurationsVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, MotionDurationsLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;
    if (typeName != 'Duration') return;

    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name != 'milliseconds') continue;

      final expr = arg.expression;
      if (expr is! IntegerLiteral) return;
      final value = expr.value;
      if (value == null || value == 0) return;
      _report(expr, '${value}ms');
      return;
    }
  }
}
