import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/oracle/oracle_registry.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;

/// Local acceptance only. Review identities are attestations, not authentication;
/// hosted CI and publication authority remain independent.
class CompletionEvidence {
  const CompletionEvidence(this.outstanding);

  final List<String> outstanding;
  bool get ready => outstanding.isEmpty;
}

class CompletionEvidenceReader {
  const CompletionEvidenceReader({
    required this.root,
    required this.controlRoot,
  });

  final Directory root;
  final Directory controlRoot;

  CompletionEvidence read(TaskState state) {
    final registry = OracleRegistry.load(root);
    final full = state.selectedLanes.any(const {'full', 'ci'}.contains);
    final runtime = _runtimeResults(state);
    final manual = _manualResults(state);
    final outstanding = <String>[];
    for (final id in state.oracleIds) {
      final oracle = registry.definitions[id];
      if (oracle == null) {
        outstanding.add('$id: oracle unavailable');
        continue;
      }
      final satisfied = switch (oracle.kind) {
        'verification-profile' =>
          state.selectedLanes.contains(oracle.target) ||
              (full && oracle.target == 'fast'),
        'contract' =>
          full &&
              oracle.target == 'docs/contracts/openapi/backend.openapi.yaml',
        'regression-test' || 'golden-test' =>
          full &&
              oracle.target.endsWith('_test.dart') &&
              const [
                'test/',
                'packages/mobile_core_kit_cli/test/',
                'packages/mobile_core_kit_lints/test/',
              ].any(oracle.target.startsWith),
        'integration-test' ||
        'maestro-flow' => runtime.contains('$id:${oracle.target}'),
        _ => manual.contains('$id:${oracle.target}'),
      };
      if (!satisfied) {
        outstanding.add(
          '$id: current passing ${oracle.kind} evidence required',
        );
      }
    }
    return CompletionEvidence(List.unmodifiable(outstanding));
  }

  Set<String> _runtimeResults(TaskState state) {
    final directory = Directory(p.join(root.path, '_artifacts', 'mobile'));
    if (!directory.existsSync() || !_within(root, directory.path)) return {};
    final latest = <String, ({DateTime at, String target, bool passed})>{};
    for (final file
        in directory
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()) {
      if (p.basename(file.path) != 'evidence.json') continue;
      final manifest = _read(root, file);
      if (manifest == null ||
          manifest['schemaVersion'] != 1 ||
          !_matches(manifest['task'], state)) {
        continue;
      }
      final run = manifest['run'];
      final entries = manifest['results'];
      if (run is! Map || run['finishedAt'] is! String || entries is! List) {
        continue;
      }
      final finished = DateTime.tryParse(run['finishedAt'] as String);
      if (finished == null) continue;
      final passed =
          run['outcome'] == 'passed' &&
          run['exitCode'] == 0 &&
          _artifactsValid(manifest['artifacts']) &&
          entries.isNotEmpty &&
          entries.every(
            (entry) =>
                entry is Map &&
                entry['outcome'] == 'passed' &&
                entry['exitCode'] == 0,
          );
      // A preflight failure has no target results and invalidates earlier runs.
      final observations = entries.isEmpty
          ? [
              for (final id in state.oracleIds) {'oracleId': id, 'target': ''},
            ]
          : entries;
      for (final entry in observations) {
        if (entry is! Map ||
            entry['oracleId'] is! String ||
            entry['target'] is! String) {
          continue;
        }
        final id = entry['oracleId'] as String;
        final previous = latest[id];
        if (previous == null ||
            finished.isAfter(previous.at) ||
            (finished.isAtSameMomentAs(previous.at) && !passed)) {
          latest[id] = (
            at: finished,
            target: entry['target'] as String,
            passed: passed,
          );
        }
      }
    }
    return {
      for (final entry in latest.entries)
        if (entry.value.passed) '${entry.key}:${entry.value.target}',
    };
  }

  Set<String> _manualResults(TaskState state) {
    final manifest = _read(
      controlRoot,
      File(
        p.join(
          controlRoot.path,
          '.tmp',
          'mobilekit',
          'tasks',
          state.taskId,
          'manual-evidence.json',
        ),
      ),
    );
    if (manifest == null ||
        manifest['schemaVersion'] != 1 ||
        !_matches(manifest['task'], state)) {
      return {};
    }
    final reviews = manifest['reviews'];
    if (reviews is! List) return {};
    final ids = <String>{};
    for (final review in reviews) {
      if (review is! Map ||
          review['oracleId'] is! String ||
          !ids.add(review['oracleId'] as String)) {
        return {};
      }
    }
    return {
      for (final entry in reviews)
        if (entry is Map &&
            entry['outcome'] == 'passed' &&
            entry['reviewer'] is String &&
            RegExp(
              r'^human:[a-z0-9][a-z0-9-]{0,63}$',
            ).hasMatch(entry['reviewer'] as String) &&
            entry['reviewedAt'] is String &&
            DateTime.tryParse(entry['reviewedAt'] as String) != null &&
            entry['oracleId'] is String &&
            entry['target'] is String &&
            _artifactsValid(entry['artifacts']))
          '${entry['oracleId']}:${entry['target']}',
    };
  }

  bool _matches(Object? value, TaskState state) =>
      value is Map &&
      value['id'] == state.taskId &&
      value['authorityHash'] == state.authorityHash &&
      value['baseRevision'] == state.baseRevision &&
      value['fingerprint'] == state.lastTaskFingerprint;

  bool _artifactsValid(Object? value) {
    if (value is! List) return false;
    final durable = value
        .whereType<Map>()
        .where((entry) => entry['durability'] == 'durable-summary')
        .toList();
    if (durable.isEmpty) return false;
    for (final entry in durable) {
      final path = entry['path'];
      if (path is! String || p.isAbsolute(path) || p.normalize(path) != path) {
        return false;
      }
      final file = File(p.join(root.path, path));
      if (!file.existsSync() ||
          !_within(root, file.path) ||
          file.lengthSync() > 1024 * 1024 ||
          file.lengthSync() != entry['sizeBytes'] ||
          sha256.convert(file.readAsBytesSync()).toString() !=
              entry['sha256']) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic>? _read(Directory base, File file) {
    if (!file.existsSync() ||
        !_within(base, file.path) ||
        file.lengthSync() > 256 * 1024) {
      return null;
    }
    try {
      final value = jsonDecode(file.readAsStringSync());
      return value is Map<String, dynamic> ? value : null;
    } on FormatException {
      return null;
    }
  }

  bool _within(Directory base, String path) => p.isWithin(
    base.resolveSymbolicLinksSync(),
    File(path).resolveSymbolicLinksSync(),
  );
}
