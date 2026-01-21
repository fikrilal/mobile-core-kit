// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
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

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final projectRoot = _ProjectRootFinder.findForFile(resolver.path);
    if (projectRoot == null) return;

    final sourceRelativePath = _normalizePath(
      p.relative(resolver.path, from: projectRoot),
    );
    if (_isGeneratedDart(sourceRelativePath)) return;

    final config = _PathConfig.fromOptions(_options);
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

class _PathConfig {
  _PathConfig({required this.include, required this.exclude});

  final List<Glob> include;
  final List<Glob> exclude;

  static _PathConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const [
        'lib/core/adaptive/widgets/**',
        'lib/core/widgets/**',
        'lib/features/**',
        'lib/navigation/**',
        'lib/presentation/**',
      ],
    );
    final exclude = _readGlobList(options?.json['exclude'], fallback: const []);

    return _PathConfig(include: include, exclude: exclude);
  }

  bool isIncluded(String path) {
    if (exclude.any((g) => g.matches(path))) return false;
    return include.any((g) => g.matches(path));
  }
}

List<Glob> _readGlobList(Object? raw, {required List<String> fallback}) {
  if (raw is List) {
    final values = raw
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty);
    return [for (final v in values) Glob(v)];
  }
  return [for (final v in fallback) Glob(v)];
}

String _normalizePath(String value) => value.replaceAll('\\', '/');

bool _isGeneratedDart(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

class _ProjectRootFinder {
  static String? findForFile(String filePath) {
    var dir = p.dirname(filePath);
    while (true) {
      final candidate = p.join(dir, 'pubspec.yaml');
      if (File(candidate).existsSync()) return dir;
      final parent = p.dirname(dir);
      if (parent == dir) return null;
      dir = parent;
    }
  }
}
