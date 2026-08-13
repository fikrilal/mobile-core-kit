import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'discovers committed and dirty paths with stable fingerprints',
    () async {
      final root = await Directory.systemTemp.createTemp('mobilekit_git_');
      addTearDown(() => root.delete(recursive: true));
      await _git(root, ['init']);
      await _git(root, ['config', 'user.email', 'test@example.com']);
      await _git(root, ['config', 'user.name', 'Test']);
      File(p.join(root.path, 'tracked.txt')).writeAsStringSync('base\n');
      await _git(root, ['add', 'tracked.txt']);
      await _git(root, ['commit', '-m', 'base']);
      final repository = NativeGitRepository(root);
      final base = await repository.head();

      File(p.join(root.path, 'tracked.txt')).writeAsStringSync('changed\n');
      File(p.join(root.path, 'new.txt')).writeAsStringSync('new\n');
      final dirty = await repository.worktreeChanges();

      expect(dirty.map((change) => change.path), ['new.txt', 'tracked.txt']);
      expect(dirty.first.sources, [ChangeSource.untracked]);
      expect(await repository.contentFingerprint('tracked.txt'), hasLength(64));
      expect(await repository.changesSince(base), isEmpty);
    },
  );
}

Future<void> _git(Directory root, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: root.path,
  );
  expect(result.exitCode, 0, reason: '${result.stderr}');
}
