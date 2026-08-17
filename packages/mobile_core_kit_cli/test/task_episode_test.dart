import 'dart:io';

import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_episode.dart';
import 'package:test/test.dart';

void main() {
  test('persists only sanitized bounded episode events', () async {
    final root = await Directory.systemTemp.createTemp('mobilekit_episode_');
    addTearDown(() => root.delete(recursive: true));
    final store = FileTaskEpisodeStore(root);

    store.append(
      'test-task-authority',
      TaskEpisodeEvent(
        at: DateTime.utc(2026, 8, 11),
        type: 'verification-failed',
        status: 'failed',
        summary: 'token=secret person@example.com',
        taskFingerprint: _hash,
        boundary: 'test.application',
      ),
    );

    final restored = store.read('test-task-authority');
    expect(restored.events, hasLength(1));
    expect(restored.events.single.summary, isNot(contains('secret')));
    expect(restored.events.single.summary, isNot(contains('@')));
  });

  test('rejects unsupported episode schemas', () async {
    final root = await Directory.systemTemp.createTemp('mobilekit_episode_');
    addTearDown(() => root.delete(recursive: true));
    final file = File(
      '${root.path}/.tmp/mobilekit/tasks/test-task-authority/episode.json',
    )..createSync(recursive: true);
    file.writeAsStringSync('{"schemaVersion":99}\n');

    expect(
      () => FileTaskEpisodeStore(root).read('test-task-authority'),
      throwsA(
        isA<TaskControlError>().having(
          (error) => error.code,
          'code',
          'task.episode-invalid',
        ),
      ),
    );
  });
}

const _hash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
