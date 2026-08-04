// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class SpacingTokensLint extends DartLintRule {
  const SpacingTokensLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'spacing_tokens',
    problemMessage:
        'Hardcoded spacing "{0}" is not allowed. Use `AppSpacing.*` tokens instead.',
    correctionMessage:
        'Prefer `AppSpacing.space*` when using EdgeInsets/SizedBox for layout spacing.',
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
      unit.accept(_SpacingTokensVisitor(reporter));
    });
  }
}

class _SpacingTokensVisitor extends RecursiveAstVisitor<void> {
  _SpacingTokensVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, SpacingTokensLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;

    if (typeName == 'EdgeInsets' || typeName == 'EdgeInsetsDirectional') {
      _checkEdgeInsets(node, typeName: typeName);
      return;
    }

    if (typeName == 'SizedBox') {
      _checkSizedBox(node);
    }
  }

  void _checkEdgeInsets(
    InstanceCreationExpression node, {
    required String typeName,
  }) {
    final ctor = node.constructorName.name?.name;

    if (ctor == 'all') {
      final args = node.argumentList.arguments;
      if (args.isEmpty) return;
      final value = args.first;
      _reportIfLiteralNonZero(value);
      return;
    }

    if (ctor == 'fromLTRB' ||
        (typeName == 'EdgeInsetsDirectional' && ctor == 'fromSTEB')) {
      for (final arg in node.argumentList.arguments) {
        _reportIfLiteralNonZero(arg);
      }
      return;
    }

    if (ctor == 'only' || ctor == 'symmetric') {
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        _reportIfLiteralNonZero(arg.expression);
      }
    }
  }

  void _checkSizedBox(InstanceCreationExpression node) {
    final ctor = node.constructorName.name?.name;
    if (ctor == 'shrink') return;

    final hasChild = node.argumentList.arguments.any((arg) {
      if (arg is! NamedExpression) return false;
      return arg.name.label.name == 'child';
    });
    if (hasChild) return;

    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name != 'height' && name != 'width') continue;
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
