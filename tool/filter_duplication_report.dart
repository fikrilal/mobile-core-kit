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
    ..addOption(
      'allowlist',
      defaultsTo: 'tool/duplication_allowlist.json',
      help: 'Path to the reviewed-acceptable duplication allowlist JSON.',
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
        'Filters raw jscpd output into a maintainability-focused duplication',
        'summary for this repository.',
        '',
        'Detected categories:',
        '- failure mapper',
        '- bridge translation',
        '- model translation',
        '- workflow tail/helper',
        '- parser helper',
        '- formatter helper',
        '- normalization helper',
        '',
        'Reviewed acceptable duplicates can be recorded in the allowlist so',
        'they remain visible but stop showing up as actionable debt.',
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

  final allowlist = _loadAllowlist(args.option('allowlist')!);

  final duplicates = rawDuplicates
      .whereType<Map>()
      .map((raw) => _Duplicate.fromJson(raw.cast<String, dynamic>()))
      .toList(growable: false);

  final selfFileCount = duplicates.where((dup) => dup.isSelfFile).length;
  final crossFile = duplicates.where((dup) => !dup.isSelfFile).toList();

  final categorized = crossFile
      .map((dup) => _CategorizedDuplicate(dup, _categorize(dup)))
      .toList(growable: false);

  final reviewed = <_ReviewedDuplicate>[];
  final actionable = <_CategorizedDuplicate>[];
  var uncategorizedCount = 0;

  for (final entry in categorized) {
    final category = entry.category;
    if (category == null) {
      uncategorizedCount += 1;
      continue;
    }

    final match = allowlist.match(entry.duplicate, category);
    if (match != null) {
      reviewed.add(_ReviewedDuplicate(entry.duplicate, category, match));
      continue;
    }

    actionable.add(entry);
  }

  final actionableGroups = _groupActionable(actionable);
  final reviewedGroups = _groupReviewed(reviewed);

  stdout.writeln('Duplication summary');
  stdout.writeln('Report: $reportPath');
  stdout.writeln('- Raw duplicates: ${duplicates.length}');
  stdout.writeln('- Self-file filtered out: $selfFileCount');
  stdout.writeln('- Cross-file duplicates: ${crossFile.length}');
  stdout.writeln('- Uncategorized filtered out: $uncategorizedCount');
  stdout.writeln('- Reviewed acceptable groups: ${reviewedGroups.length}');
  stdout.writeln('- Actionable duplicate groups: ${actionableGroups.length}');

  if (reviewedGroups.isNotEmpty) {
    stdout.writeln('\nReviewed acceptable groups:');
    for (final group in reviewedGroups) {
      stdout.writeln(
        '- [${group.category.label}] ${group.firstPath} <> ${group.secondPath}',
      );
      stdout.writeln(
        '  reviewedOn=${group.entry.reviewedOn ?? 'n/a'}, '
        'occurrences=${group.occurrences}, '
        'maxLines=${group.maxLines}, '
        'maxTokens=${group.maxTokens}',
      );
      stdout.writeln('  reason=${group.entry.reason}');
    }
  }

  if (actionableGroups.isEmpty) {
    stdout.writeln('\nOK: no actionable duplication groups found.');
    return 0;
  }

  final categoryCounts = <_Category, int>{};
  for (final group in actionableGroups) {
    categoryCounts.update(
      group.category,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }

  stdout.writeln('\nActionable category breakdown:');
  final categories = categoryCounts.keys.toList()
    ..sort((a, b) => a.label.compareTo(b.label));
  for (final category in categories) {
    stdout.writeln('- ${category.label}: ${categoryCounts[category]}');
  }

  stdout.writeln('\nActionable groups:');
  for (final group in actionableGroups) {
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

_Allowlist _loadAllowlist(String allowlistPath) {
  final file = File(allowlistPath);
  if (!file.existsSync()) {
    return const _Allowlist([]);
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Allowlist file must be a JSON object.');
  }

  final rawEntries = decoded['reviewedAcceptable'];
  if (rawEntries == null) {
    return const _Allowlist([]);
  }
  if (rawEntries is! List) {
    throw FormatException('reviewedAcceptable must be a JSON array.');
  }

  final entries = rawEntries
      .whereType<Map>()
      .map((raw) => _AllowlistEntry.fromJson(raw.cast<String, dynamic>()))
      .toList(growable: false);

  return _Allowlist(entries);
}

List<_ActionableGroup> _groupActionable(
  List<_CategorizedDuplicate> actionable,
) {
  final grouped = <String, _ActionableGroup>{};
  for (final entry in actionable) {
    final key = _groupKey(entry.duplicate, entry.category!);
    grouped.update(
      key,
      (existing) => existing.add(entry.duplicate),
      ifAbsent: () => _ActionableGroup(
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
  return groups;
}

List<_ReviewedGroup> _groupReviewed(List<_ReviewedDuplicate> reviewed) {
  final grouped = <String, _ReviewedGroup>{};
  for (final entry in reviewed) {
    final key = _groupKey(entry.duplicate, entry.category);
    grouped.update(
      key,
      (existing) => existing.add(entry.duplicate),
      ifAbsent: () => _ReviewedGroup(
        category: entry.category,
        firstPath: entry.duplicate.firstPath,
        secondPath: entry.duplicate.secondPath,
        entry: entry.allowlistEntry,
      )..add(entry.duplicate),
    );
  }

  final groups = grouped.values.toList()
    ..sort((a, b) {
      final byCategory = a.category.label.compareTo(b.category.label);
      if (byCategory != 0) return byCategory;
      return a.firstPath.compareTo(b.firstPath);
    });
  return groups;
}

String _groupKey(_Duplicate duplicate, _Category category) {
  final pair = _canonicalPair(duplicate.firstPath, duplicate.secondPath);
  return '${category.name}::${pair.$1}::${pair.$2}';
}

_Category? _categorize(_Duplicate duplicate) {
  final pathText =
      '${duplicate.firstPath.toLowerCase()} ${duplicate.secondPath.toLowerCase()}';
  final fragment = duplicate.fragment;
  final fragmentLower = fragment.toLowerCase();

  final looksLikeBridgeTranslation =
      _bridgeTranslationPathPattern.hasMatch(pathText) &&
      fragment.contains('AuthFailure') &&
      fragment.contains('SessionFailure') &&
      _bridgeTranslationFragmentPattern.hasMatch(fragment);
  if (looksLikeBridgeTranslation) {
    return _Category.bridgeTranslation;
  }

  final looksLikeWorkflowTail =
      _workflowTailPathPattern.hasMatch(pathText) &&
      _workflowTailFragmentPattern.hasMatch(fragment);
  if (looksLikeWorkflowTail) {
    return _Category.workflowTail;
  }

  final looksLikeModelTranslation =
      _modelTranslationPathPattern.hasMatch(pathText) &&
      _modelTranslationFragmentPattern.hasMatch(fragment);
  if (looksLikeModelTranslation) {
    return _Category.modelTranslation;
  }

  final looksLikeFailureMapper =
      _failureMapperPathPattern.hasMatch(pathText) &&
      _failureMapperFragmentPattern.hasMatch(fragment);
  if (looksLikeFailureMapper) {
    return _Category.failureMapper;
  }

  if (_parserPathPattern.hasMatch(pathText) ||
      _parserFragmentPattern.hasMatch(fragment)) {
    return _Category.parserHelper;
  }

  if (_formatterPathPattern.hasMatch(pathText) ||
      _formatterFragmentPattern.hasMatch(fragment)) {
    return _Category.formatterHelper;
  }

  final normalizationSignals = _normalizationPatterns
      .where((pattern) => pattern.hasMatch(fragmentLower))
      .length;
  if (normalizationSignals >= 3) {
    return _Category.normalizationHelper;
  }

  return null;
}

final _failureMapperPathPattern = RegExp(
  r'(_failure_mapper|_error_mapper|/error/)',
  caseSensitive: false,
);
final _failureMapperFragmentPattern = RegExp(
  r'(ApiErrorCodes|SessionFailureType|ApiFailure|map[A-Z_]\w*Failure)',
);

final _bridgeTranslationPathPattern = RegExp(
  r'(/adapters/)',
  caseSensitive: false,
);
final _bridgeTranslationFragmentPattern = RegExp(
  r'(AuthFailure|SessionFailure|mapLeft\(|\.when\()',
);

final _modelTranslationPathPattern = RegExp(r'(/model/)', caseSensitive: false);
final _modelTranslationFragmentPattern = RegExp(
  r'(toSessionEntity|toTokensEntity|toEntity\(|AuthSessionEntity|AuthTokensEntity)',
);

final _workflowTailPathPattern = RegExp(r'(/usecase/)', caseSensitive: false);
final _workflowTailFragmentPattern = RegExp(
  r'(CurrentUserFetcher|SessionFailureType|fetch\(\)|_currentUserFetcher)',
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
  RegExp(r'\bisempty\b'),
  RegExp(r'\bisnotempty\b'),
  RegExp(r'==\s*null'),
  RegExp(r'!=\s*null'),
  RegExp(r'\?\?'),
];

enum _Category {
  bridgeTranslation('bridge_translation'),
  failureMapper('failure_mapper'),
  formatterHelper('formatter_helper'),
  modelTranslation('model_translation'),
  normalizationHelper('normalization_helper'),
  parserHelper('parser_helper'),
  workflowTail('workflow_tail');

  const _Category(this.label);

  final String label;

  static _Category? fromName(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final category in values) {
      if (category.label == value || category.name == value) {
        return category;
      }
    }
    return null;
  }
}

class _Allowlist {
  const _Allowlist(this.entries);

  final List<_AllowlistEntry> entries;

  _AllowlistEntry? match(_Duplicate duplicate, _Category category) {
    final pair = _canonicalPair(duplicate.firstPath, duplicate.secondPath);
    for (final entry in entries) {
      if (entry.matches(pair.$1, pair.$2, category)) {
        return entry;
      }
    }
    return null;
  }
}

class _AllowlistEntry {
  const _AllowlistEntry({
    required this.firstPath,
    required this.secondPath,
    required this.reason,
    required this.status,
    this.category,
    this.reviewedOn,
  });

  factory _AllowlistEntry.fromJson(Map<String, dynamic> json) {
    final pair = _canonicalPair(
      _normalizePath(json['firstPath'] as String? ?? ''),
      _normalizePath(json['secondPath'] as String? ?? ''),
    );
    return _AllowlistEntry(
      firstPath: pair.$1,
      secondPath: pair.$2,
      category: _Category.fromName(json['category'] as String?),
      reason: json['reason'] as String? ?? 'No reason provided.',
      reviewedOn: json['reviewedOn'] as String?,
      status: json['status'] as String? ?? 'reviewed_acceptable',
    );
  }

  final String firstPath;
  final String secondPath;
  final _Category? category;
  final String reason;
  final String? reviewedOn;
  final String status;

  bool matches(String first, String second, _Category actualCategory) {
    if (status != 'reviewed_acceptable') return false;
    if (firstPath != first || secondPath != second) return false;
    return category == null || category == actualCategory;
  }
}

class _CategorizedDuplicate {
  const _CategorizedDuplicate(this.duplicate, this.category);

  final _Duplicate duplicate;
  final _Category? category;
}

class _ReviewedDuplicate {
  const _ReviewedDuplicate(this.duplicate, this.category, this.allowlistEntry);

  final _Duplicate duplicate;
  final _Category category;
  final _AllowlistEntry allowlistEntry;
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
    final pair = _canonicalPair(
      _normalizePath(firstFile['name'] as String? ?? ''),
      _normalizePath(secondFile['name'] as String? ?? ''),
    );
    return _Duplicate(
      fragment: json['fragment'] as String? ?? '',
      firstPath: pair.$1,
      secondPath: pair.$2,
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

class _ActionableGroup {
  _ActionableGroup({
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

  _ActionableGroup add(_Duplicate duplicate) {
    occurrences += 1;
    if (duplicate.lines > maxLines) maxLines = duplicate.lines;
    if (duplicate.tokens > maxTokens) maxTokens = duplicate.tokens;
    return this;
  }
}

class _ReviewedGroup {
  _ReviewedGroup({
    required this.category,
    required this.firstPath,
    required this.secondPath,
    required this.entry,
  });

  final _Category category;
  final String firstPath;
  final String secondPath;
  final _AllowlistEntry entry;

  int occurrences = 0;
  int maxLines = 0;
  int maxTokens = 0;

  _ReviewedGroup add(_Duplicate duplicate) {
    occurrences += 1;
    if (duplicate.lines > maxLines) maxLines = duplicate.lines;
    if (duplicate.tokens > maxTokens) maxTokens = duplicate.tokens;
    return this;
  }
}

(String, String) _canonicalPair(String first, String second) {
  if (first.compareTo(second) <= 0) return (first, second);
  return (second, first);
}

String _normalizePath(String path) => path.replaceAll('\\', '/');
