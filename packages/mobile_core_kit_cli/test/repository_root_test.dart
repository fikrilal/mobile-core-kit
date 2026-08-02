import 'dart:io';

import 'package:mobile_core_kit_cli/src/repository/repository_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('finds the repository root from a nested directory', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_root_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    File(
      p.join(tempDirectory.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: test\n');
    final markerFile =
        File(p.join(tempDirectory.path, '.mobilekit', 'template.yaml'))
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(
            'schema: 1\ntemplate: mobile_core_kit\nversion: 2026-08-01\n',
          );
    final nestedDirectory = Directory(
      p.join(tempDirectory.path, 'packages', 'cli'),
    )..createSync(recursive: true);

    final result = const RepositoryRootLocator().find(
      startDirectory: nestedDirectory,
    );

    expect(result?.path, tempDirectory.path);
    expect(markerFile.existsSync(), isTrue);
  });

  test('still finds an initialized repository with Git metadata', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_git_root_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    File(
      p.join(tempDirectory.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: test\n');
    File(
      p.join(tempDirectory.path, '.git'),
    ).writeAsStringSync('gitdir: test\n');

    final nestedDirectory = Directory(p.join(tempDirectory.path, 'lib', 'src'))
      ..createSync(recursive: true);

    final result = const RepositoryRootLocator().find(
      startDirectory: nestedDirectory,
    );

    expect(result?.path, tempDirectory.path);
  });

  test('returns null when no repository markers are present', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'mobile_core_kit_cli_no_root_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));

    expect(
      const RepositoryRootLocator().find(startDirectory: tempDirectory),
      isNull,
    );
  });
}
