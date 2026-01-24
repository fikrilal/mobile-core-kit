// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class HardcodedUiStringsLint extends DartLintRule {
  const HardcodedUiStringsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'hardcoded_ui_strings',
    problemMessage:
        'Hardcoded UI string is not allowed. Use localization instead: {0}',
    correctionMessage:
        'Use `context.l10n.*` (or pass localized strings into widgets). Suppress with `// ignore: hardcoded_ui_strings` for rare cases.',
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

    final config = _HardcodedUiStringsConfig.fromOptions(_options);
    if (!config.isIncluded(sourceRelativePath)) return;

    void report(AstNode node, String preview) {
      reporter.atNode(node, _code, arguments: [preview]);
    }

    context.registry.addInstanceCreationExpression((node) {
      final rawType = node.constructorName.type.toSource();
      final typeName = rawType.split('.').last;
      if (typeName != 'Text') return;

      if (node.argumentList.arguments.isEmpty) return;
      final first = node.argumentList.arguments.first;
      if (first is! StringLiteral) return;

      report(first, _shorten(first.toSource()));
    });

    context.registry.addMethodInvocation((node) {
      final target = node.target;
      final isAppText = target is SimpleIdentifier && target.name == 'AppText';
      final isAppButton =
          target is SimpleIdentifier && target.name == 'AppButton';

      if (!isAppText && !isAppButton) return;

      if (isAppText) {
        if (node.argumentList.arguments.isEmpty) return;
        final first = node.argumentList.arguments.first;
        if (first is! StringLiteral) return;
        report(first, _shorten(first.toSource()));
        return;
      }

      // AppButton.*(text: '...')
      for (final arg in node.argumentList.arguments) {
        if (arg is! NamedExpression) continue;
        final name = arg.name.label.name;
        if (name != 'text') continue;
        final value = arg.expression;
        if (value is! StringLiteral) continue;
        report(value, _shorten(value.toSource()));
      }
    });
  }
}

class _HardcodedUiStringsConfig {
  _HardcodedUiStringsConfig({required this.include, required this.exclude});

  final List<Glob> include;
  final List<Glob> exclude;

  static _HardcodedUiStringsConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const [
        'lib/core/widgets/**',
        'lib/features/**',
        'lib/navigation/**',
        'lib/presentation/**',
      ],
    );
    final exclude = _readGlobList(
      options?.json['exclude'],
      fallback: const ['lib/core/dev_tools/**', '**/*showcase*'],
    );

    return _HardcodedUiStringsConfig(include: include, exclude: exclude);
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
