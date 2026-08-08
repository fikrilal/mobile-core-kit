// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class RadiusTokensLint extends DartLintRule {
  const RadiusTokensLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'radius_tokens',
    problemMessage:
        'Hardcoded radius "{0}" is not allowed. Use `AppRadii.*` tokens instead.',
    correctionMessage:
        'Prefer `AppRadii.radius*` (or an existing radius token) when using BorderRadius/Radius.',
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
      unit.accept(_RadiusTokensVisitor(reporter));
    });
  }
}

class _RadiusTokensVisitor extends RecursiveAstVisitor<void> {
  _RadiusTokensVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, RadiusTokensLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;
    final ctor = node.constructorName.name?.name;

    if (ctor != 'circular') return;

    if (typeName != 'BorderRadius' && typeName != 'Radius') return;

    final args = node.argumentList.arguments;
    if (args.isEmpty) return;
    final value = args.first;
    _reportIfLiteralNonZero(value);
  }

  void _reportIfLiteralNonZero(Expression expr) {
    final value = tryReadDoubleLiteral(expr);
    if (value == null) return;
    if (value == 0) return;
    _report(expr, shorten(expr.toSource()));
  }
}
