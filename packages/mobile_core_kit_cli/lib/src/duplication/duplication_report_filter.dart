import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Filters a jscpd JSON report against a reviewed-acceptable allowlist.
///
/// A duplicate pair is actionable unless it appears in the allowlist
/// (matched by canonical file-pair). Any actionable pair fails the run.
class DuplicationReportFilter {
  const DuplicationReportFilter({
    required this.rootDirectory,
    required this.output,
    required this.errorOutput,
  });

  final Directory rootDirectory;
  final StringSink output;
  final StringSink errorOutput;

  int run({
    required String reportPath,
    required String allowlistPath,
    List<String> scanRoots = const [],
    bool fatalFound = false,
  }) {
    final reportFile = File(_resolvePath(reportPath));
    if (!reportFile.existsSync()) {
      errorOutput.writeln("Report file '$reportPath' does not exist.");
      return 2;
    }

    final decoded = jsonDecode(reportFile.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      errorOutput.writeln(
        "Report file '$reportPath' is not a valid JSON object.",
      );
      return 2;
    }

    final rawDuplicates = decoded['duplicates'];
    if (rawDuplicates is! List) {
      errorOutput.writeln(
        "Report file '$reportPath' does not contain duplicates.",
      );
      return 2;
    }

    final allowlist = _loadAllowlist(allowlistPath, rootDirectory);

    final duplicates = rawDuplicates
        .whereType<Map>()
        .map((raw) => _Duplicate.fromJson(raw.cast<String, dynamic>()))
        .map((dup) => dup.toRepoRelative(scanRoots, rootDirectory))
        .toList(growable: false);

    final selfFileCount = duplicates.where((dup) => dup.isSelfFile).length;
    final crossFile = duplicates.where((dup) => !dup.isSelfFile).toList();

    final actionable = <_Duplicate>[];
    final reviewed = <_Duplicate>[];

    for (final dup in crossFile) {
      final pair = _canonicalPair(dup.firstPath, dup.secondPath);
      if (allowlist.contains(pair.$1, pair.$2)) {
        reviewed.add(dup);
      } else {
        actionable.add(dup);
      }
    }

    final actionableGroups = _group(actionable);
    final reviewedGroups = _group(reviewed);

    output.writeln('Duplication summary');
    output.writeln('Report: $reportPath');
    output.writeln('- Raw duplicates: ${duplicates.length}');
    output.writeln('- Self-file filtered out: $selfFileCount');
    output.writeln('- Cross-file duplicates: ${crossFile.length}');
    output.writeln('- Reviewed acceptable groups: ${reviewedGroups.length}');
    output.writeln('- Actionable duplicate groups: ${actionableGroups.length}');

    if (reviewedGroups.isNotEmpty) {
      output.writeln('\nReviewed acceptable groups:');
      for (final group in reviewedGroups) {
        output.writeln('- ${group.firstPath} <> ${group.secondPath}');
        output.writeln(
          '  occurrences=${group.occurrences}, '
          'maxLines=${group.maxLines}, maxTokens=${group.maxTokens}',
        );
      }
    }

    if (actionableGroups.isEmpty) {
      output.writeln('\nOK: no actionable duplication groups found.');
      return 0;
    }

    output.writeln('\nActionable groups:');
    for (final group in actionableGroups) {
      output.writeln('- ${group.firstPath} <> ${group.secondPath}');
      output.writeln(
        '  occurrences=${group.occurrences}, '
        'maxLines=${group.maxLines}, maxTokens=${group.maxTokens}',
      );
    }

    output.writeln(
      '\nFound ${actionableGroups.length} actionable duplication group(s). '
      'Add to the allowlist (with a review reason) or refactor.',
    );

    return fatalFound ? 1 : 0;
  }

  String _resolvePath(String path) {
    return p.isAbsolute(path) ? path : p.join(rootDirectory.path, path);
  }
}

