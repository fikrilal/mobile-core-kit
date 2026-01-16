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
        'verify_hardcoded_ui_colors.dart',
        '',
        'Fails if hardcoded UI colors are used in app/feature layers.',
        '',
        'Rationale:',
        '- UI must consume semantic roles (ColorScheme + SemanticColors).',
        '- Hardcoded colors drift and are hard to police at scale.',
        '',
        'Suppress (rare; requires justification):',
        '- File: // ignore_for_file: hardcoded_ui_colors',
        '- Line: // ignore: hardcoded_ui_colors',
        '',
        'Usage:',
        '  dart run tool/verify_hardcoded_ui_colors.dart',
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

  // Only enforce in app/feature layers. Core may contain implementation details
  // (e.g. shadows) that will be tightened in a later sweep.
  final includePrefixes = <String>[
    'lib/features/',
    'lib/navigation/',
    'lib/presentation/',
  ];

  // Some literals are used as “no paint” sentinels and are acceptable.
  final allowedConstants = <String>{
    'Colors.transparent',
  };

  final banned = <_BannedPattern>[
    _BannedPattern('Color(...)', RegExp(r'\b(?:const\s+)?Color\s*\(')),
    _BannedPattern(
      'Color.fromARGB(...)',
      RegExp(r'\bColor\.fromARGB\s*\('),
    ),
    _BannedPattern(
      'Color.fromRGBO(...)',
      RegExp(r'\bColor\.fromRGBO\s*\('),
    ),
    _BannedPattern('Colors.*', RegExp(r'\bColors\.[A-Za-z_]\w*')),
    _BannedPattern(
      'CupertinoColors.*',
      RegExp(r'\bCupertinoColors\.[A-Za-z_]\w*'),
    ),
  ];

  final violations = <_Violation>[];
  for (final file in _dartFilesUnder(targetDir)) {
    final normalizedPath = _normalizePath(file.path);
    if (_isGeneratedDart(normalizedPath)) continue;
    if (!_isIncludedPath(normalizedPath, includePrefixes)) continue;

    violations.addAll(
      _scanFile(
        file,
        banned: banned,
        allowedConstants: allowedConstants,
      ),
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('OK: no hardcoded UI colors found.');
    return 0;
  }

  stderr.writeln('Hardcoded UI colors found.\n');
  stderr.writeln('Rule: UI code MUST consume roles, not hardcoded colors.');
  stderr.writeln(
    'Use `Theme.of(context).colorScheme`, `context.cs.*`, or `context.semanticColors.*`.\n',
  );

  for (final v in violations) {
    stderr.writeln('- ${v.path}:${v.line}:${v.column} → ${v.patternName}');
    stderr.writeln('  ${v.preview}');
  }

  stderr.writeln('\nEnforced paths:');
  for (final prefix in includePrefixes) {
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
  required List<_BannedPattern> banned,
  required Set<String> allowedConstants,
}) {
  final content = file.readAsStringSync();
  final normalizedPath = _normalizePath(file.path);

  if (content.contains('ignore_for_file: hardcoded_ui_colors')) {
    return const [];
  }

  final violations = <_Violation>[];
  var inBlockComment = false;

  final lines = content.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final lineNumber = i + 1;
    var code = lines[i];

    if (code.contains('ignore: hardcoded_ui_colors')) continue;

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

    for (final pattern in banned) {
      final match = pattern.regex.firstMatch(code);
      if (match == null) continue;

      // Allow specific constants like Colors.transparent.
      if (pattern.name == 'Colors.*') {
        final full = match.group(0);
        if (full != null && allowedConstants.contains(full)) continue;
      }

      violations.add(
        _Violation(
          path: normalizedPath,
          line: lineNumber,
          column: match.start + 1,
          patternName: pattern.name,
          preview: code.trim(),
        ),
      );
    }
  }

  return violations;
}

bool _isIncludedPath(String normalizedPath, List<String> includePrefixes) {
  for (final prefix in includePrefixes) {
    if (normalizedPath.startsWith(prefix)) return true;
  }
  return false;
}

bool _isGeneratedDart(String normalizedPath) {
  return normalizedPath.endsWith('.g.dart') ||
      normalizedPath.endsWith('.freezed.dart');
}

String _normalizePath(String value) => value.replaceAll('\\', '/');

class _BannedPattern {
  const _BannedPattern(this.name, this.regex);

  final String name;
  final RegExp regex;
}

class _Violation {
  const _Violation({
    required this.path,
    required this.line,
    required this.column,
    required this.patternName,
    required this.preview,
  });

  final String path;
  final int line;
  final int column;
  final String patternName;
  final String preview;
}

