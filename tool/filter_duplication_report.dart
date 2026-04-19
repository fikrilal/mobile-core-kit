import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> argv) async {
  exitCode = await _run(argv);
}

Future<int> _run(List<String> argv) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addOption(
      'report',
      defaultsTo: '.tmp/jscpd-phase1/jscpd-report.json',
      help: 'Path to the jscpd JSON report.',
    )
    ..addFlag(
      'fatal-found',
      negatable: false,
      help: 'Exit non-zero when actionable duplicate groups are found.',
    );

  final args = parser.parse(argv);
  if (args.flag('help')) {
    stdout.writeln(
      [
        'filter_duplication_report.dart',
        '',
        'Filters raw jscpd output into a Phase 1 maintainability-focused',
        'duplication summary for this repository.',
        '',
        'Phase 1 categories:',
        '- parser helpers',
        '- formatting helpers',
        '- mappers',
        '- normalization / fallback helpers',
        '',
        'Usage:',
        '  dart run tool/filter_duplication_report.dart',
        '  dart run tool/filter_duplication_report.dart --fatal-found',
        '',
        'Options:',
        parser.usage,
      ].join('\n'),
    );
    return 0;
  }

  final reportPath = args.option('report')!;
  final reportFile = File(reportPath);
  if (!reportFile.existsSync()) {
    stderr.writeln("Report file '$reportPath' does not exist.");
    return 2;
  }

  final decoded = jsonDecode(reportFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln("Report file '$reportPath' is not a valid JSON object.");
    return 2;
  }

  final rawDuplicates = decoded['duplicates'];
  if (rawDuplicates is! List) {
    stderr.writeln("Report file '$reportPath' does not contain duplicates.");
    return 2;
  }

  final duplicates = rawDuplicates
      .whereType<Map>()
      .map((raw) => _Duplicate.fromJson(raw.cast<String, dynamic>()))
      .toList(growable: false);

  final selfFileCount = duplicates.where((dup) => dup.isSelfFile).length;
  final crossFile = duplicates.where((dup) => !dup.isSelfFile).toList();

  final categorized = crossFile
      .map((dup) => _CategorizedDuplicate(dup, _categorize(dup)))
      .toList(growable: false);

  final actionable = categorized
      .where((entry) => entry.category != null)
      .toList(growable: false);
  final uncategorizedCount = categorized.length - actionable.length;

  final grouped = <String, _DuplicateGroup>{};
  for (final entry in actionable) {
    final key = _groupKey(entry.duplicate, entry.category!);
    grouped.update(
      key,
      (existing) => existing.add(entry.duplicate),
      ifAbsent: () => _DuplicateGroup(
        category: entry.category!,
        firstPath: entry.duplicate.firstPath,
        secondPath: entry.duplicate.secondPath,
      )..add(entry.duplicate),
    );
  }

  final groups = grouped.values.toList()
    ..sort((a, b) {
      final byCategory = a.category.label.compareTo(b.category.label);
      if (byCategory != 0) return byCategory;
      final byLines = b.maxLines.compareTo(a.maxLines);
      if (byLines != 0) return byLines;
      return a.firstPath.compareTo(b.firstPath);
    });

  stdout.writeln('Phase 1 duplication summary');
  stdout.writeln('Report: $reportPath');
  stdout.writeln('- Raw duplicates: ${duplicates.length}');
  stdout.writeln('- Self-file filtered out: $selfFileCount');
  stdout.writeln('- Cross-file duplicates: ${crossFile.length}');
  stdout.writeln('- Uncategorized filtered out: $uncategorizedCount');
  stdout.writeln('- Actionable duplicate groups: ${groups.length}');

  if (groups.isEmpty) {
    stdout.writeln('\nOK: no actionable Phase 1 duplication groups found.');
    return 0;
  }

  final categoryCounts = <_Category, int>{};
  for (final group in groups) {
    categoryCounts.update(
      group.category,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  stdout.writeln('\nCategory breakdown:');
  final categories = categoryCounts.keys.toList()
    ..sort((a, b) => a.label.compareTo(b.label));
  for (final category in categories) {
    stdout.writeln('- ${category.label}: ${categoryCounts[category]}');
  }

  stdout.writeln('\nActionable groups:');
  for (final group in groups) {
    stdout.writeln(
      '- [${group.category.label}] ${group.firstPath} <> ${group.secondPath}',
    );
    stdout.writeln(
      '  occurrences=${group.occurrences}, '
      'maxLines=${group.maxLines}, maxTokens=${group.maxTokens}',
    );
  }

  if (args.flag('fatal-found')) {
    return 1;
  }

  return 0;
}

String _groupKey(_Duplicate duplicate, _Category category) {
  return '${category.name}::${duplicate.firstPath}::${duplicate.secondPath}';
}

_Category? _categorize(_Duplicate duplicate) {
  final pathText =
      '${duplicate.firstPath.toLowerCase()} ${duplicate.secondPath.toLowerCase()}';
  final fragment = duplicate.fragment.toLowerCase();

  if (_mapperPathPattern.hasMatch(pathText) ||
      _mapperFragmentPattern.hasMatch(duplicate.fragment)) {
    return _Category.mapper;
  }

  if (_parserPathPattern.hasMatch(pathText) ||
      _parserFragmentPattern.hasMatch(duplicate.fragment)) {
    return _Category.parser;
  }

  if (_formatterPathPattern.hasMatch(pathText) ||
      _formatterFragmentPattern.hasMatch(duplicate.fragment)) {
    return _Category.formatter;
  }

  final normalizationSignals = _normalizationPatterns
      .where((pattern) => pattern.hasMatch(fragment))
      .length;
  if (normalizationSignals >= 3) {
    return _Category.normalization;
  }

  return null;
}

final _mapperPathPattern = RegExp(
  r'(mapper|_failure_mapper|_error_mapper|/error/)',
  caseSensitive: false,
);
final _mapperFragmentPattern = RegExp(
  r'\b(map[A-Z_]\w*|toEntity|toModel|toFailure|Failure\s+\w+\()',
);

final _parserPathPattern = RegExp(r'(parser|parse_)', caseSensitive: false);
final _parserFragmentPattern = RegExp(
  r'\b(tryParse\w*|fromString|parse[A-Z_]\w*|jsonDecode)\b',
);

final _formatterPathPattern = RegExp(
  r'(format|formatter|date_utils)',
  caseSensitive: false,
);
final _formatterFragmentPattern = RegExp(
  r'(DateFormat|format[A-Z_]\w*|displayName|label[A-Z_]\w*)',
);

final _normalizationPatterns = <RegExp>[
  RegExp(r'\.trim\(\)'),
  RegExp(r'\bisEmpty\b'),
  RegExp(r'\bisNotEmpty\b'),
  RegExp(r'==\s*null'),
  RegExp(r'!=\s*null'),
  RegExp(r'\?\?'),
];

enum _Category {
  formatter('formatter'),
  mapper('mapper'),
  normalization('normalization'),
  parser('parser');

  const _Category(this.label);

  final String label;
}

class _CategorizedDuplicate {
  const _CategorizedDuplicate(this.duplicate, this.category);

  final _Duplicate duplicate;
  final _Category? category;
}

class _Duplicate {
  const _Duplicate({
    required this.fragment,
    required this.firstPath,
    required this.secondPath,
    required this.lines,
    required this.tokens,
  });

  factory _Duplicate.fromJson(Map<String, dynamic> json) {
    final firstFile = (json['firstFile'] as Map).cast<String, dynamic>();
    final secondFile = (json['secondFile'] as Map).cast<String, dynamic>();
    return _Duplicate(
      fragment: json['fragment'] as String? ?? '',
      firstPath: _normalizePath(firstFile['name'] as String? ?? ''),
      secondPath: _normalizePath(secondFile['name'] as String? ?? ''),
      lines: json['lines'] as int? ?? 0,
      tokens: json['tokens'] as int? ?? 0,
    );
  }

  final String fragment;
  final String firstPath;
  final String secondPath;
  final int lines;
  final int tokens;

  bool get isSelfFile => firstPath == secondPath;
}

class _DuplicateGroup {
  _DuplicateGroup({
    required this.category,
    required this.firstPath,
    required this.secondPath,
  });

  final _Category category;
  final String firstPath;
  final String secondPath;

  int occurrences = 0;
  int maxLines = 0;
  int maxTokens = 0;

  _DuplicateGroup add(_Duplicate duplicate) {
    occurrences += 1;
    if (duplicate.lines > maxLines) maxLines = duplicate.lines;
    if (duplicate.tokens > maxTokens) maxTokens = duplicate.tokens;
    return this;
  }
}

String _normalizePath(String path) => path.replaceAll('\\', '/');
