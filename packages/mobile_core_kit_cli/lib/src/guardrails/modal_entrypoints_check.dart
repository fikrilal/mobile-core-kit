import 'dart:io';

import 'package:path/path.dart' as p;

class ModalEntrypointsCheck {
  const ModalEntrypointsCheck({
    required this.rootDirectory,
    required this.output,
    required this.errorOutput,
  });

  final Directory rootDirectory;
  final StringSink output;
  final StringSink errorOutput;

  int run({String target = 'lib'}) {
    final targetDir = _targetDirectory(target);
    if (!targetDir.existsSync()) {
      errorOutput.writeln(
        "Target directory '${targetDir.path}' does not exist.",
      );
      return 2;
    }

    final allowPrefixes = <String>['lib/core/design_system/adaptive/widgets/'];

    final bannedCalls = <_BannedCall>[
      _BannedCall('showDialog', RegExp(r'\bshowDialog\s*(?:<|\()')),
      _BannedCall(
        'showGeneralDialog',
        RegExp(r'\bshowGeneralDialog\s*(?:<|\()'),
      ),
      _BannedCall(
        'showModalBottomSheet',
        RegExp(r'\bshowModalBottomSheet\s*(?:<|\()'),
      ),
      _BannedCall(
        'showCupertinoModalPopup',
        RegExp(r'\bshowCupertinoModalPopup\s*(?:<|\()'),
      ),
      _BannedCall(
        'showCupertinoDialog',
        RegExp(r'\bshowCupertinoDialog\s*(?:<|\()'),
      ),
    ];

    final violations = <_Violation>[];
    for (final file in _dartFilesUnder(targetDir)) {
      final normalizedPath = _normalizePath(file.path, rootDirectory);
      if (_isGeneratedDart(normalizedPath)) continue;
      if (_isAllowedPath(normalizedPath, allowPrefixes)) continue;

      violations.addAll(
        _scanFile(file, rootDirectory: rootDirectory, bannedCalls: bannedCalls),
      );
    }

    if (violations.isEmpty) {
      output.writeln('OK: no disallowed modal entrypoints found.');
      return 0;
    }

    errorOutput.writeln('Disallowed modal entrypoints found.\n');
    errorOutput.writeln(
      'Rule: feature/app code MUST NOT call platform modal APIs directly.',
    );
    errorOutput.writeln(
      'Use `showAdaptiveModal` / `showAdaptiveSideSheet` or a core wrapper.\n',
    );

    for (final v in violations) {
      errorOutput.writeln('- ${v.path}:${v.line}:${v.column} → ${v.callName}');
      errorOutput.writeln('  ${v.preview}');
    }

    errorOutput.writeln('\nAllowed locations:');
    for (final prefix in allowPrefixes) {
      errorOutput.writeln('- $prefix');
    }

    return 1;
  }

  Directory _targetDirectory(String target) {
    final path = p.isAbsolute(target)
        ? target
        : p.join(rootDirectory.path, target);
    return Directory(path);
  }
}

Iterable<File> _dartFilesUnder(Directory dir) sync* {
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    yield entity;
  }
}

List<_Violation> _scanFile(
  File file, {
  required Directory rootDirectory,
  required List<_BannedCall> bannedCalls,
}) {
  final content = file.readAsStringSync();
  final normalizedPath = _normalizePath(file.path, rootDirectory);

  final violations = <_Violation>[];
  var inBlockComment = false;

  final lines = content.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final lineNumber = i + 1;
    var code = lines[i];

    if (inBlockComment) {
      final end = code.indexOf('*/');
      if (end == -1) continue;
      inBlockComment = false;
      code = code.substring(end + 2);
    }

    while (true) {
      final start = code.indexOf('/*');
      if (start == -1) break;
      final end = code.indexOf('*/', start + 2);
      if (end == -1) {
        inBlockComment = true;
        code = code.substring(0, start);
        break;
      }
      code = code.replaceRange(start, end + 2, '');
    }

    final singleLineComment = code.indexOf('//');
    if (singleLineComment != -1) {
      code = code.substring(0, singleLineComment);
    }

    if (code.trim().isEmpty) continue;

    for (final call in bannedCalls) {
      final match = call.pattern.firstMatch(code);
      if (match == null) continue;
      violations.add(
        _Violation(
          path: normalizedPath,
          line: lineNumber,
          column: match.start + 1,
          callName: call.name,
          preview: code.trim(),
        ),
      );
    }
  }

  return violations;
}

bool _isAllowedPath(String normalizedPath, List<String> allowPrefixes) {
  for (final prefix in allowPrefixes) {
    if (normalizedPath.startsWith(prefix)) return true;
  }
  return false;
}

bool _isGeneratedDart(String normalizedPath) {
  return normalizedPath.endsWith('.g.dart') ||
      normalizedPath.endsWith('.freezed.dart');
}

String _normalizePath(String value, Directory rootDirectory) {
  return p.relative(value, from: rootDirectory.path).replaceAll('\\', '/');
}

class _BannedCall {
  const _BannedCall(this.name, this.pattern);

  final String name;
  final RegExp pattern;
}

class _Violation {
  const _Violation({
    required this.path,
    required this.line,
    required this.column,
    required this.callName,
    required this.preview,
  });

  final String path;
  final int line;
  final int column;
  final String callName;
  final String preview;
}
