// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class RestrictedImportsLint extends DartLintRule {
  const RestrictedImportsLint(this._options) : super(code: _code);

  final LintOptions? _options;

  static const _code = LintCode(
    name: 'restricted_imports',
    problemMessage: 'Import "{0}" from "{1}" is not allowed. {2}',
    correctionMessage:
        'Use an approved wrapper (usually under `lib/core/**`) or update the allowlist in `analysis_options.yaml`.',
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

    final config = RestrictedImportsConfig.fromOptions(_options);
    if (!config.isIncluded(sourceRelativePath)) return;

    void check(UriBasedDirective directive) {
      final uriValue = directive.uri.stringValue;
      if (uriValue == null || uriValue.trim().isEmpty) return;

      final violation = config.firstViolation(
        sourcePath: sourceRelativePath,
        importUri: uriValue,
      );
      if (violation == null) return;

      reporter.atNode(
        directive.uri,
        _code,
        arguments: [uriValue, sourceRelativePath, violation.message],
      );
    }

    context.registry
      ..addImportDirective(check)
      ..addExportDirective(check);
  }
}

class RestrictedImportsConfig {
  RestrictedImportsConfig({
    required this.include,
    required this.exclude,
    required this.rules,
  });

  final List<Glob> include;
  final List<Glob> exclude;
  final List<RestrictedImportRule> rules;

  static RestrictedImportsConfig fromOptions(LintOptions? options) {
    final include = _readGlobList(
      options?.json['include'],
      fallback: const ['lib/**'],
    );
    final exclude = _readGlobList(options?.json['exclude'], fallback: const []);

    final rules = _readRules(options?.json['rules']);
    return RestrictedImportsConfig(
      include: include,
      exclude: exclude,
      rules: rules.isEmpty ? _defaultRules : rules,
    );
  }

  bool isIncluded(String path) {
    if (exclude.any((g) => g.matches(path))) return false;
    return include.any((g) => g.matches(path));
  }

  RestrictedImportViolation? firstViolation({
    required String sourcePath,
    required String importUri,
  }) {
    for (final rule in rules) {
      if (!rule.matchesUri(importUri)) continue;
      if (rule.isAllowedSource(sourcePath)) return null;
      return RestrictedImportViolation(
        rule: rule,
        sourcePath: sourcePath,
        importUri: importUri,
      );
    }
    return null;
  }

  static List<RestrictedImportRule> _readRules(Object? raw) {
    if (raw is! List) return const [];

    final parsed = <RestrictedImportRule>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final uri = item['uri'];
      final allow = item['allow'];
      final message = item['message'];
      if (uri is! String || uri.trim().isEmpty) continue;

      final allowGlobs = _readGlobList(allow, fallback: const []);
      if (allowGlobs.isEmpty) continue;

      parsed.add(
        RestrictedImportRule(
          uriPrefix: uri.trim(),
          allow: allowGlobs,
          message: (message is String && message.trim().isNotEmpty)
              ? message.trim()
              : null,
        ),
      );
    }
    return parsed;
  }
}

class RestrictedImportRule {
  const RestrictedImportRule({
    required this.uriPrefix,
    required this.allow,
    this.message,
  });

  final String uriPrefix;
  final List<Glob> allow;
  final String? message;

  bool matchesUri(String uri) => uri.startsWith(uriPrefix);

  bool isAllowedSource(String sourcePath) =>
      allow.any((g) => g.matches(sourcePath));

  String allowedHint() {
    final patterns = allow.map((g) => g.pattern).toList()..sort();
    return 'Allowed only from: ${patterns.join(', ')}';
  }
}

class RestrictedImportViolation {
  const RestrictedImportViolation({
    required this.rule,
    required this.sourcePath,
    required this.importUri,
  });

  final RestrictedImportRule rule;
  final String sourcePath;
  final String importUri;

  String get message => rule.message ?? rule.allowedHint();
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

final List<RestrictedImportRule> _defaultRules = [
  RestrictedImportRule(
    uriPrefix: 'package:dio/dio.dart',
    allow: [Glob('lib/core/infra/network/**')],
    message: 'Use `lib/core/infra/network/**` wrappers (ApiClient/ApiHelper).',
  ),
  RestrictedImportRule(
    uriPrefix: 'package:firebase_analytics/firebase_analytics.dart',
    allow: [Glob('lib/core/runtime/analytics/**')],
    message: 'Use analytics wrappers under `lib/core/runtime/analytics/**`.',
  ),
  RestrictedImportRule(
    uriPrefix: 'package:firebase_crashlytics/firebase_crashlytics.dart',
    allow: [
      Glob('lib/core/platform/crash_reporting/**'),
      Glob('lib/core/runtime/early_errors/**'),
      Glob('lib/core/foundation/utilities/log_utils.dart'),
      Glob('lib/core/di/**'),
    ],
    message:
        'Use crash reporting wrappers under `lib/core/platform/crash_reporting/**`.',
  ),
  RestrictedImportRule(
    uriPrefix: 'package:firebase_messaging/firebase_messaging.dart',
    allow: [Glob('lib/core/platform/push/**'), Glob('lib/main*.dart')],
    message: 'Use push wrappers under `lib/core/platform/push/**`.',
  ),
  RestrictedImportRule(
    uriPrefix: 'package:shared_preferences/shared_preferences.dart',
    allow: [
      Glob('lib/core/infra/storage/prefs/**'),
      // TEMP: profile draft is feature-owned local persistence.
      Glob(
        'lib/features/user/data/datasource/local/profile_draft_local_datasource.dart',
      ),
      Glob(
        'lib/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart',
      ),
    ],
    message:
        'Use shared preferences only in stores/services; avoid direct usage in most features.',
  ),
  RestrictedImportRule(
    uriPrefix: 'package:flutter_secure_storage/flutter_secure_storage.dart',
    allow: [Glob('lib/core/infra/storage/secure/**')],
    message:
        'Use secure storage wrappers under `lib/core/infra/storage/secure/**`.',
  ),
  RestrictedImportRule(
    uriPrefix: 'dart:developer',
    allow: [Glob('lib/core/foundation/utilities/log_utils.dart')],
    message:
        'Use `Log.*` helpers from `lib/core/foundation/utilities/log_utils.dart`.',
  ),
];
