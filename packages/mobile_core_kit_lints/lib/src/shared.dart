import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Finds the repository root (nearest `pubspec.yaml`, preferring one with a
/// resolved `.dart_tool/package_config.json`). Results are cached per
/// directory.
class ProjectRootFinder {
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

/// Path-scope config shared by most lint rules: an include/exclude glob list
/// read from rule options, with a per-rule fallback.
class PathConfig {
  PathConfig({required this.include, required this.exclude});

  final List<Glob> include;
  final List<Glob> exclude;

  static PathConfig fromOptions(
    LintOptions? options, {
    required List<String> fallbackInclude,
    List<String> fallbackExclude = const [],
  }) {
    final include = readGlobList(
      options?.json['include'],
      fallback: fallbackInclude,
    );
    final exclude = readGlobList(
      options?.json['exclude'],
      fallback: fallbackExclude,
    );
    return PathConfig(include: include, exclude: exclude);
  }

  bool isIncluded(String path) {
    if (exclude.any((g) => g.matches(path))) return false;
    return include.any((g) => g.matches(path));
  }
}

List<Glob> readGlobList(Object? raw, {required List<String> fallback}) {
  if (raw is List) {
    final values = raw
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty);
    return [for (final v in values) Glob(v)];
  }
  return [for (final v in fallback) Glob(v)];
}

double? tryReadDoubleLiteral(Expression expr) {
  if (expr is IntegerLiteral) return expr.value?.toDouble();
  if (expr is DoubleLiteral) return expr.value;
  return null;
}

String normalizePath(String value) => value.replaceAll('\\', '/');

bool isGeneratedDart(String path) =>
    path.endsWith('.g.dart') || path.endsWith('.freezed.dart');

String shorten(String source, {int max = 120}) {
  final s = source.replaceAll('\n', ' ').trim();
  if (s.length <= max) return s;
  return '${s.substring(0, max - 1)}…';
}
