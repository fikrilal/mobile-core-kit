// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class HardcodedFontSizesLint extends DartLintRule {
  const HardcodedFontSizesLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'hardcoded_font_sizes',
    problemMessage:
        'Hardcoded font sizing "{0}" is not allowed. Use TextTheme roles instead.',
    correctionMessage:
        'Use `Theme.of(context).textTheme.*` (or AppText/Heading/Paragraph wrappers).',
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
      unit.accept(_HardcodedFontSizesVisitor(reporter));
    });
  }
}

class _HardcodedFontSizesVisitor extends RecursiveAstVisitor<void> {
  _HardcodedFontSizesVisitor(this._reporter);

  final ErrorReporter _reporter;

  void _report(AstNode node, String preview) {
    _reporter.atNode(node, HardcodedFontSizesLint._code, arguments: [preview]);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final rawType = node.constructorName.type.toSource();
    final typeName = rawType.split('.').last;
    if (typeName != 'TextStyle') return;

    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name != 'fontSize') continue;
      _report(arg, shorten(arg.toSource()));
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final name = node.methodName.name;
    if (name != 'copyWith' && name != 'apply') return;

    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final key = arg.name.label.name;

      if (name == 'copyWith' && key == 'fontSize') {
        _report(arg, shorten(arg.toSource()));
      }

      if (name == 'apply' &&
          (key == 'fontSizeFactor' || key == 'fontSizeDelta')) {
        _report(arg, shorten(arg.toSource()));
      }
    }
  }
}
