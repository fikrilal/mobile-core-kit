import 'dart:io';

import 'package:args/args.dart';

Future<void> main(List<String> argv) async {
  exitCode = await _run(argv);
}

Future<int> _run(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('env', abbr: 'e', defaultsTo: 'dev')
    ..addFlag('apply-fixes', defaultsTo: false)
    ..addFlag('check-codegen', defaultsTo: false)
    ..addFlag('skip-duplication', defaultsTo: false)
    ..addFlag('skip-format', defaultsTo: false)
    ..addFlag('skip-tests', defaultsTo: false);

  final args = parser.parse(argv);
  final env = args.option('env')!;
  final applyFixes = args.flag('apply-fixes');
  final checkCodegen = args.flag('check-codegen');
  final skipDuplication = args.flag('skip-duplication');
  final skipFormat = args.flag('skip-format');
  final skipTests = args.flag('skip-tests');

  final envs = {'dev', 'staging', 'prod'};
  if (!envs.contains(env)) {
    stderr.writeln("Unknown --env '$env'. Expected one of: ${envs.join(', ')}");
    return 2;
  }

  final runner = _CommandRunner.detect(Directory.current);

  Future<int> step(String title, List<String> command) async {
    stdout.writeln('\n==> $title');
    return runner.run(command);
  }

  var exitCode = 0;

  exitCode = await step('Flutter pub get', ['flutter', 'pub', 'get']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify env schema', [
    'dart',
    'run',
    'tool/verify_env_schema.dart',
    '--all',
    if (env == 'prod') '--strict',
  ]);
  if (exitCode != 0) return exitCode;

  if (checkCodegen) {
    exitCode = await step('Verify codegen outputs', [
      'dart',
      'run',
      'tool/verify_codegen.dart',
    ]);
    if (exitCode != 0) return exitCode;
  }

  if (applyFixes) {
    exitCode = await step('Dart fix (apply: directives_ordering)', [
      'dart',
      'fix',
      '--apply',
      '--code',
      'directives_ordering',
    ]);
    if (exitCode != 0) return exitCode;

    if (!skipFormat) {
      exitCode = await step('Dart format (apply)', ['dart', 'format', '.']);
      if (exitCode != 0) return exitCode;
    }
  }

  exitCode = await step('Generate build config (.env/$env.yaml)', [
    'dart',
    'run',
    'tool/gen_config.dart',
    '--env',
    env,
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Flutter gen-l10n', ['flutter', 'gen-l10n']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify untranslated messages', [
    'dart',
    'run',
    'tool/verify_untranslated_messages.dart',
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify AGENTS project map drift', [
    'dart',
    'run',
    'tool/verify_project_map_drift.dart',
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Flutter analyze', ['flutter', 'analyze']);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Custom lint', ['dart', 'run', 'custom_lint']);
  if (exitCode != 0) return exitCode;

  if (!skipDuplication) {
    exitCode = await step('Verify duplication (core)', [
      'dart',
      'run',
      'mobile_core_kit_cli:mobilekit',
      'duplication',
      'check',
      '--profile',
      'core',
    ]);
    if (exitCode != 0) return exitCode;

    exitCode = await step('Verify duplication (small helpers)', [
      'dart',
      'run',
      'mobile_core_kit_cli:mobilekit',
      'duplication',
      'check',
      '--profile',
      'small-helpers',
    ]);
    if (exitCode != 0) return exitCode;
  }

  exitCode = await step('Verify modal entrypoints', [
    'dart',
    'run',
    'tool/verify_modal_entrypoints.dart',
  ]);
  if (exitCode != 0) return exitCode;

  exitCode = await step('Verify hardcoded UI colors', [
    'dart',
    'run',
    'tool/verify_hardcoded_ui_colors.dart',
  ]);
  if (exitCode != 0) return exitCode;

  if (!skipTests) {
    exitCode = await step('Flutter test', ['flutter', 'test']);
    if (exitCode != 0) return exitCode;
  }

  if (!skipFormat) {
    exitCode = await step('Dart format (check)', [
      'dart',
      'format',
      '--output',
      'none',
      '--set-exit-if-changed',
      '.',
    ]);
    if (exitCode != 0) return exitCode;
  }

  stdout.writeln('\nOK');
  return 0;
}

class _CommandRunner {
  _CommandRunner(this._rootDir, this._mode);

  final Directory _rootDir;
  final _RunnerMode _mode;

  static _CommandRunner detect(Directory rootDir) {
    if (Platform.isWindows) return _CommandRunner(rootDir, _RunnerMode.windows);
    return _CommandRunner(rootDir, _RunnerMode.posix);
  }

  Future<int> run(List<String> command) async {
    if (command.isEmpty) return 0;

    final executable = command.first;
    final args = command.sublist(1);

    return switch (_mode) {
      _RunnerMode.windows => _runNativeWindows(executable, args),
      _RunnerMode.posix => _runPosix(executable, args),
    };
  }

  Future<int> _runPosix(String executable, List<String> args) async {
    final resolved = _resolvePosixExecutable(executable);
    final process = await Process.start(
      resolved.executable,
      args,
      workingDirectory: _rootDir.path,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  _ResolvedCommand _resolvePosixExecutable(String executable) {
    final flutterPath = File('.fvm/flutter_sdk/bin/flutter');
    final dartPath = File('.fvm/flutter_sdk/bin/dart');
    if (executable == 'flutter' && flutterPath.existsSync()) {
      return _ResolvedCommand(flutterPath.path);
    }
    if (executable == 'dart' && dartPath.existsSync()) {
      return _ResolvedCommand(dartPath.path);
    }
    return _ResolvedCommand(executable);
  }

  Future<int> _runNativeWindows(String executable, List<String> args) async {
    final resolved = _resolveWindowsExecutable(executable);
    final process = await Process.start(
      resolved.executable,
      args,
      workingDirectory: _rootDir.path,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  _ResolvedCommand _resolveWindowsExecutable(String executable) {
    final flutterBat = File('.fvm\\flutter_sdk\\bin\\flutter.bat');
    final dartBat = File('.fvm\\flutter_sdk\\bin\\dart.bat');
    if (executable == 'flutter' && flutterBat.existsSync()) {
      return _ResolvedCommand(flutterBat.path);
    }
    if (executable == 'dart' && dartBat.existsSync()) {
      return _ResolvedCommand(dartBat.path);
    }
    return _ResolvedCommand(executable);
  }
}

class _ResolvedCommand {
  _ResolvedCommand(this.executable);

  final String executable;
}

enum _RunnerMode { windows, posix }
