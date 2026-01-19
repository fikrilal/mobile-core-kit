// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
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
    final value = _tryReadDoubleLiteral(expr);
    if (value == null) return;
    if (value == 0) return;
    _report(expr, _shorten(expr.toSource()));
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

double? _tryReadDoubleLiteral(Expression expr) {
  if (expr is IntegerLiteral) return expr.value?.toDouble();
  if (expr is DoubleLiteral) return expr.value;
  return null;
}

String _normalizePath(String value) => value.replaceAll('\\', '/');

bool _isGeneratedDart(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

String _shorten(String source, {int max = 120}) {
  final s = source.replaceAll('\n', ' ').trim();
  if (s.length <= max) return s;
  return '${s.substring(0, max - 1)}…';
}

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
