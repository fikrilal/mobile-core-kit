import 'dart:io';

import 'package:mobile_core_kit_cli/src/guardrails/hardcoded_ui_colors_check.dart';
import 'package:mobile_core_kit_cli/src/guardrails/modal_entrypoints_check.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('hardcoded color guardrail reports repository-relative violations', () {
    final repository = _createRepository();
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeDart(
      repository,
      'lib/features/example.dart',
      'const color = Colors.red;\n',
    );
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = HardcodedUiColorsCheck(
      rootDirectory: repository,
      output: output,
      errorOutput: errors,
    ).run();

    expect(result, 1);
    expect(errors.toString(), contains('lib/features/example.dart:1'));
    expect(errors.toString(), contains('Colors.*'));
  });

  test('modal guardrail preserves the adaptive-widget allowlist', () {
    final repository = _createRepository();
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeDart(
      repository,
      'lib/core/design_system/adaptive/widgets/modal.dart',
      'void open() { showDialog(); }\n',
    );
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = ModalEntrypointsCheck(
      rootDirectory: repository,
      output: output,
      errorOutput: errors,
    ).run();

    expect(result, 0);
    expect(output.toString(), contains('OK: no disallowed modal entrypoints'));
    expect(errors.toString(), isEmpty);
  });

  test('modal guardrail rejects platform calls outside the allowlist', () {
    final repository = _createRepository();
    addTearDown(() => repository.deleteSync(recursive: true));
    _writeDart(
      repository,
      'lib/features/example.dart',
      'void open() { showDialog(); }\n',
    );
    final output = StringBuffer();
    final errors = StringBuffer();

    final result = ModalEntrypointsCheck(
      rootDirectory: repository,
      output: output,
      errorOutput: errors,
    ).run();

    expect(result, 1);
    expect(errors.toString(), contains('lib/features/example.dart:1'));
    expect(errors.toString(), contains('showDialog'));
  });
}

Directory _createRepository() {
  final repository = Directory.systemTemp.createTempSync(
    'mobile_core_kit_cli_guardrails_test_',
  );
  Directory(p.join(repository.path, 'lib')).createSync(recursive: true);
  return repository;
}

void _writeDart(Directory repository, String relativePath, String content) {
  final file = File(p.join(repository.path, relativePath))
    ..createSync(recursive: true);
  file.writeAsStringSync(content);
}
