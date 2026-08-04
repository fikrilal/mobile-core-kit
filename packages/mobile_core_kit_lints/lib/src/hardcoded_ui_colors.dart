// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:mobile_core_kit_lints/src/shared.dart';
import 'package:path/path.dart' as p;

class HardcodedUiColorsLint extends DartLintRule {
  const HardcodedUiColorsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'hardcoded_ui_colors',
    problemMessage:
        'Hardcoded UI color "{0}" is not allowed. Use ColorScheme/SemanticColors roles instead.',
    correctionMessage:
        'Use `Theme.of(context).colorScheme`, `context.cs.*`, or `context.semanticColors.*`.',
    errorSeverity: ErrorSeverity.ERROR,
  );

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

    final config = _HardcodedUiColorsConfig.fromOptions(_options);
    if (!config.isIncluded(sourceRelativePath)) return;

    void reportNode(AstNode node, String preview) {
      reporter.atNode(node, _code, arguments: [preview]);
    }

    context.registry.addInstanceCreationExpression((node) {
      final rawType = node.constructorName.type.toSource();
      final typeName = rawType.split('.').last;
      if (typeName != 'Color') return;
      reportNode(node, shorten(node.toSource()));
    });

    context.registry.addPrefixedIdentifier((node) {
      final prefix = node.prefix.name;
      if (prefix != 'Colors' && prefix != 'CupertinoColors') return;

      final full = '${node.prefix.name}.${node.identifier.name}';
      if (config.allowedConstants.contains(full)) return;
      reportNode(node, full);
    });

    context.registry.addPropertyAccess((node) {
      final target = node.target;
      if (target is! SimpleIdentifier) return;
      final prefix = target.name;
      if (prefix != 'Colors' && prefix != 'CupertinoColors') return;

      final full = '$prefix.${node.propertyName.name}';
      if (config.allowedConstants.contains(full)) return;
      reportNode(node, full);
    });
  }
}

class _HardcodedUiColorsConfig {
  _HardcodedUiColorsConfig({
    required this.include,
    required this.exclude,
    required this.allowedConstants,
  });

  final List<Glob> include;
  final List<Glob> exclude;
  final Set<String> allowedConstants;

  static _HardcodedUiColorsConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const [
        'lib/features/**',
        'lib/navigation/**',
        'lib/presentation/**',
      ],
    );
    final exclude = _readGlobList(options?.json['exclude'], fallback: const []);
    final allowedConstants = _readStringSet(
      options?.json['allow'],
      fallback: const {'Colors.transparent'},
    );

    return _HardcodedUiColorsConfig(
      include: include,
      exclude: exclude,
      allowedConstants: allowedConstants,
    );
  }

  bool isIncluded(String path) {
    if (exclude.any((g) => g.matches(path))) return false;
    return include.any((g) => g.matches(path));
  }
}

List<Glob> _readGlobList(Object? raw, {required List<String> fallback}) =>
    readGlobList(raw, fallback: fallback);

Set<String> _readStringSet(Object? raw, {required Set<String> fallback}) {
  if (raw is List) {
    return {
      for (final v in raw)
        if (v is String && v.trim().isNotEmpty) v.trim(),
    };
  }
  return {...fallback};
}
