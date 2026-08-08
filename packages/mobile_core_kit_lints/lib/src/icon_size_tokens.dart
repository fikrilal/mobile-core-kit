// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class IconSizeTokensLint extends DartLintRule {
  const IconSizeTokensLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'icon_size_tokens',
    problemMessage:
        'Hardcoded icon size "{0}" is not allowed. Use `AppSizing.iconSize*` tokens instead.',
    correctionMessage: 'Prefer `AppSizing.iconSize*` for icon sizing.',
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
      unit.accept(_IconSizeTokensVisitor(reporter));
    });
  }
}

class _IconSizeTokensVisitor extends RecursiveAstVisitor<void> {
  _IconSizeTokensVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, IconSizeTokensLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;

    if (typeName == 'Icon' || typeName == 'PhosphorIcon') {
      _checkNamedLiteral(node, parameterName: 'size');
      return;
    }

    if (typeName == 'IconButton') {
      _checkNamedLiteral(node, parameterName: 'iconSize');
    }
  }

  void _checkNamedLiteral(
    InstanceCreationExpression node, {
    required String parameterName,
  }) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      if (arg.name.label.name != parameterName) continue;
      _reportIfLiteralNonZero(arg.expression);
    }
  }

  void _reportIfLiteralNonZero(Expression expr) {
    final value = tryReadDoubleLiteral(expr);
    if (value == null) return;
    if (value == 0) return;
    _report(expr, shorten(expr.toSource()));
  }
}
