import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/maintenance/maintenance_service.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'fixed registry runs once and writes a sanitized private report',
    () async {
      final fixture = _fixture();
      addTearDown(() => fixture.root.deleteSync(recursive: true));
      final calls = <List<String>>[];
      var codegenOutputDirectoryPrepared = false;
      var codegenCheckoutIsExternal = false;
      final service = MaintenanceService(
        root: fixture.root,
        controlRoot: fixture.root,
        runCommand: (workingDirectory, command, timeout) async {
          calls.add(command);
          if (command.any((value) => value.contains('codegen verify'))) {
            codegenOutputDirectoryPrepared = Directory(
              p.join(workingDirectory.path, '.tmp'),
            ).existsSync();
            codegenCheckoutIsExternal = !p.isWithin(
              fixture.root.path,
              workingDirectory.path,
            );
          }
          expect(timeout, lessThanOrEqualTo(const Duration(minutes: 25)));
          return 0;
        },
        now: () => DateTime.utc(2026, 8, 12),
      );

      final result = await service.runOnce();

      expect(result.passed, isTrue);
      expect(result.steps.last.id, MaintenanceStepId.codegen);
      expect(
        calls.singleWhere((command) => command.contains('outdated')),
        contains(
          p.join(
            fixture.root.path,
            '.fvm',
            'flutter_sdk',
            'bin',
            Platform.isWindows ? 'flutter.bat' : 'flutter',
          ),
        ),
      );
      expect(codegenOutputDirectoryPrepared, isTrue);
      expect(codegenCheckoutIsExternal, isTrue);
      final codegenCommand = calls.singleWhere(
        (command) => command.any((value) => value.contains('codegen verify')),
      );
      expect(
        codegenCommand.first,
        Platform.isWindows ? 'powershell.exe' : '/bin/bash',
      );
      expect(
        codegenCommand,
        contains(
          p.join(
            fixture.root.path,
            '.fvm',
            'flutter_sdk',
            'bin',
            Platform.isWindows ? 'flutter.bat' : 'flutter',
          ),
        ),
      );
      expect(
        codegenCommand,
        contains(
          p.join(
            fixture.root.path,
            '.fvm',
            'flutter_sdk',
            'bin',
            'cache',
            'dart-sdk',
            'bin',
            Platform.isWindows ? 'dart.exe' : 'dart',
          ),
        ),
      );
      final report = File(p.join(fixture.root.path, result.reportPath));
      final decoded = (jsonDecode(report.readAsStringSync()) as Map)
          .cast<String, Object?>();
      expect(decoded.keys, {
        'schemaVersion',
        'startedAt',
        'completedAt',
        'outcome',
        'steps',
        'observations',
      });
      final observations = (decoded['observations'] as Map)
          .cast<String, Object?>();
      expect(observations['activeV2Plans'], ['docs/exec-plans/active/test.md']);
      expect(observations['runtimeEvidenceCount'], 1);
      expect(observations['staleRuntimeEvidence'], [
        '_artifacts/mobile/old/evidence.json',
      ]);
      expect(report.readAsStringSync(), isNot(contains(fixture.root.path)));
      if (!Platform.isWindows) {
        expect(FileStat.statSync(report.path).mode & 0x1ff, 0x180); // 0600
      }
    },
  );

  test('records fixed step failures without accepting command input', () async {
    final fixture = _fixture();
    addTearDown(() => fixture.root.deleteSync(recursive: true));
    final service = MaintenanceService(
      root: fixture.root,
      controlRoot: fixture.root,
      runCommand: (_, command, __) async =>
          command.contains('outdated') ? 7 : 0,
      now: () => DateTime.utc(2026, 8, 12),
    );

    final result = await service.runOnce();

    expect(result.passed, isFalse);
    expect(
      result.steps
          .singleWhere((step) => step.id == MaintenanceStepId.dependencies)
          .status,
      'failed',
    );
    expect(
      maintenanceRegistry
          .expand((step) => step.commands)
          .every(
            (command) => const {'dart', 'flutter'}.contains(command.first),
          ),
      isTrue,
    );
  });

  test(
    'fails closed if any maintenance command changes repository state',
    () async {
      final fixture = _fixture();
      addTearDown(() => fixture.root.deleteSync(recursive: true));
      var mutated = false;
      final service = MaintenanceService(
        root: fixture.root,
        controlRoot: fixture.root,
        steps: [maintenanceRegistry.first],
        runCommand: (_, __, ___) async {
          if (!mutated) {
            mutated = true;
            File(
              p.join(fixture.root.path, 'tracked.txt'),
            ).writeAsStringSync('changed\n');
          }
          return 0;
        },
      );

      await expectLater(
        service.runOnce(),
        throwsA(_controlError('maintenance.source-mutated')),
      );
    },
  );
}

_MaintenanceFixture _fixture() {
  final root = Directory.systemTemp.createTempSync('mobilekit_maintenance_');
  File(
    p.join(root.path, '.gitignore'),
  ).writeAsStringSync('.tmp/\n_artifacts/\n');
  File(p.join(root.path, 'tracked.txt')).writeAsStringSync('baseline\n');
  File(
      p.join(
        root.path,
        '.fvm',
        'flutter_sdk',
        'bin',
        Platform.isWindows ? 'flutter.bat' : 'flutter',
      ),
    )
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('fixture\n');
  File(
      p.join(
        root.path,
        '.fvm',
        'flutter_sdk',
        'bin',
        'cache',
        'dart-sdk',
        'bin',
        Platform.isWindows ? 'dart.exe' : 'dart',
      ),
    )
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('fixture\n');
  File(p.join(root.path, 'docs/exec-plans/active/test.md'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('**Plan version:** 2\n');
  File(p.join(root.path, '_artifacts/mobile/old/evidence.json'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync('{}\n')
    ..setLastModifiedSync(DateTime.utc(2026, 6, 1));
  _git(root, ['init', '--quiet']);
  _git(root, ['config', 'user.email', 'fixture@example.test']);
  _git(root, ['config', 'user.name', 'Fixture']);
  _git(root, ['add', '--', '.gitignore', 'tracked.txt', 'docs']);
  _git(root, ['commit', '--quiet', '-m', 'fixture']);
  return _MaintenanceFixture(root);
}

void _git(Directory root, List<String> arguments) {
  final result = Process.runSync('git', arguments, workingDirectory: root.path);
  if (result.exitCode != 0) {
    throw StateError('git ${arguments.first} failed: ${result.stderr}');
  }
}

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);

class _MaintenanceFixture {
  const _MaintenanceFixture(this.root);

  final Directory root;
}
