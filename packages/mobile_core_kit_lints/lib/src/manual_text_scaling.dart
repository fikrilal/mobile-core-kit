// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class ManualTextScalingLint extends DartLintRule {
  const ManualTextScalingLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'manual_text_scaling',
    problemMessage:
        'Manual text scaling "{0}" is not allowed. Text scaling is applied at the app root via AdaptiveScope.',
    correctionMessage:
        'Remove per-widget scaling and rely on `MediaQueryData.textScaler` (clamped via `TextScaler.clamp`).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  static const _fallbackInclude = [
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
      unit.accept(_ManualTextScalingVisitor(reporter));
    });
  }
}

class _ManualTextScalingVisitor extends RecursiveAstVisitor<void> {
  _ManualTextScalingVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, ManualTextScalingLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;
    if (typeName != 'TextScaler') return;

    final ctor = node.constructorName.name?.name;
    if (ctor != 'linear') return;

    _report(node.constructorName, shorten(node.toSource()));
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    super.visitNamedExpression(node);

    final key = node.name.label.name;
    if (key != 'textScaler' && key != 'textScaleFactor') return;

    _report(node, shorten(node.toSource()));
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    // Legacy API: MediaQuery.textScaleFactorOf(context)
    if (node.methodName.name == 'textScaleFactorOf') {
      final target = node.realTarget;
      if (target is Identifier && target.name == 'MediaQuery') {
        _report(node.methodName, 'MediaQuery.textScaleFactorOf(...)');
      }
    }
  }
}
