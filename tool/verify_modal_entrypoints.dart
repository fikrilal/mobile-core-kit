import 'dart:io';

import 'package:args/args.dart';

Future<int> main(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption('target', defaultsTo: 'lib');

  final args = parser.parse(argv);
  if (args.flag('help')) {
    stdout.writeln(
      [
        'verify_modal_entrypoints.dart',
        '',
        'Fails if disallowed modal entrypoints are used outside the allowlist.',
        '',
        'Usage:',
        '  dart run tool/verify_modal_entrypoints.dart',
        '',
        'Options:',
        parser.usage,
      ].join('\n'),
    );
    return 0;
  }

  final targetDir = Directory(args.option('target')!);
  if (!targetDir.existsSync()) {
    stderr.writeln("Target directory '${targetDir.path}' does not exist.");
    return 2;
  }

  final allowPrefixes = <String>['lib/core/adaptive/widgets/'];

  final bannedCalls = <_BannedCall>[
    _BannedCall('showDialog', RegExp(r'\bshowDialog\s*(?:<|\()')),
    _BannedCall('showGeneralDialog', RegExp(r'\bshowGeneralDialog\s*(?:<|\()')),
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
    final normalizedPath = _normalizePath(file.path);
    if (_isGeneratedDart(normalizedPath)) continue;
    if (_isAllowedPath(normalizedPath, allowPrefixes)) continue;

    violations.addAll(_scanFile(file, bannedCalls: bannedCalls));
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no disallowed modal entrypoints found.');
    return 0;
  }

  stderr.writeln('Disallowed modal entrypoints found.\n');
  stderr.writeln(
    'Rule: feature/app code MUST NOT call platform modal APIs directly.',
  );
  stderr.writeln(
    'Use `showAdaptiveModal` / `showAdaptiveSideSheet` or a core wrapper.\n',
  );

  for (final v in violations) {
    stderr.writeln('- ${v.path}:${v.line}:${v.column} → ${v.callName}');
    stderr.writeln('  ${v.preview}');
  }

  stderr.writeln('\nAllowed locations:');
  for (final prefix in allowPrefixes) {
    stderr.writeln('- $prefix');
  }

  return 1;
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
  required List<_BannedCall> bannedCalls,
}) {
  final content = file.readAsStringSync();
  final normalizedPath = _normalizePath(file.path);

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

String _normalizePath(String value) => value.replaceAll('\\', '/');

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
