import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

enum ChangeSource { committed, staged, unstaged, untracked }

class RepositoryChange {
  const RepositoryChange({required this.path, required this.sources});

  final String path;
  final List<ChangeSource> sources;
}

abstract interface class GitRepository {
  Future<String> head();

  Future<List<RepositoryChange>> worktreeChanges();

  Future<List<RepositoryChange>> changesSince(String baseRevision);

  Future<String> contentFingerprint(String path);
}

class NativeGitRepository implements GitRepository {
  const NativeGitRepository(this.root);

  final Directory root;

  @override
  Future<String> head() async {
    final revision = (await _git(const [
      'rev-parse',
      '--verify',
      'HEAD',
    ])).trim();
    if (!RegExp(r'^[0-9a-f]{40,64}$').hasMatch(revision)) {
      throw const TaskControlError(
        'git.head-invalid',
        'Git returned an invalid HEAD revision.',
      );
    }
    return revision;
  }

  @override
  Future<List<RepositoryChange>> worktreeChanges() async {
    final output = await _git(const [
      'status',
      '--porcelain=v1',
      '-z',
      '--untracked-files=all',
    ]);
    final entries = output.split('\x00');
    final changes = <String, Set<ChangeSource>>{};
    for (var index = 0; index < entries.length; index += 1) {
      final entry = entries[index];
      if (entry.isEmpty || entry.length < 4) continue;
      final x = entry[0];
      final y = entry[1];
      _addStatus(changes, entry.substring(3), x, y);
      if ({'R', 'C'}.contains(x) || {'R', 'C'}.contains(y)) {
        if (index + 1 < entries.length && entries[index + 1].isNotEmpty) {
          _addStatus(changes, entries[index + 1], x, y);
          index += 1;
        }
      }
    }
    return _mapChanges(changes);
  }

  @override
  Future<List<RepositoryChange>> changesSince(String baseRevision) async {
    if (!RegExp(r'^[0-9a-f]{40,64}$').hasMatch(baseRevision)) {
      throw const TaskControlError(
        'git.base-invalid',
        'Task base revision is invalid.',
      );
    }
    final output = await _git([
      'diff',
      '--name-only',
      '--diff-filter=ACMRDT',
      '-z',
      baseRevision,
      'HEAD',
      '--',
    ]);
    final paths =
        output
            .split('\x00')
            .where((path) => path.isNotEmpty)
            .map(normalizeRepositoryPath)
            .toSet()
            .toList()
          ..sort();
    return paths
        .map(
          (path) => RepositoryChange(
            path: path,
            sources: const [ChangeSource.committed],
          ),
        )
        .toList();
  }

  @override
  Future<String> contentFingerprint(String path) async {
    final normalized = normalizeRepositoryPath(path);
    final entityPath = p.join(root.path, normalized);
    if (Link(entityPath).existsSync()) {
      return _hash('symlink:${Link(entityPath).targetSync()}');
    }
    final type = FileSystemEntity.typeSync(entityPath, followLinks: false);
    return switch (type) {
      FileSystemEntityType.notFound => _hash('missing'),
      FileSystemEntityType.file =>
        sha256.convert(File(entityPath).readAsBytesSync()).toString(),
      _ => _hash('other:$type'),
    };
  }

  Future<String> _git(List<String> arguments) async {
    final result = await Process.run(
      'git',
      arguments,
      workingDirectory: root.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode != 0) {
      final detail = (result.stderr as String).trim();
      throw TaskControlError(
        'git.command-failed',
        detail.isEmpty ? 'Git command failed.' : detail,
      );
    }
    return result.stdout as String;
  }
}

List<RepositoryChange> mergeChanges(
  Iterable<RepositoryChange> first,
  Iterable<RepositoryChange> second,
) {
  final merged = <String, Set<ChangeSource>>{};
  for (final change in [...first, ...second]) {
    merged.putIfAbsent(change.path, () => {}).addAll(change.sources);
  }
  return _mapChanges(merged);
}

void _addStatus(
  Map<String, Set<ChangeSource>> changes,
  String path,
  String x,
  String y,
) {
  final normalized = normalizeRepositoryPath(path);
  final sources = changes.putIfAbsent(normalized, () => {});
  if (x == '?' && y == '?') {
    sources.add(ChangeSource.untracked);
    return;
  }
  if (x != ' ' && x != '?') sources.add(ChangeSource.staged);
  if (y != ' ' && y != '?') sources.add(ChangeSource.unstaged);
}

List<RepositoryChange> _mapChanges(Map<String, Set<ChangeSource>> changes) {
  final result = changes.entries
      .map(
        (entry) => RepositoryChange(
          path: entry.key,
          sources: entry.value.toList()
            ..sort((left, right) => left.index.compareTo(right.index)),
        ),
      )
      .toList();
  result.sort((left, right) => left.path.compareTo(right.path));
  return result;
}

String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

class TaskControlError implements Exception {
  const TaskControlError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => '$code: $message';
}
