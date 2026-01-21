// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
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
      return _tryReadDoubleLiteral(arg.expression);
    }
    return null;
  }

  double? _readPositionalAlpha(MethodInvocation node) {
    final args = node.argumentList.arguments;
    if (args.length != 1) return null;
    final expr = args.first;
    return _tryReadDoubleLiteral(expr);
  }

  bool _looksLikeOnColor(String name) {
    return RegExp(r'^on[A-Z]').hasMatch(name);
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

String? _lastPropertyOrIdentifier(Expression expr) {
  return switch (expr) {
    PropertyAccess(:final propertyName) => propertyName.name,
    PrefixedIdentifier(:final identifier) => identifier.name,
    SimpleIdentifier(:final name) => name,
    _ => null,
  };
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
