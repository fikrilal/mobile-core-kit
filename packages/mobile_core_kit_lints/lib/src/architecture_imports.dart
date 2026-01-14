// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class ArchitectureImportsLint extends DartLintRule {
  const ArchitectureImportsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'architecture_imports',
    problemMessage:
        'Import "{0}" from "{1}" is not allowed (rule: {2}). {3}',
    correctionMessage:
        'Refactor to comply, or add an explicit exception in tool/lints/architecture_lints.yaml.',
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

    final configPath = _configPathFromOptions(
      projectRoot: projectRoot,
      options: _options,
    );
    final config = _ArchitectureImportsConfigCache.load(
      configPath: configPath,
      fallbackPackageName: _readPackageName(projectRoot) ?? 'mobile_core_kit',
    );
    if (config == null) return;

    void check(UriBasedDirective directive) {
      final uriValue = directive.uri.stringValue;
      if (uriValue == null) return;

      final targetRelativePath = resolveImportToProjectRelativePath(
        uri: uriValue,
        sourceFileAbsolutePath: resolver.path,
        projectRoot: projectRoot,
        packageName: config.packageName,
      );
      if (targetRelativePath == null) return;

      final violation = config.firstViolation(
        sourcePath: sourceRelativePath,
        targetPath: targetRelativePath,
      );
      if (violation == null) return;

      reporter.atNode(
        directive.uri,
        _code,
        arguments: [
          targetRelativePath,
          sourceRelativePath,
          violation.ruleId,
          violation.reason,
        ],
      );
    }

    context.registry
      ..addImportDirective(check)
      ..addExportDirective(check);
  }
}

String _configPathFromOptions({
  required String projectRoot,
  required LintOptions? options,
}) {
  final value = options?.json['config'];
  if (value is String && value.trim().isNotEmpty) {
    return p.normalize(p.join(projectRoot, value.trim()));
  }
  return p.normalize(p.join(projectRoot, 'tool/lints/architecture_lints.yaml'));
}

String? _readPackageName(String projectRoot) {
  final file = File(p.join(projectRoot, 'pubspec.yaml'));
  if (!file.existsSync()) return null;
  final contents = file.readAsStringSync();
  final match = RegExp(
    r'^name:\s*([a-zA-Z0-9_]+)\s*$',
    multiLine: true,
  ).firstMatch(contents);
  return match?.group(1);
}

