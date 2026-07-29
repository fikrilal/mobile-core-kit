import 'dart:io';

import 'package:mobile_core_kit_cli/src/doctor/doctor.dart';
import 'package:mobile_core_kit_cli/src/doctor/executable_finder.dart';
import 'package:mobile_core_kit_cli/src/process/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('reports a healthy pinned toolchain', () async {
    final tempDirectory = await _createRepository();
    addTearDown(() => tempDirectory.delete(recursive: true));
    _writeFvmSdk(tempDirectory);

    final pathDirectory = Directory(p.join(tempDirectory.path, 'bin'))
      ..createSync();
    File(p.join(pathDirectory.path, 'git')).writeAsStringSync('');
    File(p.join(pathDirectory.path, 'npx')).writeAsStringSync('');

    final report = Doctor(
      executableFinder: ExecutableFinder(
        environment: {'PATH': pathDirectory.path},
        isWindows: false,
      ),
      platform: CommandPlatform.posix,
    ).inspect(startDirectory: tempDirectory);

    expect(report.hasErrors, isFalse);
    expect(
      report.checks.where((check) => check.status.name == 'warning'),
      isEmpty,
    );
  });

  test('reports missing required tools as errors', () async {
    final tempDirectory = await _createRepository();
    addTearDown(() => tempDirectory.delete(recursive: true));

    final report = Doctor(
      executableFinder: ExecutableFinder(
        environment: {'PATH': p.join(tempDirectory.path, 'bin')},
        isWindows: false,
      ),
      platform: CommandPlatform.posix,
    ).inspect(startDirectory: tempDirectory);

    expect(report.hasErrors, isTrue);
    expect(
      report.checks.any(
        (check) =>
            check.label == 'npx' && check.status == DoctorCheckStatus.error,
      ),
      isTrue,
    );
  });

  test('reports a PATH fallback as a warning', () async {
    final tempDirectory = await _createRepository();
    addTearDown(() => tempDirectory.delete(recursive: true));

    final pathDirectory = Directory(p.join(tempDirectory.path, 'bin'))
      ..createSync();
    for (final executable in ['dart', 'flutter', 'git', 'npx']) {
      File(p.join(pathDirectory.path, executable)).writeAsStringSync('');
    }

    final report = Doctor(
      executableFinder: ExecutableFinder(
        environment: {'PATH': pathDirectory.path},
        isWindows: false,
      ),
      platform: CommandPlatform.posix,
    ).inspect(startDirectory: tempDirectory);

    expect(report.hasErrors, isFalse);
    expect(
      report.checks.any(
        (check) =>
            check.label == 'dart' && check.status == DoctorCheckStatus.warning,
      ),
      isTrue,
    );
  });
}

Future<Directory> _createRepository() async {
  final directory = await Directory.systemTemp.createTemp(
    'mobile_core_kit_cli_doctor_test_',
  );
  File(p.join(directory.path, '.mobilekit', 'template.yaml'))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
    );
  File(
    p.join(directory.path, 'pubspec.yaml'),
  ).writeAsStringSync('name: test\n');
  File(
    p.join(directory.path, '.fvmrc'),
  ).writeAsStringSync('{"flutter":"3.41.4"}\n');
  return directory;
}

void _writeFvmSdk(Directory root) {
  final binDirectory = Directory(
    p.join(root.path, '.fvm', 'flutter_sdk', 'bin'),
  )..createSync(recursive: true);
  File(p.join(binDirectory.path, 'dart')).writeAsStringSync('');
  File(p.join(binDirectory.path, 'flutter')).writeAsStringSync('');
}
