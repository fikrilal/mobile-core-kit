// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class ApiHelperDatasourcePolicyLint extends DartLintRule {
  const ApiHelperDatasourcePolicyLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'api_helper_datasource_policy',
    problemMessage: 'ApiHelper datasource policy violation: {0}',
    correctionMessage:
        'Add explicit `host:`, `throwOnError: false`, and (optionally) explicit `requiresAuth:` to ApiHelper calls in datasources.',
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

    final config = _ApiHelperDatasourcePolicyConfig.fromOptions(_options);
    if (!config.isIncluded(sourceRelativePath)) return;

    void report(AstNode node, String message) {
      reporter.atNode(node, _code, arguments: [message]);
    }

    context.registry.addMethodInvocation((node) {
      final target = node.target;
      if (target is! SimpleIdentifier) return;
      if (target.name != '_apiHelper') return;

      final namedArgs = node.argumentList.arguments
          .whereType<NamedExpression>();

      NamedExpression? named(String name) {
        for (final arg in namedArgs) {
          if (arg.name.label.name == name) return arg;
        }
        return null;
      }

      final hostArg = named('host');
      if (hostArg == null) {
        report(node.methodName, 'Missing required `host:` argument.');
      }

      final throwOnErrorArg = named('throwOnError');
      if (throwOnErrorArg == null) {
        report(
          node.methodName,
          'Missing required `throwOnError: false` argument.',
        );
      } else {
        final expr = throwOnErrorArg.expression;
        if (expr is! BooleanLiteral || expr.value != false) {
          report(
            throwOnErrorArg,
            '`throwOnError` must be explicitly set to `false` in datasources.',
          );
        }
      }

      if (config.requireExplicitRequiresAuth) {
        final requiresAuthArg = named('requiresAuth');
        if (requiresAuthArg == null) {
          report(
            node.methodName,
            'Missing required explicit `requiresAuth: true|false` argument.',
          );
        }
      }
    });
  }
}

class _ApiHelperDatasourcePolicyConfig {
  _ApiHelperDatasourcePolicyConfig({
    required this.include,
    required this.exclude,
    required this.requireExplicitRequiresAuth,
  });

  final List<Glob> include;
  final List<Glob> exclude;
  final bool requireExplicitRequiresAuth;

  static _ApiHelperDatasourcePolicyConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const ['lib/features/*/data/datasource/**'],
    );
    final exclude = _readGlobList(options?.json['exclude'], fallback: const []);
    final requireExplicitRequiresAuth =
        options?.json['require_requires_auth'] == true;

    return _ApiHelperDatasourcePolicyConfig(
      include: include,
      exclude: exclude,
      requireExplicitRequiresAuth: requireExplicitRequiresAuth,
    );
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