bool _isGeneratedDart(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

String _normalizePath(String value) => value.replaceAll('\\', '/');

String? resolveImportToProjectRelativePath({
  required String uri,
  required String sourceFileAbsolutePath,
  required String projectRoot,
  required String packageName,
}) {
  if (uri.startsWith('dart:')) return null;

  if (uri.startsWith('package:')) {
    final rest = uri.substring('package:'.length);
    final firstSlash = rest.indexOf('/');
    if (firstSlash == -1) return null;
    final pkg = rest.substring(0, firstSlash);
    final pkgPath = rest.substring(firstSlash + 1);
    if (pkg != packageName) return null;
    return _normalizePath(p.join('lib', pkgPath));
  }

  if (uri.startsWith('asset:')) return null;

  final sourceDir = p.dirname(sourceFileAbsolutePath);
  final absoluteTarget = p.normalize(p.join(sourceDir, uri));
  return _normalizePath(p.relative(absoluteTarget, from: projectRoot));
}

class _ProjectRootFinder {
  static String? findForFile(String filePath) {
    final dir = Directory(p.dirname(filePath));

    final fromCache = _cache[dir.path];
    if (fromCache != null) return fromCache;

    final root = _find(dir);
    if (root != null) {
      _cache[dir.path] = root;
    }
    return root;
  }

  static final Map<String, String> _cache = {};

  static String? _find(Directory start) {
    Directory current = start;
    Directory? firstPubspec;

    while (true) {
      final pubspec = File(p.join(current.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        firstPubspec ??= current;
        final pkgConfig = File(
          p.join(current.path, '.dart_tool', 'package_config.json'),
        );
        if (pkgConfig.existsSync()) {
          return current.path;
        }
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        return firstPubspec?.path;
      }
      current = parent;
    }
  }
}

class _ArchitectureImportsConfigCache {
  static ArchitectureImportsConfig? load({
    required String configPath,
    required String fallbackPackageName,
  }) {
    final file = File(configPath);

    final mtime = file.existsSync() ? file.lastModifiedSync() : null;
    final cached = _cache[configPath];
    if (cached != null && cached.mtime == mtime) {
      return cached.config;
    }

    final config = ArchitectureImportsConfig.tryParse(
      yamlFile: file.existsSync() ? file : null,
      fallbackPackageName: fallbackPackageName,
    );
    _cache[configPath] = _CacheEntry(mtime: mtime, config: config);
    return config;
  }

  static final Map<String, _CacheEntry> _cache = {};
}

class _CacheEntry {
  const _CacheEntry({required this.mtime, required this.config});

  final DateTime? mtime;
  final ArchitectureImportsConfig? config;
}

class ArchitectureImportsConfig {
  ArchitectureImportsConfig({required this.packageName, required this.rules});

  final String packageName;
  final List<_ImportRule> rules;

  ArchitectureImportViolation? firstViolation({
    required String sourcePath,
    required String targetPath,
  }) {
    for (final rule in rules) {
      final violation = rule.check(
        sourcePath: sourcePath,
        targetPath: targetPath,
      );
      if (violation != null) return violation;
    }
    return null;
  }

  static ArchitectureImportsConfig? tryParse({
    required File? yamlFile,
    required String fallbackPackageName,
  }) {
    String? yaml;
    if (yamlFile != null) {
      try {
        yaml = yamlFile.readAsStringSync();
      } catch (_) {
        return null;
      }
    }
    return tryParseYaml(
      yaml: yaml,
      fallbackPackageName: fallbackPackageName,
    );
  }

  static ArchitectureImportsConfig? tryParseYaml({
    required String? yaml,
    required String fallbackPackageName,
  }) {
    if (yaml == null) {
      return ArchitectureImportsConfig(
        packageName: fallbackPackageName,
        rules: const [],
      );
    }

    Object? parsed;
    try {
      parsed = loadYaml(yaml);
    } catch (_) {
      return null;
    }
    if (parsed is! YamlMap) return null;

    final rawPackageName = parsed['package_name'];
    final packageName =
        rawPackageName is String && rawPackageName.trim().isNotEmpty
        ? rawPackageName.trim()
        : fallbackPackageName;

    final rulesYaml = parsed['rules'];
    if (rulesYaml is! YamlList) {
      return ArchitectureImportsConfig(
        packageName: packageName,
        rules: const [],
      );
    }

    final rules = <_ImportRule>[];
    for (final ruleYaml in rulesYaml) {
      if (ruleYaml is! YamlMap) continue;
      final from = ruleYaml['from'];
      final deny = ruleYaml['deny'];
      if (from is! String || deny is! YamlList) continue;

      final exceptionsYaml = ruleYaml['exceptions'];
      final exceptions = <_ImportRuleException>[];
      if (exceptionsYaml is YamlList) {
        for (final exYaml in exceptionsYaml) {
          if (exYaml is! YamlMap) continue;
          final exFrom = exYaml['from'];
          final allow = exYaml['allow'];
          if (exFrom is! String || allow is! YamlList) continue;
          exceptions.add(
            _ImportRuleException(
              from: Glob(exFrom),
              allow: [
                for (final item in allow)
                  if (item is String) Glob(item),
              ],
            ),
          );
        }
      }

      rules.add(
        _ImportRule(
          name: (ruleYaml['id'] is String) ? ruleYaml['id'] as String : null,
          from: Glob(from),
          deny: [
            for (final item in deny)
              if (item is String) Glob(item),
          ],
          exceptions: exceptions,
          reason: (ruleYaml['reason'] is String)
              ? ruleYaml['reason'] as String
              : null,
        ),
      );
    }

    return ArchitectureImportsConfig(packageName: packageName, rules: rules);
  }
}

class _ImportRule {
  _ImportRule({
    required this.name,
    required this.from,
    required this.deny,
    required this.exceptions,
    required this.reason,
  });

  final String? name;
  final Glob from;
  final List<Glob> deny;
  final List<_ImportRuleException> exceptions;
  final String? reason;

  ArchitectureImportViolation? check({
    required String sourcePath,
    required String targetPath,
  }) {
    if (!from.matches(sourcePath)) return null;
    if (!deny.any((glob) => glob.matches(targetPath))) return null;

    for (final exception in exceptions) {
      if (!exception.from.matches(sourcePath)) continue;
      if (exception.allow.any((glob) => glob.matches(targetPath))) {
        return null;
      }
    }

    return ArchitectureImportViolation(
      ruleId: name ?? '(unnamed)',
      reason:
          reason ??
          'Update import boundaries (see tool/lints/architecture_lints.yaml).',
    );
  }
}

class _ImportRuleException {
  _ImportRuleException({required this.from, required this.allow});

  final Glob from;
  final List<Glob> allow;
}

class ArchitectureImportViolation {
  const ArchitectureImportViolation({required this.ruleId, required this.reason});

  final String ruleId;
  final String reason;
}
