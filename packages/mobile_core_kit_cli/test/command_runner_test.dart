import 'dart:io';

import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('resolves pinned POSIX SDK executables', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runner_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final binDirectory = Directory(
      p.join(tempDirectory.path, '.fvm', 'flutter_sdk', 'bin'),
    )..createSync(recursive: true);
    File(p.join(binDirectory.path, 'dart')).writeAsStringSync('');
    File(p.join(binDirectory.path, 'flutter')).writeAsStringSync('');

    final runner = CommandRunner(
      rootDirectory: tempDirectory,
      platform: CommandPlatform.posix,
    );

    expect(runner.resolve('dart').isPinned, isTrue);
    expect(
      runner.resolve('dart').executable,
      p.join(binDirectory.path, 'dart'),
    );
    expect(runner.resolve('flutter').isPinned, isTrue);
  });

  test(
    'falls back to PATH command names when the pinned SDK is absent',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'mobile_core_kit_cli_runner_fallback_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));

      final runner = CommandRunner(
        rootDirectory: tempDirectory,
        platform: CommandPlatform.posix,
      );

      expect(runner.resolve('dart').isPinned, isFalse);
      expect(runner.resolve('dart').executable, 'dart');
      expect(runner.resolve('git').executable, 'git');
    },
  );

  test('resolves Windows SDK batch files', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_windows_runner_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    final binDirectory = Directory(
      p.join(tempDirectory.path, '.fvm', 'flutter_sdk', 'bin'),
    )..createSync(recursive: true);
    File(p.join(binDirectory.path, 'dart.bat')).writeAsStringSync('');

    final runner = CommandRunner(
      rootDirectory: tempDirectory,
      platform: CommandPlatform.windows,
    );

    expect(runner.resolve('dart').isPinned, isTrue);
    expect(
      runner.resolve('dart').executable,
      p.join(binDirectory.path, 'dart.bat'),
    );
  });

  test('describes PATH fallback with a stable diagnostic id', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_runner_diagnostics_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final output = StringBuffer();
    final runner = CommandRunner(
      rootDirectory: tempDirectory,
      platform: CommandPlatform.posix,
      output: output,
    );

    final resolved = runner.resolve('flutter');

    expect(resolved.isPinned, isFalse);
    expect(
      runner.toolchainDiagnostic('flutter', resolved),
      contains('WARN [toolchain.path-fallback]'),
    );
    expect(output, isEmpty);
  });
}
