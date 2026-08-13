import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:path/path.dart' as p;

class GitWorktreeInfo {
  const GitWorktreeInfo({
    required this.path,
    required this.head,
    required this.branch,
  });

  final String path;
  final String head;
  final String? branch;
}

abstract interface class GitWorktreeClient {
  Future<List<GitWorktreeInfo>> list();

  Future<bool> branchExists(String branch);

  Future<void> add({
    required String path,
    required String branch,
    required String baseRevision,
  });

  Future<List<String>> dirtyPaths(String path);

  Future<void> remove(String path);
}

class NativeGitWorktreeClient implements GitWorktreeClient {
  const NativeGitWorktreeClient(this.controlRoot);

  final Directory controlRoot;

  @override
  Future<List<GitWorktreeInfo>> list() async {
    final result = await _run(['worktree', 'list', '--porcelain']);
    final records = <GitWorktreeInfo>[];
    String? path;
    String? head;
    String? branch;
    void finish() {
      if (path != null && head != null) {
        records.add(GitWorktreeInfo(path: path!, head: head!, branch: branch));
      }
      path = null;
      head = null;
      branch = null;
    }

    for (final line in LineSplitter.split('${result.stdout}')) {
      if (line.isEmpty) {
        finish();
      } else if (line.startsWith('worktree ')) {
        path = _canonical(line.substring('worktree '.length));
      } else if (line.startsWith('HEAD ')) {
        head = line.substring('HEAD '.length);
      } else if (line.startsWith('branch refs/heads/')) {
        branch = line.substring('branch refs/heads/'.length);
      }
    }
    finish();
    return records;
  }

  @override
  Future<bool> branchExists(String branch) async {
    final result = await Process.run('git', [
      'show-ref',
      '--verify',
      '--quiet',
      'refs/heads/$branch',
    ], workingDirectory: controlRoot.path);
    if (result.exitCode == 0) return true;
    if (result.exitCode == 1) return false;
    throw TaskControlError(
      'workspace.git-failed',
      'Unable to inspect task branch (exit=${result.exitCode}).',
    );
  }

  @override
  Future<void> add({
    required String path,
    required String branch,
    required String baseRevision,
  }) async {
    await _run(['worktree', 'add', '-b', branch, path, baseRevision]);
  }

  @override
  Future<List<String>> dirtyPaths(String path) async {
    final result = await _run(['-C', path, 'status', '--porcelain=v1']);
    return LineSplitter.split('${result.stdout}')
        .where((line) => line.isNotEmpty)
        .map((line) => line.length > 3 ? line.substring(3) : line)
        .toList();
  }

  @override
  Future<void> remove(String path) => _run(['worktree', 'remove', path]);

  Future<ProcessResult> _run(List<String> arguments) async {
    final result = await Process.run(
      'git',
      arguments,
      workingDirectory: controlRoot.path,
    );
    if (result.exitCode != 0) {
      final diagnostic = '${result.stderr}'.trim();
      throw TaskControlError(
        'workspace.git-failed',
        diagnostic.isEmpty
            ? 'Git worktree command failed (exit=${result.exitCode}).'
            : diagnostic,
      );
    }
    return result;
  }
}

String canonicalWorkspacePath(String path) => p.normalize(p.absolute(path));

String _canonical(String path) => canonicalWorkspacePath(path);
