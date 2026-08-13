import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:path/path.dart' as p;

class PublicationRepositoryState {
  const PublicationRepositoryState({
    required this.branch,
    required this.remote,
    required this.head,
    required this.stagedPaths,
    required this.worktreePaths,
  });

  final String branch;
  final String remote;
  final String head;
  final List<String> stagedPaths;
  final List<String> worktreePaths;
}

abstract interface class PublicationAdapter {
  Future<PublicationRepositoryState> inspect();

  Future<void> stage(List<String> paths);

  Future<String> commit(String message);

  Future<String> push(String branch);

  Future<String> createDraftPr({
    required String branch,
    required String base,
    required String title,
    required String bodyPath,
  });
}

class NativePublicationAdapter implements PublicationAdapter {
  const NativePublicationAdapter(this.root);

  final Directory root;

  @override
  Future<PublicationRepositoryState> inspect() async {
    final branch = (await _git(const ['branch', '--show-current'])).trim();
    validatePublicationBranch(branch);
    final remote = normalizePublicationRemote(
      (await _git(const ['remote', 'get-url', 'origin'])).trim(),
    );
    final head = (await _git(const ['rev-parse', '--verify', 'HEAD'])).trim();
    if (!RegExp(r'^[0-9a-f]{40,64}$').hasMatch(head)) {
      throw const TaskControlError(
        'handoff.head-invalid',
        'Publication checkout HEAD is invalid.',
      );
    }
    final staged = _paths(
      await _git(const ['diff', '--cached', '--name-only', '-z', '--']),
    );
    final worktree = (await NativeGitRepository(
      root,
    ).worktreeChanges()).map((change) => change.path).toList()..sort();
    return PublicationRepositoryState(
      branch: branch,
      remote: remote,
      head: head,
      stagedPaths: staged,
      worktreePaths: worktree,
    );
  }

  @override
  Future<void> stage(List<String> paths) async {
    if (paths.isEmpty) {
      throw const TaskControlError(
        'handoff.paths-empty',
        'No verified task paths are available to stage.',
      );
    }
    await _git(['add', '--', ...paths]);
  }

  @override
  Future<String> commit(String message) async {
    validatePublicationText(message, 'commit message');
    await _git(['commit', '-m', message]);
    return (await _git(const ['rev-parse', '--verify', 'HEAD'])).trim();
  }

  @override
  Future<String> push(String branch) async {
    validatePublicationBranch(branch);
    await _git(['push', 'origin', 'refs/heads/$branch:refs/heads/$branch']);
    return (await _git(const ['rev-parse', '--verify', 'HEAD'])).trim();
  }

  @override
  Future<String> createDraftPr({
    required String branch,
    required String base,
    required String title,
    required String bodyPath,
  }) async {
    validatePublicationBranch(branch);
    validatePublicationBase(base);
    validatePublicationText(title, 'pull request title');
    if (!p.isAbsolute(bodyPath)) {
      throw const TaskControlError(
        'handoff.body-path-invalid',
        'Draft PR body path must be absolute.',
      );
    }
    final remote = (await inspect()).remote;
    final result = await _run('gh', [
      'pr',
      'create',
      '--draft',
      '--repo',
      remote,
      '--head',
      branch,
      '--base',
      base,
      '--title',
      title,
      '--body-file',
      bodyPath,
      '--no-maintainer-edit',
    ]);
    final url = result.trim();
    if (!RegExp(
      r'^https://[a-z0-9.-]+/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/pull/\d+$',
    ).hasMatch(url)) {
      throw const TaskControlError(
        'handoff.pr-result-invalid',
        'GitHub CLI returned an invalid draft PR URL.',
      );
    }
    return url;
  }

  Future<String> _git(List<String> arguments) => _run('git', arguments);

  Future<String> _run(String executable, List<String> arguments) async {
    final environment = Map<String, String>.from(Platform.environment)
      ..remove('MOBILEKIT_HANDOFF_APPROVAL');
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: root.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
      environment: environment,
      includeParentEnvironment: false,
    );
    if (result.exitCode != 0) {
      throw TaskControlError(
        'handoff.command-failed',
        '$executable ${arguments.isEmpty ? 'command' : arguments.first} failed.',
      );
    }
    return result.stdout as String;
  }
}

String normalizePublicationRemote(String value) {
  final scp = RegExp(
    r'^git@([a-z0-9.-]+):([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git)?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (scp != null) {
    return '${scp.group(1)!.toLowerCase()}/${scp.group(2)}/${scp.group(3)}';
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.query.isNotEmpty ||
      uri.fragment.isNotEmpty) {
    throw const TaskControlError(
      'handoff.remote-invalid',
      'Origin must be credential-free HTTPS or git@host SCP syntax.',
    );
  }
  final match = RegExp(
    r'^/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git)?/?$',
  ).firstMatch(uri.path);
  if (match == null) {
    throw const TaskControlError(
      'handoff.remote-invalid',
      'Origin remote repository identity is invalid.',
    );
  }
  return '${uri.host.toLowerCase()}/${match.group(1)}/${match.group(2)}';
}

void validatePublicationBranch(String value) {
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{0,127}$').hasMatch(value) ||
      value.contains('..') ||
      value.endsWith('/') ||
      value == 'main' ||
      value == 'master') {
    throw const TaskControlError(
      'handoff.branch-invalid',
      'Publication requires a non-protected named task branch.',
    );
  }
}

void validatePublicationBase(String value) {
  if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{0,127}$').hasMatch(value) ||
      value.contains('..') ||
      value.endsWith('/')) {
    throw const TaskControlError(
      'handoff.base-invalid',
      'Draft PR base branch is invalid.',
    );
  }
}

void validatePublicationText(String value, String label) {
  if (value.trim() != value ||
      value.isEmpty ||
      value.length > 200 ||
      value.contains('\n') ||
      value.contains('\r') ||
      value.contains('\u0000')) {
    throw TaskControlError(
      'handoff.text-invalid',
      'Handoff $label is invalid.',
    );
  }
}

List<String> _paths(String value) {
  final result = value
      .split('\x00')
      .where((path) => path.isNotEmpty)
      .map(normalizeRepositoryPath)
      .toSet()
      .toList();
  result.sort();
  return result;
}
