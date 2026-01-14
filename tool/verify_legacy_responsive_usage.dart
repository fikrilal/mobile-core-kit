import 'dart:io';

import 'package:path/path.dart' as p;

Future<int> main() async {
  final repoRoot = Directory.current.path;
  final libDir = Directory(p.join(repoRoot, 'lib'));
  if (!libDir.existsSync()) {
    stderr.writeln('Missing `lib/` directory at: $repoRoot');
    return 2;
  }

  final legacyResponsiveDir = p.normalize(
    p.join(repoRoot, 'lib', 'core', 'theme', 'responsive'),
  );

  final violations = <_Violation>[];

  for (final entry in libDir.listSync(recursive: true, followLinks: false)) {
    if (entry is! File) continue;
    if (!entry.path.endsWith('.dart')) continue;

    final filePath = p.normalize(entry.path);
    if (_isWithinOrEqual(legacyResponsiveDir, filePath)) {
      continue; // Legacy module can import itself.
    }

    final contents = entry.readAsStringSync();
    for (final directive in _parseImportExportUris(contents)) {
      final resolved = _resolveUriToPath(
        repoRoot: repoRoot,
        sourceFilePath: filePath,
        uri: directive.uri,
      );
      if (resolved == null) continue;
      if (_isWithinOrEqual(legacyResponsiveDir, resolved)) {
        violations.add(
          _Violation(
            filePath: p.relative(filePath, from: repoRoot),
            directive: directive.kind,
            uri: directive.uri,
            resolvedPath: p.relative(resolved, from: repoRoot),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no imports from `core/theme/responsive/*` found.');
    return 0;
  }

  stderr.writeln(
    'Legacy responsive imports detected. Migrate to `core/adaptive/*` and/or '
    '`core/theme/tokens/*` (do not add new dependencies on '
    '`core/theme/responsive/*`).\n',
  );
  for (final violation in violations) {
    stderr.writeln(
      '- ${violation.filePath}: ${violation.directive} `${violation.uri}` '
      '→ `${violation.resolvedPath}`',
    );
  }
  return 1;
}

bool _isWithinOrEqual(String dirPath, String filePath) {
  final dir = p.normalize(dirPath);
  final file = p.normalize(filePath);
  return dir == file || p.isWithin(dir, file);
}

String? _resolveUriToPath({
  required String repoRoot,
  required String sourceFilePath,
  required String uri,
}) {
  if (uri.startsWith('dart:')) return null;

  const packagePrefix = 'package:mobile_core_kit/';
  if (uri.startsWith(packagePrefix)) {
    final libRelative = uri.substring(packagePrefix.length);
    return p.normalize(p.join(repoRoot, 'lib', libRelative));
  }

  if (uri.startsWith('package:')) {
    return null; // External package import.
  }

  // Treat as relative path import.
  final sourceDir = p.dirname(sourceFilePath);
  return p.normalize(p.join(sourceDir, uri));
}

Iterable<_ImportExportDirective> _parseImportExportUris(String contents) sync* {
  final directiveRe = RegExp(
    r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );
  for (final match in directiveRe.allMatches(contents)) {
    final kind = match.group(1);
    final uri = match.group(2);
    if (kind == null || uri == null) continue;
    yield _ImportExportDirective(kind: kind, uri: uri);
  }
}

class _ImportExportDirective {
  const _ImportExportDirective({required this.kind, required this.uri});

  final String kind;
  final String uri;
}

class _Violation {
  const _Violation({
    required this.filePath,
    required this.directive,
    required this.uri,
    required this.resolvedPath,
  });

  final String filePath;
  final String directive;
  final String uri;
  final String resolvedPath;
}
