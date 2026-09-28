import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:path/path.dart' as p;

class TaskControlRootLocator {
  const TaskControlRootLocator();

  Future<Directory> locate(Directory checkoutRoot) async {
    final result = await Process.run('git', [
      'worktree',
      'list',
      '--porcelain',
    ], workingDirectory: checkoutRoot.path);
    if (result.exitCode != 0) {
      throw TaskControlError(
        'workspace.discovery-failed',
        'Unable to discover the primary Git worktree.',
      );
    }
    final first = LineSplitter.split(
      '${result.stdout}',
    ).firstWhere((line) => line.startsWith('worktree '), orElse: () => '');
    if (first.isEmpty) {
      throw const TaskControlError(
        'workspace.discovery-invalid',
        'Git returned no primary worktree.',
      );
    }
    final path = p.normalize(p.absolute(first.substring('worktree '.length)));
    final root = Directory(path);
    if (!root.existsSync()) {
      throw const TaskControlError(
        'workspace.discovery-invalid',
        'The discovered primary worktree does not exist.',
      );
    }
    return root;
  }
}
