// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class StateOpacityTokensLint extends DartLintRule {
  const StateOpacityTokensLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'state_opacity_tokens',
    problemMessage:
        'Hardcoded state opacity "{0}" is not allowed. Use `StateOpacities.*` instead.',
    correctionMessage:
        'Replace numeric alpha values with `StateOpacities.hover/focus/pressed/dragged/disabled*` constants.',
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
      unit.accept(_StateOpacityTokensVisitor(reporter));
    });
  }
}

class _StateOpacityTokensVisitor extends RecursiveAstVisitor<void> {
  _StateOpacityTokensVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, StateOpacityTokensLint._code, arguments: [preview]);
  }

  static const Set<int> _stateOpacityPercents = {8, 12, 16, 38};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final method = node.methodName.name;
    if (method != 'withValues' && method != 'withOpacity') return;

    final receiver = node.target;
    if (receiver == null) return;

    final receiverName = _lastPropertyOrIdentifier(receiver);
    if (receiverName == null || !_looksLikeOnColor(receiverName)) return;

    final alpha = switch (method) {
      'withOpacity' => _readPositionalAlpha(node),
      _ => _readNamedAlpha(node),
    };
    if (alpha == null) return;
    final alphaPercent = (alpha * 100).round();
    if (!_stateOpacityPercents.contains(alphaPercent)) return;

    _report(node.methodName, alpha.toString());
  }

  double? _readNamedAlpha(MethodInvocation node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name != 'alpha') continue;
      return tryReadDoubleLiteral(arg.expression);
    }
    return null;
  }

  double? _readPositionalAlpha(MethodInvocation node) {
    final args = node.argumentList.arguments;
    if (args.length != 1) return null;
    final expr = args.first;
    return tryReadDoubleLiteral(expr);
  }

  bool _looksLikeOnColor(String name) {
    return RegExp(r'^on[A-Z]').hasMatch(name);
  }
}

String? _lastPropertyOrIdentifier(Expression expr) {
  return switch (expr) {
    PropertyAccess(:final propertyName) => propertyName.name,
    PrefixedIdentifier(:final identifier) => identifier.name,
    SimpleIdentifier(:final name) => name,
    _ => null,
  };
}
