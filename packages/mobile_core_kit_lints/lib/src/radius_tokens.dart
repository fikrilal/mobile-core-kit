// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
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