_Allowlist _loadAllowlist(String allowlistPath, Directory rootDirectory) {
  final filePath = p.isAbsolute(allowlistPath)
      ? allowlistPath
      : p.join(rootDirectory.path, allowlistPath);
  final file = File(filePath);
  if (!file.existsSync()) {
    return const _Allowlist([]);
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Allowlist file must be a JSON object.');
  }

  final rawEntries = decoded['reviewedAcceptable'];
  if (rawEntries is! List) {
    return const _Allowlist([]);
  }

  final entries = rawEntries
      .whereType<Map>()
      .map((raw) => _AllowlistEntry.fromJson(raw.cast<String, dynamic>()))
      .toList(growable: false);

  return _Allowlist(entries);
}

List<_DuplicateGroup> _group(List<_Duplicate> duplicates) {
  final grouped = <String, _DuplicateGroup>{};
  for (final dup in duplicates) {
    final pair = _canonicalPair(dup.firstPath, dup.secondPath);
    final key = '${pair.$1}::${pair.$2}';
    grouped.update(
      key,
      (existing) => existing.add(dup),
      ifAbsent: () =>
          _DuplicateGroup(firstPath: pair.$1, secondPath: pair.$2)..add(dup),
    );
  }

  final groups = grouped.values.toList()
    ..sort((a, b) {
      final byLines = b.maxLines.compareTo(a.maxLines);
      if (byLines != 0) return byLines;
      return a.firstPath.compareTo(b.firstPath);
    });
  return groups;
}

class _Allowlist {
  const _Allowlist(this.entries);

  final List<_AllowlistEntry> entries;

  bool contains(String first, String second) {
    for (final entry in entries) {
      if (entry.matches(first, second)) return true;
    }
    return false;
  }
}

class _AllowlistEntry {
  const _AllowlistEntry({required this.firstPath, required this.secondPath});

  factory _AllowlistEntry.fromJson(Map<String, dynamic> json) {
    final pair = _canonicalPair(
      _normalizePath(json['firstPath'] as String? ?? ''),
      _normalizePath(json['secondPath'] as String? ?? ''),
    );
    return _AllowlistEntry(firstPath: pair.$1, secondPath: pair.$2);
  }

  final String firstPath;
  final String secondPath;

  bool matches(String first, String second) {
    return firstPath == first && secondPath == second;
  }
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

  /// Resolves a scan-root-relative path (e.g. `network/api.dart` from scanning
  /// `lib/core/infra`) to a repo-relative path (`lib/core/infra/network/...`).
  ///
  /// Tries each [scanRoots] prefix and keeps the first that resolves to an
  /// existing file. Paths already repo-relative pass through unchanged.
  _Duplicate toRepoRelative(List<String> scanRoots, Directory rootDirectory) {
    final first = _toRepoRelativePath(firstPath, scanRoots, rootDirectory);
    final second = _toRepoRelativePath(secondPath, scanRoots, rootDirectory);
    if (first == firstPath && second == secondPath) return this;

    final pair = _canonicalPair(first, second);
    return _Duplicate(
      fragment: fragment,
      firstPath: pair.$1,
      secondPath: pair.$2,
      lines: lines,
      tokens: tokens,
    );
  }

  String _toRepoRelativePath(
    String path,
    List<String> scanRoots,
    Directory rootDirectory,
  ) {
    if (path.startsWith('lib/')) return path;
    for (final root in scanRoots) {
      final candidate = _normalizePath(p.join(root, path));
      if (File(p.join(rootDirectory.path, candidate)).existsSync()) {
        return candidate;
      }
    }
    return path;
  }
}

class _DuplicateGroup {
  _DuplicateGroup({required this.firstPath, required this.secondPath});

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

(String, String) _canonicalPair(String first, String second) {
  if (first.compareTo(second) <= 0) return (first, second);
  return (second, first);
}

String _normalizePath(String path) => path.replaceAll('\\', '/');
